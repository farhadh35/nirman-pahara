import '../../../core/content/models.dart';
import '../../../core/i18n/app_locale.dart';

/// A market price, always carried as a band rather than a single figure.
///
/// Construction material prices in Bangladesh move week to week and differ by
/// brand, grade and district. A single number would be wrong the day after it
/// shipped, so the app ships a band with the date it was gathered, shows that
/// date, and lets the user type today's local price over it.
class MaterialPrice {
  const MaterialPrice({
    required this.id,
    required this.name,
    required this.unit,
    required this.lowBdt,
    required this.highBdt,
    required this.asOf,
    this.region,
    this.note,
    this.sources = const [],
    this.status = ReviewStatus.review,
  });

  final String id;
  final L10nText name;

  /// The unit the band is quoted in: bag, tonne, thousand, cft.
  final L10nText unit;

  final double lowBdt;
  final double highBdt;

  /// ISO date the band was gathered. Displayed with every figure.
  final String asOf;

  final L10nText? region;
  final L10nText? note;
  final List<Citation> sources;
  final ReviewStatus status;

  double get midBdt => (lowBdt + highBdt) / 2;

  factory MaterialPrice.fromJson(Map<String, dynamic> j) => MaterialPrice(
        id: j['id'] as String,
        name: L10nText.fromJson(j['name']),
        unit: L10nText.fromJson(j['unit']),
        lowBdt: (j['low_bdt'] as num).toDouble(),
        highBdt: (j['high_bdt'] as num).toDouble(),
        asOf: j['as_of'] as String,
        region: j['region'] == null ? null : L10nText.fromJson(j['region']),
        note: j['note'] == null ? null : L10nText.fromJson(j['note']),
        status: ReviewStatus.parse(j['status'] as String?),
        sources: (j['sources'] as List?)
                ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// A published construction cost figure for one country.
///
/// Used only for the "how does this compare elsewhere" screen. Every benchmark
/// must carry [comparability] — the reason two countries' figures may not mean
/// the same thing — because a bare multiple across borders is close to
/// meaningless and easy to misuse.
class CountryBenchmark {
  const CountryBenchmark({
    required this.id,
    required this.itemId,
    required this.country,
    required this.lowUsd,
    required this.highUsd,
    required this.unit,
    required this.year,
    required this.comparability,
    this.label,
    this.sources = const [],
    this.status = ReviewStatus.review,
  });

  final String id;

  /// Groups benchmarks that can be laid beside each other, e.g.
  /// 'highway_4lane_per_km'.
  final String itemId;

  final L10nText country;
  final double lowUsd;
  final double highUsd;

  /// e.g. 'per km of 4-lane highway'.
  final L10nText unit;

  /// The year the figure refers to, where it is known. Comparing across years
  /// without adjusting for inflation is one of the ways this screen can
  /// mislead, so the year is always shown — and when it is null the app says
  /// "year not confirmed" rather than quietly implying the figures are
  /// contemporaneous.
  final int? year;

  /// Why this figure may not be directly comparable.
  final L10nText comparability;

  /// Optional project name, where the figure is for a named project.
  final L10nText? label;

  final List<Citation> sources;
  final ReviewStatus status;

  double get midUsd => (lowUsd + highUsd) / 2;

  bool get isRange => lowUsd != highUsd;

  factory CountryBenchmark.fromJson(Map<String, dynamic> j) => CountryBenchmark(
        id: j['id'] as String,
        itemId: j['item_id'] as String,
        country: L10nText.fromJson(j['country']),
        lowUsd: (j['low_usd'] as num).toDouble(),
        highUsd: (j['high_usd'] as num).toDouble(),
        unit: L10nText.fromJson(j['unit']),
        year: j['year'] as int?,
        comparability: L10nText.fromJson(j['comparability']),
        label: j['label'] == null ? null : L10nText.fromJson(j['label']),
        status: ReviewStatus.parse(j['status'] as String?),
        sources: (j['sources'] as List?)
                ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// A group of benchmarks that can legitimately be shown on one chart.
class BenchmarkItem {
  const BenchmarkItem({
    required this.id,
    required this.title,
    required this.unit,
    required this.benchmarks,
  });

  final String id;
  final L10nText title;
  final L10nText unit;
  final List<CountryBenchmark> benchmarks;

  List<int> get years => benchmarks
      .map((b) => b.year)
      .whereType<int>()
      .toSet()
      .toList()
    ..sort();

  /// True when the figures being compared come from different years, which is
  /// the most common reason a comparison overstates a gap.
  bool get spansYears => years.length > 1;

  /// True when at least one figure has no confirmed year, so the comparison
  /// cannot be described as like-for-like in time.
  bool get hasUndatedFigures => benchmarks.any((b) => b.year == null);
}

/// Everything the price screens need, as bundled.
class PricePack {
  const PricePack({
    required this.contentVersion,
    required this.updated,
    required this.materials,
    required this.benchmarks,
    required this.seedUsdToBdt,
    required this.fxAsOf,
  });

  final int contentVersion;
  final String updated;
  final List<MaterialPrice> materials;
  final List<CountryBenchmark> benchmarks;

  /// Starting exchange rate for the cross-country screen. Always editable by
  /// the user: a stale rate silently distorts every multiple on the screen.
  final double seedUsdToBdt;
  final String fxAsOf;

  factory PricePack.fromJson(Map<String, dynamic> j) => PricePack(
        contentVersion: j['content_version'] as int,
        updated: j['updated'] as String,
        seedUsdToBdt: (j['seed_usd_to_bdt'] as num).toDouble(),
        fxAsOf: j['fx_as_of'] as String,
        materials: (j['materials'] as List)
            .map((e) => MaterialPrice.fromJson(e as Map<String, dynamic>))
            .toList(),
        benchmarks: (j['benchmarks'] as List)
            .map((e) => CountryBenchmark.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  MaterialPrice? materialById(String id) {
    for (final m in materials) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Groups the benchmarks by the item they measure.
  List<BenchmarkItem> get items {
    final byItem = <String, List<CountryBenchmark>>{};
    for (final b in benchmarks) {
      byItem.putIfAbsent(b.itemId, () => []).add(b);
    }
    return byItem.entries.map((e) {
      final first = e.value.first;
      return BenchmarkItem(
        id: e.key,
        title: first.unit,
        unit: first.unit,
        benchmarks: e.value..sort((a, b) => a.midUsd.compareTo(b.midUsd)),
      );
    }).toList();
  }

  BenchmarkItem? itemById(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }
}
