import '../i18n/app_locale.dart';

/// Which of the app's two tracks a piece of content belongs to.
enum Track {
  government('সরকারি কাজ', 'Government works'),
  private('নিজের বাড়ি', 'Your own house'),
  both('দুটোই', 'Both');

  const Track(this._bn, this._en);

  final String _bn;
  final String _en;

  L10nText get label => L10nText(_bn, _en);

  static Track parse(String? s) => switch (s) {
        'government' => Track.government,
        'private' => Track.private,
        _ => Track.both,
      };

  String get key => name;

  bool covers(Track selected) =>
      this == Track.both || selected == Track.both || this == selected;
}

/// Review state of a technical claim.
///
/// Nothing ships as [verified] until a licensed civil engineer has signed it
/// off against the cited source. Anything still in [review] carries a visible
/// badge, so the user is told what has and has not been checked.
/// See docs/CONTENT_REVIEW.md.
enum ReviewStatus {
  verified,
  review;

  static ReviewStatus parse(String? s) =>
      s == 'verified' ? ReviewStatus.verified : ReviewStatus.review;
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
class GuideCard {
  const GuideCard({
    required this.id,
    required this.title,
    required this.body,
    this.watchFor = const [],
    this.citations = const [],
    this.audioAsset,
    this.imageAsset,
    this.diagram,
  });

  final String id;
  final L10nText title;
  final L10nText body;

  /// "কী দেখবেন" — the concrete, checkable points.
  final List<L10nText> watchFor;

  final List<Citation> citations;
  final String? audioAsset;
  final String? imageAsset;

  /// Key of a labelled diagram drawn by the app. Diagrams are painted rather
  /// than shipped as pictures so that every dimension shown is one the code
  /// put there — see the guide diagram library.
  final String? diagram;

  ReviewStatus get status =>
      citations.any((c) => c.status == ReviewStatus.review)
          ? ReviewStatus.review
          : ReviewStatus.verified;

  factory GuideCard.fromJson(Map<String, dynamic> j) => GuideCard(
        id: j['id'] as String,
        title: L10nText.fromJson(j['title']),
        body: L10nText.fromJson(j['body']),
        watchFor: L10nText.listFromJson(j['watch_for']),
        citations: (j['citations'] as List?)
                ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        audioAsset: j['audio'] as String?,
        imageAsset: j['image'] as String?,
        diagram: j['diagram'] as String?,
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

  List<GuideModule> forTrack(Track t) =>
      modules.where((m) => m.track.covers(t)).toList();

  GuideModule? moduleById(String id) {
    for (final m in modules) {
      if (m.id == id) return m;
    }
    return null;
  }
}
