import '../../../core/i18n/app_locale.dart';

/// A region of the PWD schedule.
///
/// The schedule prices every item four times, once per region. Comparing a
/// Rangpur BoQ against the Dhaka column is a real way to reach a wrong answer,
/// so the region is chosen explicitly rather than defaulted quietly.
class SorRegion {
  const SorRegion({required this.id, required this.name});

  final String id;
  final L10nText name;

  factory SorRegion.fromJson(Map<String, dynamic> j) => SorRegion(
        id: j['id'] as String,
        name: L10nText(j['bn'] as String, j['en'] as String?),
      );
}

/// One priced line of the schedule, as published.
class PwdRateItem {
  const PwdRateItem({
    required this.code,
    required this.chapter,
    required this.chapterName,
    required this.description,
    required this.unit,
    required this.rates,
  });

  /// Item number as printed, e.g. '07.1.3'.
  final String code;

  final int chapter;
  final L10nText chapterName;

  /// English as published — the schedule itself is written in English.
  final String description;

  final L10nText unit;

  /// One rate per region, in the same order as [PwdRateTable.regions].
  final List<double> rates;

  double rateFor(int regionIndex) =>
      rates[regionIndex.clamp(0, rates.length - 1)];

  /// Whether this item answers [query].
  ///
  /// The item code matches on a plain substring, because people type a partial
  /// number like "07.1". The description matches on **word boundaries**: a bare
  /// substring search returns "damp proof course" for "roof", which is the sort
  /// of near-miss that wastes a person's time at a site and makes the search
  /// look broken.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (code.toLowerCase().contains(q)) return true;

    final haystack = description.toLowerCase();
    final terms = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (terms.isEmpty) return false;
    // Every term must appear, so "roof slab" narrows rather than widens.
    return terms.every((term) => _containsWord(haystack, term));
  }

  /// True when [term] appears in [haystack] at the start of a word.
  ///
  /// Only the start is anchored. Anchoring the end too would stop "plaster"
  /// finding "plastering", and the schedule's wording varies far too much for
  /// that to be safe.
  static bool _containsWord(String haystack, String term) {
    var from = 0;
    while (from <= haystack.length - term.length) {
      final at = haystack.indexOf(term, from);
      if (at < 0) return false;
      final startsWord = at == 0 || !_isWordChar(haystack.codeUnitAt(at - 1));
      if (startsWord) return true;
      from = at + 1;
    }
    return false;
  }

  static bool _isWordChar(int c) =>
      (c >= 0x61 && c <= 0x7A) || (c >= 0x41 && c <= 0x5A) ||
      (c >= 0x30 && c <= 0x39);

  factory PwdRateItem.fromJson(Map<String, dynamic> j) => PwdRateItem(
        code: j['code'] as String,
        chapter: j['ch'] as int,
        chapterName: L10nText(j['ch_bn'] as String, j['ch_en'] as String?),
        description: j['desc'] as String,
        unit: L10nText(j['unit_bn'] as String, j['unit'] as String),
        rates: (j['rates'] as List).map((e) => (e as num).toDouble()).toList(),
      );
}

/// The published schedule, extracted from the official PDF.
///
/// The schedule is only ever published as a PDF, so the rates here were parsed
/// out of it and are pinned to the edition named in [schedule]. That edition is
/// shown wherever a rate is, because a rate quoted from the wrong revision is
/// worse than no rate.
class PwdRateTable {
  const PwdRateTable({
    required this.schedule,
    required this.effective,
    required this.sourceUrl,
    required this.extracted,
    required this.regions,
    required this.items,
    required this.profitPercent,
    required this.overheadPercent,
    required this.vatPercent,
  });

  final L10nText schedule;

  /// Date the edition takes effect, as printed on it.
  final String effective;

  final String sourceUrl;

  /// When these rates were parsed out of the PDF.
  final String extracted;

  final List<SorRegion> regions;
  final List<PwdRateItem> items;

  /// Built into every rate in the schedule.
  final double profitPercent;
  final double overheadPercent;
  final double vatPercent;

  factory PwdRateTable.fromJson(Map<String, dynamic> j) => PwdRateTable(
        schedule: L10nText(
          (j['schedule'] as Map)['bn'] as String,
          (j['schedule'] as Map)['en'] as String?,
        ),
        effective: j['effective'] as String,
        sourceUrl: j['source_url'] as String,
        extracted: j['extracted'] as String,
        profitPercent:
            ((j['markups'] as Map)['profit_percent'] as num).toDouble(),
        overheadPercent:
            ((j['markups'] as Map)['overhead_percent'] as num).toDouble(),
        vatPercent: ((j['markups'] as Map)['vat_percent'] as num).toDouble(),
        regions: (j['regions'] as List)
            .map((e) => SorRegion.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        items: (j['items'] as List)
            .map((e) => PwdRateItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  PwdRateItem? byCode(String code) {
    for (final i in items) {
      if (i.code == code) return i;
    }
    return null;
  }

  List<PwdRateItem> search(String query, {int limit = 40}) {
    if (query.trim().isEmpty) return items.take(limit).toList();
    final out = <PwdRateItem>[];
    for (final i in items) {
      if (i.matches(query)) {
        out.add(i);
        if (out.length >= limit) break;
      }
    }
    return out;
  }

  List<int> get chapters =>
      items.map((i) => i.chapter).toSet().toList()..sort();
}
