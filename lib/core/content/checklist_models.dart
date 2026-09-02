import '../i18n/app_locale.dart';
import 'models.dart';

/// What the user answered for one checklist item.
enum ItemAnswer {
  ok('ঠিক আছে', 'Looks right'),
  problem('সমস্যা আছে', 'There is a problem'),
  unsure('বুঝতে পারিনি', 'Could not tell'),
  notApplicable('প্রযোজ্য নয়', 'Not applicable');

  const ItemAnswer(this._bn, this._en);

  final String _bn;
  final String _en;

  L10nText get label => L10nText(_bn, _en);
}

/// One thing to look at, phrased so a non-engineer can answer it.
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.question,
    required this.why,
    this.how,
    this.standard,
    this.citations = const [],
    this.wantsPhoto = false,
  });

  final String id;

  /// The question, in the second person: 'ঢালাইয়ের পর পানি দেওয়া হচ্ছে?'
  final L10nText question;

  /// Why it matters, in one sentence.
  final L10nText why;

  /// How to check it without instruments, where that is possible.
  final L10nText? how;

  /// What the standard requires. Deliberately kept separate from the
  /// observation, so a report can always be phrased as "the standard says X,
  /// what was seen was Y" rather than as an accusation.
  final L10nText? standard;

  final List<Citation> citations;

  /// Whether to prompt for a photo when the answer is a problem.
  final bool wantsPhoto;

  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(
        id: j['id'] as String,
        question: L10nText.fromJson(j['question']),
        why: L10nText.fromJson(j['why']),
        how: j['how'] == null ? null : L10nText.fromJson(j['how']),
        standard:
            j['standard'] == null ? null : L10nText.fromJson(j['standard']),
        wantsPhoto: j['photo'] as bool? ?? false,
        citations: (j['citations'] as List?)
                ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// A stage of work. Most items can only be checked while the stage is open, so
/// [when] tells the user when to turn up.
class ChecklistStage {
  const ChecklistStage({
    required this.id,
    required this.title,
    required this.when,
    required this.items,
  });

  final String id;
  final L10nText title;

  /// 'রড বাঁধা শেষ, ঢালাই শুরুর আগে' …
  final L10nText when;

  final List<ChecklistItem> items;

  factory ChecklistStage.fromJson(Map<String, dynamic> j) => ChecklistStage(
        id: j['id'] as String,
        title: L10nText.fromJson(j['title']),
        when: L10nText.fromJson(j['when']),
        items: (j['items'] as List)
            .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A checklist for one kind of work (rural road, building, drain …).
class ChecklistPack {
  const ChecklistPack({
    required this.id,
    required this.title,
    required this.summary,
    required this.track,
    required this.stages,
    this.iconName,
  });

  final String id;
  final L10nText title;
  final L10nText summary;
  final Track track;
  final List<ChecklistStage> stages;
  final String? iconName;

  int get itemCount => stages.fold(0, (sum, s) => sum + s.items.length);

  factory ChecklistPack.fromJson(Map<String, dynamic> j) => ChecklistPack(
        id: j['id'] as String,
        title: L10nText.fromJson(j['title']),
        summary: L10nText.fromJson(j['summary']),
        track: Track.parse(j['track'] as String?),
        iconName: j['icon'] as String?,
        stages: (j['stages'] as List)
            .map((e) => ChecklistStage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
