import '../../../core/i18n/app_locale.dart';
import '../../../core/util/bn.dart';
import '../logic/calc_result.dart';
import '../logic/brickwork.dart';
import '../logic/brick_stack.dart';
import '../logic/earthwork.dart';
import '../logic/hook_lap.dart';
import '../logic/paint.dart';
import '../logic/rod_delivery.dart';
import '../logic/shuttering.dart';
import '../logic/soling.dart';
import '../logic/stair.dart';
import '../logic/tiles.dart';
import '../logic/water_store.dart';
import '../logic/concrete.dart';
import '../logic/mix_ratio.dart';
import '../logic/plaster.dart';
import '../logic/rebar.dart';
import '../logic/road_layer.dart';
import '../logic/unit_cost.dart';
import '../logic/units.dart';

/// Which moment on a site a calculator belongs to.
///
/// Grouped by when a person reaches for it, not by what material it works on.
/// Someone opens this app because a truck has turned up or a pour is starting,
/// not because they were thinking about aggregate — so the delivery tools sit
/// together even though one counts bricks and the other weighs steel.
enum CalcGroup {
  delivery(
    L10nText('মালামাল বুঝে নিন', 'Checking a delivery'),
    L10nText(
      'গাড়ি খালি হওয়ার আগে যা গুনে নেওয়া যায়',
      'What can still be counted before the truck is empty',
    ),
  ),
  casting(
    L10nText('ঢালাইয়ের দিন', 'Casting day'),
    L10nText(
      'ঢালাই, রড, শাটারিং আর তার নিচের স্তর',
      'The pour, the steel, the formwork and the layer under it',
    ),
  ),
  finishing(
    L10nText('গাঁথুনি ও ফিনিশিং', 'Walls and finishing'),
    L10nText(
      'একই দেয়ালে গাঁথুনি থেকে রং পর্যন্ত',
      'One wall, from the brickwork to the paint',
    ),
  ),
  site(
    L10nText('মাটি ও রাস্তা', 'Earth and road'),
    L10nText(
      'যা খোঁড়া হয়, যা সরানো হয়, যা বিছানো হয়',
      'What gets dug, what gets carted, what gets laid',
    ),
  ),
  inside(
    L10nText('ঘরের ভিতর', 'Inside the house'),
    L10nText(
      'সিঁড়ি, পানির ট্যাংক, সেপটিক',
      'Stairs, water tanks, septic tanks',
    ),
  ),
  cost(
    L10nText('খরচ', 'Cost'),
    L10nText(
      'টাকার অঙ্ক ভেঙে প্রতি এককের হিসাব',
      'Breaking a contract figure down to the unit',
    ),
  );

  const CalcGroup(this.title, this.subtitle);

  final L10nText title;
  final L10nText subtitle;
}

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
    this.variesWith,
    this.labelWhen,
    this.hintWhen,
    this.suffixWhen,
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

  /// The key of a choice field this one follows.
  ///
  /// Some forms ask for the same box under different names. Shuttering is the
  /// case that forced this: the first measurement is a beam's width in inches,
  /// a slab's length in feet or a wall's length in feet, depending on what is
  /// being built. Labelling that box "Measurement 1" and explaining all three
  /// in a hint is how a form gets filled in wrong.
  final String? variesWith;

  final Map<String, L10nText>? labelWhen;
  final Map<String, L10nText>? hintWhen;
  final Map<String, L10nText>? suffixWhen;

  String? _driver(Map<String, dynamic> values) {
    if (variesWith == null) return null;
    final v = values[variesWith];
    return v is String ? v : null;
  }

  L10nText labelFor(Map<String, dynamic> values) =>
      labelWhen?[_driver(values)] ?? label;

  L10nText? hintFor(Map<String, dynamic> values) =>
      hintWhen?[_driver(values)] ?? hint;

  L10nText? suffixFor(Map<String, dynamic> values) =>
      suffixWhen?[_driver(values)] ?? suffix;

  bool get isChoice => choices != null;
}

/// A calculator, described declaratively so that one screen can render them
/// all. Adding a calculator means adding a spec, not a screen.
class CalcSpec {
  const CalcSpec({
    required this.id,
    required this.group,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.run,
  });

  final String id;
  final CalcGroup group;
  final L10nText title;
  final L10nText subtitle;
  final List<CalcField> fields;

  /// Values arrive parsed: numbers as doubles, choices as their string key.
  final CalcResult Function(Map<String, dynamic> values) run;

  static double _num(
    Map<String, dynamic> v,
    String key, [
    double fallback = 0,
  ]) {
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
      r.label: L10nText(Bn.digits(r.label), r.label),
  };

  static final Map<String, L10nText> _mortarRatios = {
    for (final r in MixRatio.commonMortar)
      r.label: L10nText(Bn.digits(r.label), r.label),
  };

  static final List<CalcSpec> all = [
    CalcSpec(
      id: 'rebar',
      group: CalcGroup.casting,
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
              '$d': L10nText('${Bn.digits('$d')} মিমি', '$d mm'),
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
      group: CalcGroup.casting,
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
      group: CalcGroup.finishing,
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
      group: CalcGroup.finishing,
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
            '0.5': L10nText(
              '১/২ ইঞ্চি (ভেতরের দেয়াল)',
              '1/2 inch (inner wall)',
            ),
            '0.75': L10nText(
              '৩/৪ ইঞ্চি (বাইরের দেয়াল)',
              '3/4 inch (outer wall)',
            ),
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
      group: CalcGroup.site,
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
      group: CalcGroup.cost,
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
          label: L10nText(
            'তুলনার রেট (জানা থাকলে)',
            'Comparison rate, if known',
          ),
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
    CalcSpec(
      id: 'brick_stack',
      group: CalcGroup.delivery,
      title: const L10nText('ইটের গাদা', 'Brick stack'),
      subtitle: const L10nText(
        'পুরো গাদা না গুনেই মেপে দেখুন সংখ্যায় কম পড়ছে কি না',
        'Measure the stack and see whether the count comes up short, without counting every brick',
      ),
      fields: [
        const CalcField(
          key: 'length',
          label: L10nText('গাদার দৈর্ঘ্য', 'Stack length'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '10',
        ),
        const CalcField(
          key: 'width',
          label: L10nText('গাদার প্রস্থ', 'Stack width'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '4',
        ),
        const CalcField(
          key: 'height',
          label: L10nText('গাদার উচ্চতা', 'Stack height'),
          suffix: L10nText('ফুট', 'ft'),
          hint: L10nText(
            'মাটি থেকে না, গাদার উপর পর্যন্ত মাপুন',
            'Measure from the ground to the top of the stack',
          ),
          initial: '5',
        ),
        const CalcField(
          key: 'gap',
          label: L10nText('গাদায় ফাঁক', 'Gap in the stack'),
          suffix: L10nText('%', '%'),
          hint: L10nText(
            'গাদা যত এলোমেলো, ফাঁক তত বেশি ধরুন',
            'The rougher the stack, the higher this should be',
          ),
          initial: '5',
          optional: true,
        ),
      ],
      run: (v) => const BrickStackCalculator().fromStack(
        lengthFt: _num(v, 'length'),
        widthFt: _num(v, 'width'),
        heightFt: _num(v, 'height'),
        gapPercent: _num(v, 'gap', 5),
      ),
    ),
    CalcSpec(
      id: 'brick_count',
      group: CalcGroup.delivery,
      title: const L10nText('ইট গোনা', 'Brick count'),
      subtitle: const L10nText(
        'একটা স্তর গুনে নিন, পুরো গাদা গোনার দরকার নেই',
        'Count one layer — there is no need to count the whole stack',
      ),
      fields: [
        const CalcField(
          key: 'along',
          label: L10nText('লম্বায় ইট', 'Bricks along the length'),
          hint: L10nText(
            'গাদার এক স্তরে লম্বা দিকে সারিবদ্ধ ইট গুনুন',
            'Count the bricks in one row along the long side of the stack',
          ),
          initial: '20',
        ),
        const CalcField(
          key: 'across',
          label: L10nText('চওড়ায় ইট', 'Bricks across the width'),
          hint: L10nText(
            'একই স্তরে চওড়া দিকে গুনুন',
            'Count across the same layer, the short side',
          ),
          initial: '8',
        ),
        const CalcField(
          key: 'layers',
          label: L10nText('মোট স্তর', 'Number of layers'),
          hint: L10nText(
            'নিচ থেকে ওপর পর্যন্ত কয়টি স্তর গোনা যায়',
            'How many layers stack from the ground up',
          ),
          initial: '25',
        ),
      ],
      run: (v) => const BrickStackCalculator().fromLayers(
        along: _num(v, 'along', 1).round(),
        across: _num(v, 'across', 1).round(),
        layers: _num(v, 'layers', 1).round(),
      ),
    ),
    CalcSpec(
      id: 'rod_delivery',
      group: CalcGroup.delivery,
      title: const L10nText('রড ডেলিভারি চেক', 'Rod delivery check'),
      subtitle: const L10nText(
        'টনে কেনা রড পিস হয়ে আসে — নামার আগেই গুনে ফেলুন',
        'Steel is bought by weight, delivered as bars — count it before it is unloaded',
      ),
      fields: [
        const CalcField(
          key: 'weight',
          label: L10nText('অর্ডার করা ওজন', 'Weight ordered'),
          suffix: L10nText('কেজি', 'kg'),
          hint: L10nText(
            'টনে কেনা হলে ১০০০ দিয়ে গুণ করুন',
            'If bought by the tonne, multiply by 1000',
          ),
          initial: '1000',
        ),
        CalcField(
          key: 'diameter',
          label: const L10nText('রডের ব্যাস', 'Bar diameter'),
          suffix: const L10nText('মিমি', 'mm'),
          initial: '16',
          choices: {
            for (final d in RebarCalculator.commonDiametersMm)
              '$d': L10nText('${Bn.digits('$d')} মিমি', '$d mm'),
          },
        ),
        CalcField(
          key: 'length',
          label: const L10nText('প্রতিটি রডের দৈর্ঘ্য', 'Length of each bar'),
          suffix: const L10nText('ফুট', 'ft'),
          hint: const L10nText(
            'গাড়িতে যা এসেছে তা মেপে দেখুন',
            'Measure what actually arrived on the truck',
          ),
          initial: '40',
          choices: const {
            '20': L10nText('২০ ফুট', '20 ft'),
            '40': L10nText('৪০ ফুট', '40 ft'),
          },
        ),
      ],
      run: (v) => const RodDeliveryCalculator().expectedBars(
        orderedKg: _num(v, 'weight'),
        diameterMm: double.parse(_str(v, 'diameter', '16')),
        stockLengthFt: double.parse(_str(v, 'length', '40')),
      ),
    ),
    CalcSpec(
      id: 'soling',
      group: CalcGroup.casting,
      title: const L10nText('ইটের সলিং', 'Brick soling'),
      subtitle: const L10nText(
        'ঢালাইয়ের আগেই গুনে নিন, পরে ইট আর দেখা যাবে না',
        'Count it before the pour — after that the bricks are gone from sight',
      ),
      fields: [
        const CalcField(
          key: 'area',
          label: L10nText('ক্ষেত্রফল', 'Area'),
          suffix: L10nText('বর্গফুট', 'sft'),
          initial: '500',
        ),
        CalcField(
          key: 'pattern',
          label: const L10nText('বিছানোর ধরন', 'Laying pattern'),
          initial: 'flat',
          choices: const {
            'flat': L10nText('ফ্ল্যাট সলিং', 'Flat soling'),
            'herringbone': L10nText('হেরিং বোন সলিং', 'Herringbone soling'),
          },
        ),
        const CalcField(
          key: 'wastage',
          label: L10nText('অপচয়', 'Wastage'),
          suffix: L10nText('%', '%'),
          initial: '5',
          optional: true,
        ),
      ],
      run: (v) => const SolingCalculator().compute(
        areaSft: _num(v, 'area'),
        herringbone: _str(v, 'pattern', 'flat') == 'herringbone',
        wastagePercent: _num(v, 'wastage', 5),
      ),
    ),
    CalcSpec(
      id: 'hook',
      group: CalcGroup.casting,
      title: const L10nText('হুকের দৈর্ঘ্য', 'Hook length'),
      subtitle: const L10nText(
        'রড বাঁকানোর আগে হুকের মাপ ফিতে দিয়ে মিলিয়ে নিন',
        'Check the hook length with a tape before the bar gets bent',
      ),
      fields: [
        CalcField(
          key: 'diameter',
          label: const L10nText('রডের ব্যাস', 'Bar diameter'),
          suffix: const L10nText('মিমি', 'mm'),
          initial: '12',
          choices: {
            for (final d in RebarCalculator.commonDiametersMm)
              '$d': L10nText('${Bn.digits('$d')} মিমি', '$d mm'),
          },
        ),
        const CalcField(
          key: 'count',
          label: L10nText('কয়টি হুক', 'Number of hooks'),
          initial: '4',
        ),
      ],
      run: (v) => const HookLapCalculator().hook(
        diameterMm: double.parse(_str(v, 'diameter', '12')),
        count: _num(v, 'count', 1).round(),
      ),
    ),
    CalcSpec(
      id: 'shuttering',
      group: CalcGroup.casting,
      title: const L10nText('শাটারিং', 'Shuttering'),
      subtitle: const L10nText(
        'কংক্রিট যে পাশে ঠেকে শুধু সেটাই বিলে ওঠে — ভুল পাশ ধরলে বাড়তি টাকা যায়',
        'Only the face the concrete touches goes in the bill; the wrong face '
            'costs you money',
      ),
      fields: [
        CalcField(
          key: 'element',
          label: const L10nText('কীসের শাটারিং', 'Shuttering for what'),
          initial: 'beam',
          choices: {for (final e in ShutterElement.values) e.name: e.label},
        ),
        // Each box renames itself with the element, because the same box is a
        // beam's width in inches and a slab's length in feet.
        const CalcField(
          key: 'a',
          label: L10nText('প্রথম মাপ', 'First measurement'),
          initial: '10',
          variesWith: 'element',
          labelWhen: {
            'beam': L10nText('বিমের চওড়া', 'Beam width'),
            'column': L10nText('কলামের এক বাহু', 'Column, one side'),
            'slab': L10nText('স্ল্যাবের দৈর্ঘ্য', 'Slab length'),
            'wall': L10nText('দেয়ালের দৈর্ঘ্য', 'Wall length'),
          },
          suffixWhen: {
            'beam': L10nText('ইঞ্চি', 'inch'),
            'column': L10nText('ইঞ্চি', 'inch'),
            'slab': L10nText('ফুট', 'ft'),
            'wall': L10nText('ফুট', 'ft'),
          },
        ),
        const CalcField(
          key: 'b',
          label: L10nText('দ্বিতীয় মাপ', 'Second measurement'),
          initial: '15',
          optional: true,
          variesWith: 'element',
          labelWhen: {
            'beam': L10nText('বিমের গভীরতা', 'Beam depth'),
            'column': L10nText('কলামের অন্য বাহু', 'Column, other side'),
            'slab': L10nText('স্ল্যাবের প্রস্থ', 'Slab width'),
            'wall': L10nText('দেয়ালে লাগে না', 'Not used for a wall'),
          },
          suffixWhen: {
            'beam': L10nText('ইঞ্চি', 'inch'),
            'column': L10nText('ইঞ্চি', 'inch'),
            'slab': L10nText('ফুট', 'ft'),
            'wall': L10nText('', ''),
          },
          hintWhen: {
            'wall': L10nText(
              'দেয়ালের হিসাবে এই ঘরটা লাগে না, খালি রাখলেও চলবে',
              'A wall does not use this box; leaving it empty is fine',
            ),
          },
        ),
        const CalcField(
          key: 'run',
          label: L10nText('দৈর্ঘ্য', 'Run'),
          initial: '20',
          variesWith: 'element',
          labelWhen: {
            'beam': L10nText('বিমের স্প্যান', 'Beam span'),
            'column': L10nText('কলামের উচ্চতা', 'Column height'),
            'slab': L10nText('স্ল্যাবের পুরুত্ব', 'Slab thickness'),
            'wall': L10nText('দেয়ালের উচ্চতা', 'Wall height'),
          },
          suffixWhen: {
            'beam': L10nText('ফুট', 'ft'),
            'column': L10nText('ফুট', 'ft'),
            'slab': L10nText('ইঞ্চি', 'inch'),
            'wall': L10nText('ফুট', 'ft'),
          },
        ),
        const CalcField(
          key: 'count',
          label: L10nText('কয়টি', 'How many'),
          initial: '1',
        ),
      ],
      run: (v) {
        final element = switch (_str(v, 'element', 'beam')) {
          'column' => ShutterElement.column,
          'slab' => ShutterElement.slab,
          'wall' => ShutterElement.wall,
          _ => ShutterElement.beam,
        };
        return const ShutteringCalculator().compute(
          element: element,
          a: _num(v, 'a'),
          b: element == ShutterElement.wall ? 1 : _num(v, 'b'),
          runFt: _num(v, 'run'),
          count: _num(v, 'count', 1).round(),
        );
      },
    ),
    CalcSpec(
      id: 'tiles',
      group: CalcGroup.finishing,
      title: const L10nText('টাইলস', 'Tiles'),
      subtitle: const L10nText(
        'কাটা টাইলস কোনায় পড়ে থাকে, কাজে লাগে না — বাক্স কেনার আগে হিসাব করুন',
        'A cut tile is left at the edge, not reused — work it out before you buy the boxes',
      ),
      fields: [
        const CalcField(
          key: 'area',
          label: L10nText('ঘরের ক্ষেত্রফল', 'Room area'),
          suffix: L10nText('বর্গফুট', 'sft'),
          initial: '120',
        ),
        CalcField(
          key: 'length',
          label: const L10nText('টাইলসের দৈর্ঘ্য', 'Tile length'),
          suffix: const L10nText('ইঞ্চি', 'in'),
          initial: '24',
          choices: const {
            '8': L10nText('৮ ইঞ্চি', '8 in'),
            '10': L10nText('১০ ইঞ্চি', '10 in'),
            '12': L10nText('১২ ইঞ্চি', '12 in'),
            '16': L10nText('১৬ ইঞ্চি', '16 in'),
            '18': L10nText('১৮ ইঞ্চি', '18 in'),
            '24': L10nText('২৪ ইঞ্চি', '24 in'),
            '32': L10nText('৩২ ইঞ্চি', '32 in'),
          },
        ),
        CalcField(
          key: 'width',
          label: const L10nText('টাইলসের প্রস্থ', 'Tile width'),
          suffix: const L10nText('ইঞ্চি', 'in'),
          initial: '24',
          choices: const {
            '8': L10nText('৮ ইঞ্চি', '8 in'),
            '10': L10nText('১০ ইঞ্চি', '10 in'),
            '12': L10nText('১২ ইঞ্চি', '12 in'),
            '16': L10nText('১৬ ইঞ্চি', '16 in'),
            '18': L10nText('১৮ ইঞ্চি', '18 in'),
            '24': L10nText('২৪ ইঞ্চি', '24 in'),
            '32': L10nText('৩২ ইঞ্চি', '32 in'),
          },
        ),
        const CalcField(
          key: 'wastage',
          label: L10nText('কাটার জন্য বাড়তি', 'Allowance for cutting'),
          suffix: L10nText('%', '%'),
          hint: L10nText(
            'ঘর যত ছোট আর কোনা যত বেশি, তত বেশি ধরুন',
            'The smaller the room and the more corners, the more you should allow',
          ),
          initial: '10',
        ),
        const CalcField(
          key: 'per_box',
          label: L10nText('প্রতি বাক্সে টাইলস', 'Tiles per box'),
          hint: L10nText('বাক্সের গায়ে লেখা থাকে', "It's printed on the box"),
          initial: '',
          optional: true,
        ),
      ],
      run: (v) {
        final perBox = _num(v, 'per_box');
        return const TileCalculator().compute(
          areaSft: _num(v, 'area'),
          tileLengthIn: double.parse(_str(v, 'length', '24')),
          tileWidthIn: double.parse(_str(v, 'width', '24')),
          wastagePercent: _num(v, 'wastage', 10),
          tilesPerBox: perBox > 0 ? perBox.round() : null,
        );
      },
    ),
    CalcSpec(
      id: 'paint',
      group: CalcGroup.finishing,
      title: const L10nText('রং', 'Paint'),
      subtitle: const L10nText(
        'কৌটার গায়ের কভারেজ বসান, কয় কৌটা কিনতে হবে বুঝে নিন',
        'Enter what the tin says, and know how many tins to buy',
      ),
      fields: [
        const CalcField(
          key: 'surface',
          label: L10nText('রং করার ক্ষেত্রফল', 'Area to be painted'),
          suffix: L10nText('বর্গফুট', 'sft'),
          hint: L10nText(
            'দেয়ালের দৈর্ঘ্য × উচ্চতা, প্রতিটি দেয়াল যোগ করে',
            'Length × height of each wall, added up',
          ),
          initial: '400',
        ),
        const CalcField(
          key: 'coverage',
          label: L10nText('কভারেজ', 'Coverage'),
          suffix: L10nText('বর্গফুট/লিটার', 'sft/litre'),
          hint: L10nText(
            'কৌটার গায়ে লেখা থাকে — ব্র্যান্ডভেদে অনেক আলাদা হয়, তাই এখানেই বসান',
            'It is printed on the tin — brands differ a lot, so use that figure',
          ),
          initial: '110',
        ),
        CalcField(
          key: 'coats',
          label: const L10nText('কোটের সংখ্যা', 'Number of coats'),
          initial: '2',
          choices: {
            '1': L10nText(Bn.digits('1'), '1'),
            '2': L10nText(Bn.digits('2'), '2'),
            '3': L10nText(Bn.digits('3'), '3'),
          },
        ),
        const CalcField(
          key: 'openings',
          label: L10nText('দরজা-জানালা বাদ', 'Deduct openings'),
          suffix: L10nText('বর্গফুট', 'sft'),
          initial: '0',
          optional: true,
        ),
        const CalcField(
          key: 'wastage',
          label: L10nText('অপচয়', 'Wastage'),
          suffix: L10nText('%', '%'),
          initial: '5',
          optional: true,
        ),
      ],
      run: (v) => const PaintCalculator().compute(
        surfaceSft: _num(v, 'surface'),
        coverageSftPerLitre: _num(v, 'coverage'),
        coats: int.parse(_str(v, 'coats', '2')),
        openingsSft: _num(v, 'openings'),
        wastagePercent: _num(v, 'wastage', 5.0),
      ),
    ),
    CalcSpec(
      id: 'earthwork',
      group: CalcGroup.site,
      title: const L10nText('মাটি খননের হিসাব', 'Earthwork'),
      subtitle: const L10nText(
        'গর্ত ভরাট হওয়ার আগে মাপুন — বিল আর ট্রাক এক মাপে গোনা হয় না',
        'Measure the pit before it is filled — the bill and the trucks are not counted the same way',
      ),
      fields: [
        const CalcField(
          key: 'length',
          label: L10nText('গর্তের দৈর্ঘ্য', 'Length of the pit'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '20',
        ),
        const CalcField(
          key: 'width',
          label: L10nText('গর্তের প্রস্থ', 'Width of the pit'),
          suffix: L10nText('ফুট', 'ft'),
          initial: '15',
        ),
        const CalcField(
          key: 'depth',
          label: L10nText('গর্তের গভীরতা', 'Depth of the pit'),
          suffix: L10nText('ফুট', 'ft'),
          hint: L10nText(
            'ঢালাই পড়ার আগে মেপে নিন, পরে আর সুযোগ নেই',
            'Measure before concrete goes in — there is no second chance',
          ),
          initial: '5',
        ),
        const CalcField(
          key: 'bulking',
          label: L10nText('মাটি ফোলার হার', 'Bulking (soil swell)'),
          hint: L10nText(
            'এটি কোনো নির্দিষ্ট মান নয়, ভেজা মাটিতে বদলে যায়',
            'This is not a fixed value — wet ground changes it a lot',
          ),
          initial: '25',
          choices: {
            '12.5': L10nText('বালু মাটি (১০–১৫%)', 'Sandy soil (10-15%)'),
            '25': L10nText('সাধারণ মাটি (২০–৩০%)', 'Common earth (20-30%)'),
            '35': L10nText('এঁটেল মাটি (৩০–৪০%)', 'Clay (30-40%)'),
          },
        ),
        const CalcField(
          key: 'truck',
          label: L10nText('গাড়ির ধারণক্ষমতা', 'Truck capacity'),
          suffix: L10nText('ঘনফুট', 'cft'),
          hint: L10nText(
            'জানা থাকলে দিন, তাহলে ট্রিপ সংখ্যা বের হবে',
            'Give it if you know it, to also get the number of trips',
          ),
          initial: '120',
          optional: true,
        ),
      ],
      run: (v) {
        final truck = _num(v, 'truck');
        return const EarthworkCalculator().compute(
          lengthFt: _num(v, 'length'),
          widthFt: _num(v, 'width'),
          depthFt: _num(v, 'depth'),
          bulkingPercent: double.parse(_str(v, 'bulking', '25')),
          truckCapacityCft: truck > 0 ? truck : null,
        );
      },
    ),
    CalcSpec(
      id: 'stair',
      group: CalcGroup.inside,
      title: const L10nText('সিঁড়ির মাপ', 'Stair dimensions'),
      subtitle: const L10nText(
        'ঢালাইয়ের আগেই ধাপ সংখ্যা বসান, নইলে প্রথম বা শেষ ধাপটা অসমান হয়ে যাবে',
        'Fix the riser count before the pour — leave it, and the first or last step comes out uneven',
      ),
      fields: [
        const CalcField(
          key: 'floor_height',
          label: L10nText('তলার উচ্চতা', 'Floor-to-floor height'),
          suffix: L10nText('ফুট', 'ft'),
          hint: L10nText(
            'এই মেঝে থেকে পরের মেঝে পর্যন্ত',
            'From this floor to the next one up',
          ),
          initial: '10',
        ),
        CalcField(
          key: 'tread',
          label: const L10nText('ট্রেডের গভীরতা', 'Tread depth'),
          suffix: const L10nText('ইঞ্চি', 'inch'),
          hint: const L10nText(
            'যে অংশে পা রাখবেন তার গভীরতা',
            'The depth of the part the foot lands on',
          ),
          initial: '10',
          choices: {
            '10': L10nText('${Bn.digits('10')} ইঞ্চি', '10 inch'),
            '10.5': L10nText('${Bn.digits('10.5')} ইঞ্চি', '10.5 inch'),
            '11': L10nText('${Bn.digits('11')} ইঞ্চি', '11 inch'),
            '12': L10nText('${Bn.digits('12')} ইঞ্চি', '12 inch'),
          },
        ),
      ],
      run: (v) => const StairCalculator().compute(
        floorHeightFt: _num(v, 'floor_height'),
        treadIn: double.parse(_str(v, 'tread', '10')),
      ),
    ),
    CalcSpec(
      id: 'water_store',
      group: CalcGroup.inside,
      title: const L10nText('পানির ট্যাংক', 'Water tank'),
      subtitle: const L10nText(
        'রাজমিস্ত্রির আন্দাজ নয়, মানুষ গুনে রিজার্ভার আর ছাদের ট্যাংকের মাপ ঠিক করুন',
        "Size the reservoir and roof tank by headcount, not the mason's guess",
      ),
      fields: [
        const CalcField(
          key: 'people',
          label: L10nText('বাড়িতে কতজন থাকেন', 'People living in the house'),
          suffix: L10nText('জন', 'people'),
          initial: '5',
        ),
        CalcField(
          key: 'gallons',
          label: const L10nText(
            'জনপ্রতি দিনে পানি',
            'Water per person per day',
          ),
          suffix: const L10nText('গ্যালন', 'gallons'),
          hint: const L10nText(
            'না জানলে খালি রাখুন, সবচেয়ে কম হিসাব বসে যাবে',
            'Leave blank if unsure — the floor figure is used',
          ),
          initial: '${WaterStoreCalculator.minGallonsPerPersonPerDay.round()}',
          optional: true,
        ),
      ],
      run: (v) {
        final gallons = _num(v, 'gallons');
        return const WaterStoreCalculator().compute(
          people: _num(v, 'people', 1).round(),
          gallonsPerPersonPerDay: gallons > 0
              ? gallons
              : WaterStoreCalculator.minGallonsPerPersonPerDay,
        );
      },
    ),
  ];

  /// Specs in one group, in registry order.
  static List<CalcSpec> inGroup(CalcGroup g) =>
      all.where((s) => s.group == g).toList();

  /// Groups that actually carry a calculator, in enum order. A group with
  /// nothing in it never renders as an empty heading.
  static List<CalcGroup> get groups =>
      CalcGroup.values.where((g) => inGroup(g).isNotEmpty).toList();

  static CalcSpec? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
