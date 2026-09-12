import '../i18n/app_locale.dart';

/// Which of the app's two tracks a piece of content belongs to.
enum Track {
  government('সরকারি কাজ', 'Government works'),
  private('নিজের বাড়ি', 'Your own house'),

  /// Content that applies whichever the reader picked — how to tell good
  /// cement, what curing is for, how to read a drawing.
  ///
  /// This is a property of a card, never an answer a reader gives. It used to
  /// be offered in the picker as "দুটোই", which asked someone watching a road
  /// or building a house to describe themselves as both, and told the app
  /// nothing it could act on: choosing it simply showed everything. The two
  /// real answers are the two real situations.
  either('', '');

  const Track(this._bn, this._en);

  final String _bn;
  final String _en;

  L10nText get label => L10nText(_bn, _en);

  /// The answers a reader can give. [either] is not among them.
  static const choices = [Track.government, Track.private];

  /// Reads a content pack's track. Content may be marked [either].
  static Track parse(String? s) => switch (s) {
        'government' => Track.government,
        'private' => Track.private,
        _ => Track.either,
      };

  /// Reads a reader's stored choice.
  ///
  /// Anyone who picked "দুটোই" before it was withdrawn is moved to government
  /// works, which is the wider of the two sets and the app's first purpose.
  /// The chips on the home page change it in one tap.
  static Track parseChoice(String? s) =>
      s == 'private' ? Track.private : Track.government;

  String get key => name;

  bool covers(Track selected) =>
      this == Track.either || selected == Track.either || this == selected;
}

/// Review state of a technical claim.
///
/// Nothing ships as [verified] until a licensed civil engineer has signed it
/// off against the cited source. Anything still in [review] carries a visible
/// badge, so the user is told what has and has not been checked.
/// See docs/CONTENT_REVIEW.md.
enum ReviewStatus {
  verified,
  review,

  /// An estimator's shortcut, not a specification.
  ///
  /// Separate from [review] because the two need opposite treatment: a review
  /// claim is probably right and waiting to be confirmed, while a rule of thumb
  /// is only ever for sanity-checking a number somebody quoted you. Some of
  /// them — foundation depth taken as a foot per storey, beam depth in inches
  /// taken as the span in feet — are unsafe if read as a way to decide a
  /// dimension, so the card carrying one always says so on its face.
  ruleOfThumb;

  static ReviewStatus parse(String? s) => switch (s) {
        'verified' => ReviewStatus.verified,
        'ruleOfThumb' => ReviewStatus.ruleOfThumb,
        _ => ReviewStatus.review,
      };

  /// Whether a badge is shown against a claim with this status.
}

/// Where a number came from.
class Citation {
  const Citation({
    required this.source,
    this.clause,
    this.url,
    this.status = ReviewStatus.review,
  });

  /// e.g. 'BNBC 2020, পার্ট ৫', 'PWD SoR 2022 (২য় সংশোধিত), অধ্যায় ০৭'.
  final L10nText source;

  /// Clause or item number within the source, when known.
  final L10nText? clause;

  final String? url;

  final ReviewStatus status;

  factory Citation.fromJson(Map<String, dynamic> j) => Citation(
        source: L10nText.fromJson(j['source']),
        clause: j['clause'] == null ? null : L10nText.fromJson(j['clause']),
        url: j['url'] as String?,
        status: ReviewStatus.parse(j['status'] as String?),
      );

  String display(AppLocale locale) {
    final c = clause?.of(locale);
    return c == null || c.isEmpty
        ? source.of(locale)
        : '${source.of(locale)} — $c';
  }
}

/// One screen of the guide.
/// Who a card is written for.
///
/// The guide has to serve a homeowner who has never read a drawing and an
/// assistant engineer who reads them all day, and the way that fails is by
/// burying the first reader under detailing tables. Tier is a field rather than
/// a convention so a test can hold the line: nothing above [general] is
/// reachable from the general reader's path.
enum CardTier {
  /// Plain language, one diagram, one number. Every reader.
  general,

  /// For the person actually having the work done: measurements, stage checks.
  work,

  /// Detailing, foundation types, bore logs. Kept behind its own entry.
  reference;

  static CardTier parse(String? s) => switch (s) {
        'work' => CardTier.work,
        'reference' => CardTier.reference,
        _ => CardTier.general,
      };

  String get key => name;
}

class GuideCard {
  const GuideCard({
    required this.id,
    required this.title,
    required this.body,
    this.tier = CardTier.general,
    this.watchFor = const [],
    this.citations = const [],
    this.audioAsset,
    this.imageAsset,
    this.diagram,
    this.calc,
  });

  final String id;
  final L10nText title;
  final L10nText body;

  /// Who this card is written for.
  final CardTier tier;

  /// "কী দেখবেন" — the concrete, checkable points.
  final List<L10nText> watchFor;

  final List<Citation> citations;
  final String? audioAsset;
  final String? imageAsset;

  /// Key of a labelled diagram drawn by the app. Diagrams are painted rather
  /// than shipped as pictures so that every dimension shown is one the code
  /// put there — see the guide diagram library.
  final String? diagram;

  /// Id of a calculator this card's reader is likely to want next.
  ///
  /// The seventeen calculators have always lived behind one door of their own,
  /// which is fine for somebody who knows what they are looking for and no use
  /// at all to a reader who has just been told how many bricks a stack should
  /// hold. A card naming a calculator puts the tool at the moment of the
  /// question. The door stays: this is a second way in, not a replacement.
  ///
  /// Must match a [CalcSpec] id; a test holds the two lists together, the same
  /// way diagram keys are held.
  final String? calc;

  /// The weakest status among this card's citations.
  ///
  /// A card is only as checked as its least checked number, so one unverified
  /// citation badges the whole card. A rule of thumb outranks review here: it
  /// needs the blunter warning.
  ReviewStatus get status {
    if (citations.any((c) => c.status == ReviewStatus.ruleOfThumb)) {
      return ReviewStatus.ruleOfThumb;
    }
    if (citations.any((c) => c.status == ReviewStatus.review)) {
      return ReviewStatus.review;
    }
    return ReviewStatus.verified;
  }

  factory GuideCard.fromJson(Map<String, dynamic> j) => GuideCard(
        id: j['id'] as String,
        title: L10nText.fromJson(j['title']),
        body: L10nText.fromJson(j['body']),
        tier: CardTier.parse(j['tier'] as String?),
        watchFor: L10nText.listFromJson(j['watch_for']),
        citations: (j['citations'] as List?)
                ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        audioAsset: j['audio'] as String?,
        imageAsset: j['image'] as String?,
        diagram: j['diagram'] as String?,
        calc: j['calc'] as String?,
      );
}

/// One module of the guide.
class GuideModule {
  const GuideModule({
    required this.id,
    required this.code,
    required this.title,
    required this.summary,
    required this.track,
    required this.cards,
    this.iconName,
  });

  final String id;

  /// 'M1'..'M10' — stable across translations.
  final String code;

  final L10nText title;
  final L10nText summary;
  final Track track;
  final List<GuideCard> cards;
  final String? iconName;

  /// A module written for the engineer's reference tier.
  ///
  /// Derived from the cards rather than declared, so a module cannot claim to
  /// be general reading while carrying detailing tables, or the reverse. The
  /// guide list shows everything this is false for; the reference section shows
  /// everything it is true for, and nothing appears in both.
  bool get isReference =>
      cards.isNotEmpty && cards.every((c) => c.tier == CardTier.reference);

  factory GuideModule.fromJson(Map<String, dynamic> j) => GuideModule(
        id: j['id'] as String,
        code: j['code'] as String,
        title: L10nText.fromJson(j['title']),
        summary: L10nText.fromJson(j['summary']),
        track: Track.parse(j['track'] as String?),
        iconName: j['icon'] as String?,
        cards: (j['cards'] as List)
            .map((e) => GuideCard.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// The whole guide, as bundled with a given app version.
class GuidePack {
  const GuidePack({
    required this.contentVersion,
    required this.updated,
    required this.modules,
  });

  final int contentVersion;

  /// Shown as "হালনাগাদ: …" so stale content is visible rather than silent.
  final String updated;

  final List<GuideModule> modules;

  factory GuidePack.fromJson(Map<String, dynamic> j) => GuidePack(
        contentVersion: j['content_version'] as int,
        updated: j['updated'] as String,
        modules: (j['modules'] as List)
            .map((e) => GuideModule.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Built from an index plus one file per module.
  ///
  /// The guide is split across files because a single pack crossed the size at
  /// which the bundle decodes on a worker isolate, which is invisible on a
  /// device and hangs a widget test. Per-module files also mean a card can be
  /// edited without rewriting a hundred kilobytes of JSON.
  factory GuidePack.assembled({
    required Map<String, dynamic> index,
    required List<Map<String, dynamic>> modules,
  }) =>
      GuidePack(
        contentVersion: index['content_version'] as int,
        updated: index['updated'] as String,
        modules: modules.map(GuideModule.fromJson).toList(),
      );

  /// Every card in every module, in reading order.
  Iterable<GuideCard> get cards =>
      modules.expand((m) => m.cards);

  List<GuideModule> forTier(CardTier tier) => [
        for (final m in modules)
          if (m.cards.any((c) => c.tier == tier)) m,
      ];

  List<GuideModule> forTrack(Track t) => modules
      .where((m) => m.track.covers(t) && !m.isReference)
      .toList();

  /// The engineer's reference tier, reached from its own entry and never from
  /// the guide list.
  List<GuideModule> get reference =>
      modules.where((m) => m.isReference).toList();

  GuideModule? moduleById(String id) {
    for (final m in modules) {
      if (m.id == id) return m;
    }
    return null;
  }
}
