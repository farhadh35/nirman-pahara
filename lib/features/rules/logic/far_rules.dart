import '../../../core/i18n/app_locale.dart';

/// The road-width FAR table from the 2025 Dhaka building rules.
///
/// FAR — floor area ratio — is the multiplier that turns a plot into a floor
/// area budget. FAR 2.5 on a 3 katha plot means the total floor area of every
/// storey added together may reach 2.5 times the plot area. It is the single
/// number that decides how much building a plot is worth, which is why it is
/// the number a landowner is most often told wrongly.
///
/// The gazette sets it by the width of the road the plot sits on, the use the
/// building is put to, and — for housing only — which part of the city it is
/// in. This class holds that table and nothing more: it reports a ceiling, not
/// a permission. See [FarCalculator.compute] for what it deliberately does not
/// tell you.
class FarPack {
  const FarPack({
    required this.table,
    required this.sourceBn,
    required this.roadBands,
    required this.zones,
    required this.uses,
  });

  final String table;
  final String sourceBn;

  /// The nine road-width columns, in the gazette's order.
  final List<RoadBand> roadBands;

  /// The three residential zones. Every other use is city-wide.
  final List<FarZone> zones;

  final List<FarUse> uses;

  static FarPack fromJson(Map<String, dynamic> json) => FarPack(
        table: json['table'] as String,
        sourceBn: json['source_bn'] as String,
        roadBands: [
          for (final b in json['road_bands'] as List)
            RoadBand(
              fromM: (b['from_m'] as num).toDouble(),
              toM: (b['to_m'] as num?)?.toDouble(),
            ),
        ],
        zones: [
          for (final z in json['zones'] as List)
            FarZone(id: z['id'] as String, labelBn: z['label_bn'] as String),
        ],
        uses: [
          for (final u in json['uses'] as List)
            FarUse(
              code: u['code'] as String,
              zone: u['zone'] as String?,
              labelBn: u['label_bn'] as String,
              far: [
                for (final f in u['far'] as List) (f as num?)?.toDouble(),
              ],
              notRecommended: u['not_recommended'] as bool? ?? false,
            ),
        ],
      );

  /// The column a road of [widthM] metres falls in, or null if the table does
  /// not reach that far down. Below 1.8 m the gazette lists no FAR at all.
  int? bandIndex(double widthM) {
    if (!widthM.isFinite) return null;
    for (var i = 0; i < roadBands.length; i++) {
      final b = roadBands[i];
      if (widthM < b.fromM) continue;
      if (b.toM == null || widthM < b.toM!) return i;
    }
    return null;
  }

  FarUse? use(String code, {String? zone}) {
    for (final u in uses) {
      if (u.code == code && u.zone == zone) return u;
    }
    return null;
  }

  /// Use codes in the order the gazette lists them, deduplicated across zones.
  List<String> get useCodes {
    final seen = <String>[];
    for (final u in uses) {
      if (!seen.contains(u.code)) seen.add(u.code);
    }
    return seen;
  }

  bool get isZoned => zones.isNotEmpty;
}

class RoadBand {
  const RoadBand({required this.fromM, this.toM});

  final double fromM;

  /// Null on the last column, which is "24 metres or wider".
  final double? toM;

  L10nText get label => toM == null
      ? L10nText('${fmtMetres(fromM)} মিটার বা তার বেশি', '${fmtMetres(fromM)} m or wider')
      : L10nText('${fmtMetres(fromM)} থেকে ${fmtMetres(toM!)} মিটারের কম',
          '${fmtMetres(fromM)} m to under ${fmtMetres(toM!)} m');

  static String fmtMetres(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class FarZone {
  const FarZone({required this.id, required this.labelBn});

  final String id;
  final String labelBn;
}

class FarUse {
  const FarUse({
    required this.code,
    required this.zone,
    required this.labelBn,
    required this.far,
    required this.notRecommended,
  });

  final String code;

  /// Null for every use except housing, which the gazette splits three ways.
  final String? zone;

  final String labelBn;

  /// Nine entries, one per road band. Null means the gazette permits this use
  /// on no road that narrow — which is a refusal, not a zero.
  final List<double?> far;

  /// The gazette marks the widest-road figure "*NR" on some rows.
  final bool notRecommended;
}
