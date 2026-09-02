import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';
import 'units.dart';

/// One pavement layer as specified on the drawing.
class RoadLayerSpec {
  const RoadLayerSpec({
    required this.name,
    required this.thickness,
    this.thicknessUnit = LengthUnit.mm,
    this.looseFactor = 1.25,
  });

  final L10nText name;
  final double thickness;
  final LengthUnit thicknessUnit;

  /// Loose (as-delivered) volume per unit of compacted volume. Sand, khoa and
  /// aggregate all shrink under the roller, which is what makes an honest truck
  /// count look short and a short one look honest.
  final double looseFactor;

  double get thicknessFt => thicknessUnit.toFeet(thickness);
}

/// Material volume for a road, layer by layer.
///
/// The point is not procurement. It is that a citizen can stand at an open
/// trench with a tape, measure the layer, and compare it with the thickness the
/// estimate was paid for.
class RoadLayerCalculator {
  const RoadLayerCalculator();

  CalcResult compute({
    required double length,
    required double width,
    LengthUnit lengthUnit = LengthUnit.foot,
    LengthUnit widthUnit = LengthUnit.foot,
    required List<RoadLayerSpec> layers,
  }) {
    if (!length.isFinite || !width.isFinite || length <= 0 || width <= 0) {
      throw CalcException(const L10nText(
        'রাস্তার দৈর্ঘ্য ও প্রস্থ শূন্যের বেশি হতে হবে।',
        'Road length and width must be greater than zero.',
      ));
    }
    if (layers.isEmpty) {
      throw CalcException(const L10nText(
        'কমপক্ষে একটি স্তর যোগ করুন।',
        'Add at least one layer.',
      ));
    }

    final lengthFt = lengthUnit.toFeet(length);
    final widthFt = widthUnit.toFeet(width);
    final areaSft = lengthFt * widthFt;

    final lines = <CalcLine>[
      CalcLine(
        key: 'area_sft',
        label: const L10nText('রাস্তার ক্ষেত্রফল', 'Road area'),
        value: areaSft,
        unit: U.sft,
        decimals: 0,
      ),
    ];

    var totalCompacted = 0.0;
    for (var i = 0; i < layers.length; i++) {
      final layer = layers[i];
      if (!layer.thickness.isFinite || layer.thickness <= 0) {
        throw CalcException(L10nText(
          '${layer.name.bn}: পুরুত্ব শূন্যের বেশি হতে হবে।',
          '${layer.name.en ?? layer.name.bn}: thickness must be greater than zero.',
        ));
      }
      final compacted = areaSft * layer.thicknessFt;
      totalCompacted += compacted;
      lines.add(CalcLine(
        key: 'layer_${i}_compacted_cft',
        label: L10nText(
          '${layer.name.bn} (দাবানোর পর)',
          '${layer.name.en ?? layer.name.bn} (compacted)',
        ),
        value: compacted,
        unit: U.cft,
        decimals: 0,
        emphasis: true,
      ));
      lines.add(CalcLine(
        key: 'layer_${i}_loose_cft',
        label: L10nText(
          '${layer.name.bn} (আলগা মাল)',
          '${layer.name.en ?? layer.name.bn} (loose)',
        ),
        value: compacted * layer.looseFactor,
        unit: U.cft,
        decimals: 0,
      ));
    }

    lines.add(CalcLine(
      key: 'total_compacted_cft',
      label: const L10nText('সব স্তর মিলে', 'All layers together'),
      value: totalCompacted,
      unit: U.cft,
      decimals: 0,
    ));

    return CalcResult(
      lines: lines,
      formula: const L10nText(
        'প্রতি স্তরের আয়তন = দৈর্ঘ্য × প্রস্থ × স্তরের পুরুত্ব\n'
            'আলগা মাল = দাবানো আয়তন × আলগা গুণক',
        'Layer volume = length × width × layer thickness\n'
            'Loose material = compacted volume × loose factor',
      ),
      assumptions: [
        L10nText(
          'দৈর্ঘ্য ${lengthFt.toStringAsFixed(1)} ফুট, প্রস্থ '
              '${widthFt.toStringAsFixed(1)} ফুট',
          'Length ${lengthFt.toStringAsFixed(1)} ft, width '
              '${widthFt.toStringAsFixed(1)} ft',
        ),
        for (final l in layers)
          L10nText(
            '${l.name.bn}: ${l.thickness} ${l.thicknessUnit.label.bn}, '
                'আলগা গুণক ${l.looseFactor}',
            '${l.name.en ?? l.name.bn}: ${l.thickness} '
                '${l.thicknessUnit.label.en}, loose factor ${l.looseFactor}',
          ),
      ],
      note: const L10nText(
        'স্তরের পুরুত্ব খোলা অবস্থায় মাপুন — ঢেকে গেলে আর মাপা যায় না। ডিজাইনে '
            'যে পুরুত্ব লেখা, সেটা দাবানোর পরের পুরুত্ব।',
        'Measure a layer while it is still open — once it is covered you cannot. '
            'The thickness on the drawing is the compacted thickness.',
      ),
    );
  }
}
