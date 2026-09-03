import '../../../core/content/checklist_models.dart';
import 'photo_ref.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/util/bn.dart';

/// One answered checklist item.
class Finding {
  Finding({
    required this.item,
    this.answer,
    this.note = '',
    List<PhotoRef>? photos,
  }) : photos = photos ?? [];

  final ChecklistItem item;
  ItemAnswer? answer;
  String note;

  /// Photographs taken for this item, each with when and where it was taken.
  ///
  /// Referenced by file name rather than absolute path: Android hands an app a
  /// different sandbox path after some updates and restores, so a path saved
  /// today can be dead tomorrow. The directory is resolved at read time.
  final List<PhotoRef> photos;

  bool get hasPhotos => photos.isNotEmpty;

  Map<String, dynamic> toJson() => {
        if (answer != null) 'answer': answer!.name,
        if (note.trim().isNotEmpty) 'note': note,
        if (photos.isNotEmpty)
          'photos': [for (final p in photos) p.toJson()],
      };

  void applyJson(Map<String, dynamic> j, {required DateTime fallbackTakenAt}) {
    final name = j['answer'] as String?;
    answer = name == null
        ? null
        : ItemAnswer.values.where((a) => a.name == name).firstOrNull;
    note = (j['note'] as String?) ?? '';
    photos
      ..clear()
      ..addAll([
        for (final p in (j['photos'] as List?) ?? const [])
          PhotoRef.fromJson(p, fallbackTakenAt: fallbackTakenAt),
      ]);
  }

  bool get isProblem => answer == ItemAnswer.problem;
  bool get isUnsure => answer == ItemAnswer.unsure;
  bool get isAnswered => answer != null;
}

/// A walk through one checklist at one site.
///
/// Held in memory for now: the run produces a report the user copies out and
/// sends. Persisting runs, attaching photos and generating a PDF are the next
/// step and do not change this shape.
class InspectionRun {
  InspectionRun({
    required this.id,
    required this.pack,
    required this.projectName,
    this.tenderId = '',
    this.location = '',
    required this.date,
    DateTime? updatedAt,
  })  : updatedAt = updatedAt ?? date,
        findings = {
          for (final s in pack.stages)
            for (final i in s.items) i.id: Finding(item: i)
        };

  /// Stable across saves, so a run can be reopened on a later visit. Derived
  /// from the start time rather than a random source, which keeps the whole
  /// class deterministic and testable.
  final String id;

  final ChecklistPack pack;
  final String projectName;
  final String tenderId;
  final String location;

  /// When the inspection was started. Passed in rather than read from the
  /// clock, so a report can be regenerated identically and tests stay
  /// deterministic.
  final DateTime date;

  /// When it was last worked on.
  ///
  /// Someone checking curing walks the same slab on three successive days, so
  /// the start date alone cannot tell two runs apart. The list sorts and
  /// labels on this.
  DateTime updatedAt;

  final Map<String, Finding> findings;

  Iterable<Finding> get all => findings.values;
  Iterable<Finding> get withPhotos => all.where((f) => f.hasPhotos);
  int get photoCount => all.fold(0, (n, f) => n + f.photos.length);
  Iterable<Finding> get answered => all.where((f) => f.isAnswered);
  Iterable<Finding> get problems => all.where((f) => f.isProblem);
  Iterable<Finding> get unsure => all.where((f) => f.isUnsure);

  /// Findings that carry a photograph but appear in neither of the report's
  /// two named sections — an item marked fine, or not applicable, that somebody
  /// photographed anyway. The text report has always listed these under
  /// PHOTOGRAPHS; the printable one dropped them on the floor.
  Iterable<Finding> get otherWithPhotos =>
      all.where((f) => f.hasPhotos && !f.isProblem && !f.isUnsure);

  int get total => findings.length;
  double get progress => total == 0 ? 0 : answered.length / total;

  /// The report, written so that every problem reads as
  /// "the standard requires X; what was seen was Y" — never as an accusation.
  /// That phrasing is what makes a complaint checkable, and it is also what
  /// keeps the person filing it out of a defamation argument.
  /// [missingPhotos] names photographs whose file is no longer on disk. The
  /// share path already drops those from what it attaches, so a report that
  /// counted them said "৩টি সংযুক্ত" while two files went out — a number an
  /// office would check against the envelope. The caller resolves the files,
  /// because this runs inside a build and cannot touch the disk itself.
  String report(AppLocale locale, {Set<String> missingPhotos = const {}}) {
    final bn = locale.isBangla;
    final b = StringBuffer();
    String d(String s) => Bn.localiseDigits(s, locale);

    b.writeln(bn ? 'পরিদর্শন রিপোর্ট' : 'INSPECTION REPORT');
    b.writeln('=' * 40);
    b.writeln('${bn ? 'কাজ' : 'Work'}: $projectName');
    if (location.isNotEmpty) {
      b.writeln('${bn ? 'অবস্থান' : 'Location'}: $location');
    }
    if (tenderId.isNotEmpty) {
      // Not localised. A tender ID is typed back into the e-GP portal or
      // matched against a file by an official — "LGED-২০২৬-০১৪২" matches
      // nothing. Digits that are read become Bangla; digits that are re-entered
      // into a machine stay as they were given.
      b.writeln('${bn ? 'টেন্ডার আইডি' : 'Tender ID'}: $tenderId');
    }
    b.writeln('${bn ? 'ধরন' : 'Type'}: ${pack.title.of(locale)}');
    b.writeln('${bn ? 'তারিখ' : 'Date'}: '
        '${d('${date.year}-${_two(date.month)}-${_two(date.day)}')}');
    b.writeln();
    b.writeln(bn
        ? 'দেখা হয়েছে: ${Bn.digits('${answered.length}')} / '
            '${Bn.digits('$total')} · সমস্যা: ${Bn.digits('${problems.length}')}'
            '${photoCount == 0 ? '' : ' · ছবি: ${Bn.digits('$photoCount')}'}'
        : 'Checked: ${answered.length} / $total · '
            'Problems: ${problems.length}'
            '${photoCount == 0 ? '' : ' · Photographs: $photoCount'}');
    b.writeln();

    if (problems.isNotEmpty) {
      b.writeln(bn ? 'যেসব বিষয়ে সমস্যা দেখা গেছে' : 'WHERE A PROBLEM WAS SEEN');
      b.writeln('-' * 40);
      var n = 1;
      for (final f in problems) {
        b.writeln('${d('${n++}')}. ${f.item.question.of(locale)}');
        if (f.item.standard != null) {
          b.writeln('   ${bn ? 'নিয়মে যা থাকার কথা' : 'What the rule requires'}'
              ': ${f.item.standard!.of(locale)}');
        }
        b.writeln('   ${bn ? 'কেন জরুরি' : 'Why it matters'}'
            ': ${f.item.why.of(locale)}');
        if (f.note.trim().isNotEmpty) {
          b.writeln('   ${bn ? 'যা দেখা গেছে' : 'What was seen'}'
              ': ${f.note.trim()}');
        }
        if (f.hasPhotos) {
          final present =
              f.photos.where((p) => !missingPhotos.contains(p.name)).length;
          final lost = f.photos.length - present;
          // "২টি", not "২ টি": the classifier joins the numeral in Bangla.
          final attached =
              bn ? '${d('$present')}টি সংযুক্ত' : '$present attached';
          final lostNote = lost == 0
              ? ''
              : (bn
                  ? ', ${d('$lost')}টির ফাইল পাওয়া যায়নি'
                  : ', $lost could not be found');
          b.writeln('   ${bn ? 'ছবি' : 'Photographs'}: $attached$lostNote');
        }
        b.writeln();
      }
    }

    // Photographs get their own section rather than living only under
    // problems. The most useful photograph is often on an item the citizen
    // could not judge — that is precisely the one somebody else has to look
    // at, and burying it in a count made it invisible.
    if (withPhotos.isNotEmpty) {
      b.writeln(bn ? 'ছবি' : 'PHOTOGRAPHS');
      b.writeln('-' * 40);
      for (final f in withPhotos) {
        b.writeln('${f.item.question.of(locale)}'
            '${f.answer == null ? '' : ' — ${f.answer!.label.of(locale)}'}');
        for (final photo in f.photos) {
          final lost = missingPhotos.contains(photo.name);
          b.writeln('  - ${photo.describe(locale)}'
              '${lost ? (bn ? '  [ফাইল পাওয়া যায়নি]' : '  [file not found]') : ''}');
        }
      }
      b.writeln();
    }

    if (unsure.isNotEmpty) {
      b.writeln(bn ? 'যা বোঝা যায়নি' : 'COULD NOT TELL');
      b.writeln('-' * 40);
      for (final f in unsure) {
        b.writeln('• ${f.item.question.of(locale)}');
      }
      b.writeln();
    }

    b.writeln('-' * 40);
    b.writeln(bn
        ? 'এই রিপোর্ট একজন সাধারণ নাগরিকের চোখে দেখা বিবরণ। এটি কোনো '
            'প্রকৌশল পরীক্ষা বা আইনি সিদ্ধান্ত নয়। প্রতিটি বিষয়ে নিয়ম কী বলে আর '
            'কী দেখা গেছে — দুটোই আলাদা করে লেখা হয়েছে, যাতে কর্তৃপক্ষ নিজে '
            'যাচাই করতে পারে।'
        : 'This report records what an ordinary citizen observed. It is not an '
            'engineering test or a legal finding. For each point, what the rule '
            'requires and what was seen are stated separately, so that the '
            'authority can verify it themselves.');
    return b.toString();
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// Everything needed to rebuild this run against its checklist pack.
  ///
  /// The checklist itself is not stored — only the pack's id and the answers.
  /// A content update then reaches old runs too, and a run saved against an
  /// item that no longer exists simply drops that answer rather than breaking.
  Map<String, dynamic> toJson() => {
        'id': id,
        'pack': pack.id,
        'name': projectName,
        if (location.isNotEmpty) 'location': location,
        if (tenderId.isNotEmpty) 'tender_id': tenderId,
        'date': date.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'findings': {
          for (final e in findings.entries)
            if (e.value.isAnswered || e.value.note.trim().isNotEmpty)
              e.key: e.value.toJson(),
        },
      };

  /// Rebuilds a saved run. Returns null when the pack it referenced is gone.
  static InspectionRun? fromJson(
    Map<String, dynamic> j,
    List<ChecklistPack> packs,
  ) {
    final packId = j['pack'] as String?;
    final pack = packs.where((p) => p.id == packId).firstOrNull;
    if (pack == null) return null;

    final run = InspectionRun(
      id: j['id'] as String,
      pack: pack,
      projectName: j['name'] as String,
      location: (j['location'] as String?) ?? '',
      tenderId: (j['tender_id'] as String?) ?? '',
      date: DateTime.parse(j['date'] as String),
      updatedAt: j['updated_at'] == null
          ? DateTime.parse(j['date'] as String)
          : DateTime.parse(j['updated_at'] as String),
    );
    final saved = (j['findings'] as Map?)?.cast<String, dynamic>() ?? {};
    for (final e in saved.entries) {
      run.findings[e.key]?.applyJson(
        (e.value as Map).cast<String, dynamic>(),
        // Photographs saved before capture times were recorded fall back to
        // when the inspection started, which is the closest honest answer.
        fallbackTakenAt: run.date,
      );
    }
    return run;
  }

  /// Id for a run started at [startedAt]. Seconds are enough: a person cannot
  /// start two inspections in the same second.
  static String idFor(DateTime startedAt) =>
      'r${startedAt.toUtc().millisecondsSinceEpoch ~/ 1000}';
}
