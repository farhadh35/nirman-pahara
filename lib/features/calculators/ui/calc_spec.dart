import '../../../core/i18n/app_locale.dart';
import '../../../core/util/bn.dart';
import '../logic/calc_result.dart';
import '../logic/brickwork.dart';
import '../logic/concrete.dart';
import '../logic/mix_ratio.dart';
import '../logic/plaster.dart';
import '../logic/rebar.dart';
import '../logic/road_layer.dart';
import '../logic/unit_cost.dart';
import '../logic/units.dart';

/// One input on a calculator form.
class CalcField {
  const CalcField({
    required this.key,
    required this.label,
    this.hint,
    this.suffix,
    this.initial,
    this.choices,
    this.optional = false,
    this.money = false,
  });

  final String key;
  final L10nText label;
  final L10nText? hint;
  final L10nText? suffix;
  final String? initial;

  /// When present the field is a dropdown rather than a number box; the map is
  /// value -> label.
  final Map<String, L10nText>? choices;

  final bool optional;

  /// Taka amounts are grouped as the user types — a seven-digit contract value
  /// is unreadable otherwise.
  final bool money;

  bool get isChoice => choices != null;
}

/// A calculator, described declaratively so that one screen can render them
/// all. Adding a calculator means adding a spec, not a screen.
class CalcSpec {
  const CalcSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.run,
  });

  final String id;
  final L10nText title;
  final L10nText subtitle;
  final List<CalcField> fields;

  /// Values arrive parsed: numbers as doubles, choices as their string key.
  final CalcResult Function(Map<String, dynamic> values) run;

  static double _num(Map<String, dynamic> v, String key, [double fallback = 0]) {
    final raw = v[key];
    if (raw is double) return raw;
    if (raw is num) return raw.toDouble();
    return fallback;
  }

  static String _str(Map<String, dynamic> v, String key, String fallback) {
    final raw = v[key];
    return raw is String && raw.isNotEmpty ? raw : fallback;
  }

  // Ratio keys stay in western digits — they are parsed, not read. The Bangla
  // label is what the user sees.
  static final Map<String, L10nText> _concreteRatios = {
    for (final r in MixRatio.commonConcrete)
      r.label: L10nText(Bn.digits(r.label), r.label)
  };

  static final Map<String, L10nText> _mortarRatios = {
    for (final r in MixRatio.commonMortar)
      r.label: L10nText(Bn.digits(r.label), r.label)
  };

  static final List<CalcSpec> all = [
    CalcSpec(
      id: 'rebar',
      title: const L10nText('রডের ওজন', 'Rod weight'),
      subtitle: const L10nText(
        'কত রড এলো, ওজনে ঠিক আছে কি না',
        'How much steel arrived, and whether the weight adds up',
      ),
      fields: [
        CalcField(
          key: 'diameter',
          label: const L10nText('রডের ব্যাস', 'Bar diameter'),
          suffix: const L10nText('মিমি', 'mm'),
          initial: '16',
          choices: {
            for (final d in RebarCalculator.commonDiametersMm)
              '$d': L10nText('${Bn.digits('$d')} মিমি', '$d mm')
          },
        ),
        const CalcField(
          key: 'length',
          label: L10nText('প্রতিটি রডের দৈর্ঘ্য', 'Length of each bar'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '40',
        ),
        const CalcField(
          key: 'pieces',
          label: L10nText('কয়টি রড', 'Number of bars'),
          initial: '1',
        ),
      ],
      run: (v) => const RebarCalculator().compute(
        diameterMm: double.parse(_str(v, 'diameter', '16')),
        length: _num(v, 'length'),
        pieces: _num(v, 'pieces', 1).round(),
      ),
    ),
    CalcSpec(
      id: 'concrete',
      title: const L10nText('ঢালাইয়ের মালামাল', 'Concrete materials'),
      subtitle: const L10nText(
        'কত সিমেন্ট, বালি ও খোয়া লাগার কথা',
        'How much cement, sand and khoa the pour needs',
      ),
      fields: [
        const CalcField(
          key: 'volume',
          label: L10nText('ঢালাইয়ের আয়তন', 'Volume of concrete'),
          suffix: L10nText('ঘনফুট', 'cft'),
          hint: L10nText(
            'ছাদ হলে: দৈর্ঘ্য × প্রস্থ × পুরুত্ব (ফুটে)',
            'For a slab: length × width × thickness, in feet',
          ),
          initial: '100',
        ),
        CalcField(
          key: 'ratio',
          label: const L10nText('অনুপাত', 'Mix ratio'),
          initial: '1:2:4',
          choices: _concreteRatios,
        ),
      ],
      run: (v) => const ConcreteCalculator().compute(
        volume: _num(v, 'volume'),
        ratio: MixRatio.parse(_str(v, 'ratio', '1:2:4')),
      ),
    ),
    CalcSpec(
      id: 'brickwork',
      title: const L10nText('ইটের গাঁথুনি', 'Brickwork'),
      subtitle: const L10nText(
        'কত ইট আর কত মসলা লাগার কথা',
        'How many bricks and how much mortar the wall needs',
      ),
      fields: [
        const CalcField(
          key: 'length',
          label: L10nText('দেয়ালের দৈর্ঘ্য', 'Wall length'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '10',
        ),
        const CalcField(
          key: 'height',
          label: L10nText('দেয়ালের উচ্চতা', 'Wall height'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '10',
        ),
        CalcField(
          key: 'thickness',
          label: const L10nText('দেয়ালের পুরুত্ব', 'Wall thickness'),
          initial: '5',
          choices: const {
            '5': L10nText('৫ ইঞ্চি (আধা ইট)', '5 inch (half brick)'),
            '10': L10nText('১০ ইঞ্চি (এক ইট)', '10 inch (full brick)'),
          },
        ),
        const CalcField(
          key: 'openings',
          label: L10nText('দরজা-জানালা বাদ', 'Deduct openings'),
          suffix: L10nText('বর্গফুট', 'sft'),
          initial: '0',
          optional: true,
        ),
        CalcField(
          key: 'mortar',
          label: const L10nText('মসলার অনুপাত', 'Mortar ratio'),
          initial: '1:6',
          choices: _mortarRatios,
        ),
      ],
      run: (v) => const BrickworkCalculator().compute(
        lengthFt: _num(v, 'length'),
        heightFt: _num(v, 'height'),
        thicknessIn: double.parse(_str(v, 'thickness', '5')),
        openingsSft: _num(v, 'openings'),
        mortar: MixRatio.parse(_str(v, 'mortar', '1:6')),
      ),
    ),
    CalcSpec(
      id: 'plaster',
      title: const L10nText('প্লাস্টার', 'Plaster'),
      subtitle: const L10nText(
        'কত সিমেন্ট ও বালি লাগার কথা',
        'How much cement and sand the plaster needs',
      ),
      fields: [
        const CalcField(
          key: 'area',
          label: L10nText('ক্ষেত্রফল', 'Area'),
          suffix: L10nText('বর্গফুট', 'sft'),
          initial: '100',
        ),
        CalcField(
          key: 'thickness',
          label: const L10nText('পুরুত্ব', 'Thickness'),
          initial: '0.5',
          choices: const {
            '0.375': L10nText('৩/৮ ইঞ্চি (ছাদের নিচে)', '3/8 inch (ceiling)'),
            '0.5': L10nText('১/২ ইঞ্চি (ভেতরের দেয়াল)', '1/2 inch (inner wall)'),
            '0.75': L10nText('৩/৪ ইঞ্চি (বাইরের দেয়াল)', '3/4 inch (outer wall)'),
          },
        ),
        CalcField(
          key: 'mortar',
          label: const L10nText('অনুপাত', 'Ratio'),
          initial: '1:6',
          choices: _mortarRatios,
        ),
      ],
      run: (v) => const PlasterCalculator().compute(
        area: _num(v, 'area'),
        thicknessIn: double.parse(_str(v, 'thickness', '0.5')),
        mortar: MixRatio.parse(_str(v, 'mortar', '1:6')),
      ),
    ),
    CalcSpec(
      id: 'road',
      title: const L10nText('সড়কের স্তর', 'Road layers'),
      subtitle: const L10nText(
        'স্তর খোলা থাকতে মেপে নিন — পরে আর সুযোগ নেই',
        'Measure a layer while it is open — there is no second chance',
      ),
      fields: [
        const CalcField(
          key: 'length',
          label: L10nText('রাস্তার দৈর্ঘ্য', 'Road length'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '1000',
        ),
        const CalcField(
          key: 'width',
          label: L10nText('রাস্তার প্রস্থ', 'Road width'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '12',
        ),
        const CalcField(
          key: 'subbase',
          label: L10nText('সাব-বেজের পুরুত্ব', 'Sub-base thickness'),
          suffix: L10nText('মিমি', 'mm'),
          initial: '150',
        ),
        const CalcField(
          key: 'base',
          label: L10nText('বেজের পুরুত্ব', 'Base thickness'),
          suffix: L10nText('মিমি', 'mm'),
          initial: '150',
          optional: true,
        ),
      ],
      run: (v) => const RoadLayerCalculator().compute(
        length: _num(v, 'length'),
        width: _num(v, 'width'),
        layers: [
          RoadLayerSpec(
            name: const L10nText('সাব-বেজ', 'Sub-base'),
            thickness: _num(v, 'subbase'),
            thicknessUnit: LengthUnit.mm,
          ),
          if (_num(v, 'base') > 0)
            RoadLayerSpec(
              name: const L10nText('বেজ', 'Base'),
              thickness: _num(v, 'base'),
              thicknessUnit: LengthUnit.mm,
            ),
        ],
      ),
    ),
    CalcSpec(
      id: 'unit_cost',
      title: const L10nText('চুক্তি বনাম বাস্তব', 'Contract versus reality'),
      subtitle: const L10nText(
        'সাইনবোর্ডের টাকা ভাগ করে দেখুন প্রতি একক কত পড়ছে',
        'Divide the signboard figure and see what each unit costs',
      ),
      fields: [
        const CalcField(
          key: 'value',
          label: L10nText('চুক্তিমূল্য', 'Contract value'),
          suffix: L10nText('টাকা', 'Tk'),
          hint: L10nText('সাইনবোর্ডে লেখা থাকে', 'It is on the signboard'),
          initial: '4250000',
          money: true,
        ),
        const CalcField(
          key: 'quantity',
          label: L10nText('কাজের পরিমাণ', 'Work quantity'),
          hint: L10nText(
            'রাস্তা হলে মিটার, ভবন হলে বর্গফুট',
            'Metres for a road, square feet for a building',
          ),
          initial: '1200',
        ),
        CalcField(
          key: 'unit',
          label: const L10nText('একক', 'Unit'),
          initial: 'metre',
          choices: const {
            'metre': L10nText('মিটার', 'metre'),
            'km': L10nText('কিলোমিটার', 'km'),
            'sft': L10nText('বর্গফুট', 'sft'),
          },
        ),
        const CalcField(
          key: 'income_tax',
          label: L10nText('উৎসে আয়কর', 'Income tax at source'),
          suffix: L10nText('%', '%'),
          initial: '0',
          optional: true,
        ),
        const CalcField(
          key: 'comparison',
          label: L10nText('তুলনার রেট (জানা থাকলে)', 'Comparison rate, if known'),
          suffix: L10nText('টাকা', 'Tk'),
          hint: L10nText(
            'তফসিল রেট বা পাশের এলাকার কাজের রেট',
            'A schedule rate, or the rate on a nearby work',
          ),
          initial: '',
          optional: true,
          money: true,
        ),
      ],
      run: (v) {
        const units = {
          'metre': L10nText('মিটার', 'metre'),
          'km': L10nText('কিলোমিটার', 'km'),
          'sft': L10nText('বর্গফুট', 'sft'),
        };
        final comparison = _num(v, 'comparison');
        return const UnitCostCalculator().compute(
          contractValue: _num(v, 'value'),
          quantity: _num(v, 'quantity'),
          quantityUnit: units[_str(v, 'unit', 'metre')]!,
          incomeTaxPercent: _num(v, 'income_tax'),
          comparisonRate: comparison > 0 ? comparison : null,
        );
      },
    ),
  ];

  static CalcSpec? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
