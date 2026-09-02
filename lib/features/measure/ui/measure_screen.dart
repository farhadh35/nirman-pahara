import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/util/bn.dart';
import '../../calculators/logic/calc_result.dart';
import '../../calculators/ui/calculator_screen.dart';
import '../logic/geometry.dart';
import '../logic/land_units.dart';
import '../logic/sutas.dart';

/// Measuring tools: land area, rod size and shape geometry.
///
/// These are conversion and geometry, not material calculators — a katha is
/// not a bag of cement — which is why they live on their own tabs instead of
/// in the calculator list.
class MeasureScreen extends StatelessWidget {
  const MeasureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t(
              const L10nText('মাপজোক', 'Measuring tools'))),
          bottom: TabBar(
            tabs: [
              Tab(text: context.t(const L10nText('জমির একক', 'Land units'))),
              Tab(text: context.t(const L10nText('সুতা', 'Suta'))),
              Tab(text: context.t(const L10nText('জ্যামিতি', 'Geometry'))),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_LandUnitsTab(), _SutaTab(), _GeometryTab()],
        ),
      ),
    );
  }
}

/// Text field shared by all three tabs: Bangla digits typed in, live update,
/// no submit button.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.helper,
  });

  final TextEditingController controller;
  final L10nText label;
  final L10nText? helper;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\s]')),
      ],
      decoration: InputDecoration(
        labelText: context.t(label),
        helperText: helper == null ? null : context.t(helper!),
        helperMaxLines: 3,
      ),
    );
  }
}

/// ---------------------------------------------------------------- জমির একক

class _LandUnitsTab extends StatefulWidget {
  const _LandUnitsTab();

  @override
  State<_LandUnitsTab> createState() => _LandUnitsTabState();
}

class _LandUnitsTabState extends State<_LandUnitsTab> {
  late final TextEditingController _controller;
  LandUnit _unit = LandUnit.decimal;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    // Seeded here, not initState: the box has to show the reader's own
    // digits, the same as the answer below it will.
    _controller = TextEditingController(
      text: Bn.localiseDigits('5', context.locale),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final value = Bn.parse(_controller.text) ?? 0.0;

    LandArea? area;
    String? error;
    try {
      area = LandArea.of(value, _unit);
    } on ArgumentError {
      error = locale.isBangla
          ? 'শূন্য বা তার বেশি একটি সংখ্যা দিন।'
          : 'Enter a number that is zero or more.';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        Text(
          locale.isBangla
              ? 'একটি এককে মাপ লিখুন, বাকি সব একক আর দলিলের হিসাব একসাথে '
                  'দেখুন।'
              : 'Type an area in one unit and see it in every other unit, '
                  'and the way a deed writes it, at the same time.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        _NumberField(
          controller: _controller,
          label: const L10nText('ক্ষেত্রফল', 'Area'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<LandUnit>(
          initialValue: _unit,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.t(const L10nText('একক', 'Unit')),
          ),
          items: [
            for (final u in LandUnit.values)
              DropdownMenuItem(value: u, child: Text(context.t(u.label))),
          ],
          onChanged: (u) => u == null ? null : setState(() => _unit = u),
        ),
        const SizedBox(height: 20),
        if (error != null)
          CautionBox(text: error)
        else if (area != null) ...[
          SectionCard(
            title: context.t(const L10nText('সব এককে', 'In every unit')),
            icon: Icons.swap_horiz,
            child: Column(
              children: [
                for (final u in LandUnit.values)
                  if (u != _unit)
                    ValueRow(
                      label: context.t(u.label),
                      value: Bn.number(area.asUnit(u),
                          decimals: 2, locale: locale),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.t(
                const L10nText('দলিলের হিসাবে', 'The way a deed writes it')),
            icon: Icons.description_outlined,
            child: Column(
              children: [
                ValueRow(
                  label: context.t(const L10nText('বিঘা', 'Bigha')),
                  value: Bn.number(area.breakdown.bigha.toDouble(),
                      decimals: 0, locale: locale),
                  emphasis: true,
                ),
                ValueRow(
                  label: context.t(const L10nText('কাঠা', 'Katha')),
                  value: Bn.number(area.breakdown.katha.toDouble(),
                      decimals: 0, locale: locale),
                  emphasis: true,
                ),
                ValueRow(
                  label: context.t(const L10nText(
                      'বাকি (বর্গফুট)', 'Remainder (square feet)')),
                  value: Bn.number(area.breakdown.squareFeet,
                      decimals: 2, locale: locale),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// -------------------------------------------------------------------- সুতা

class _SutaTab extends StatefulWidget {
  const _SutaTab();

  @override
  State<_SutaTab> createState() => _SutaTabState();
}

class _SutaTabState extends State<_SutaTab> {
  late final TextEditingController _controller;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    _controller = TextEditingController(
      text: Bn.localiseDigits('12', context.locale),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final mm = Bn.parse(_controller.text);
    final nearest =
        (mm != null && mm.isFinite && mm > 0) ? SutaSize.nearestToMm(mm) : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        Text(
          locale.isBangla
              ? 'রডের গায়ে মিলিমিটার লেখা থাকে, সাইটে সবাই সুতায় কথা বলে। '
                  'রড মেপে মিমি লিখুন, কত সুতা তা দেখুন।'
              : 'A rod is stamped in millimetres; the site talks in suta. '
                  'Type the millimetre size and see which suta it is.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        _NumberField(
          controller: _controller,
          label: const L10nText('রডের মাপ (মিমি)', 'Bar size (mm)'),
        ),
        const SizedBox(height: 20),
        if (nearest == null)
          CautionBox(
            text: locale.isBangla
                ? 'শূন্যের বড় একটি মাপ দিন।'
                : 'Enter a size greater than zero.',
          )
        else
          SectionCard(
            title: context.t(const L10nText('কাছাকাছি সুতা', 'Nearest suta')),
            icon: Icons.straighten,
            child: Column(
              children: [
                ValueRow(
                  label: Bn.localiseDigits(context.t(nearest.label), locale),
                  value: Bn.localiseDigits(nearest.inchLabel, locale),
                  emphasis: true,
                ),
                ValueRow(
                  label: context.t(
                      const L10nText('দোকানে বিক্রি হয়', 'Sold in shops as')),
                  value: '${Bn.number(nearest.nominalMm.toDouble(), decimals: 0, locale: locale)} '
                      '${locale.isBangla ? 'মিমি' : 'mm'}',
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        CautionBox(
          icon: Icons.info_outline,
          text: locale.isBangla
              ? 'ইঞ্চির ভগ্নাংশ আর দোকানের মিমি রড কখনো এক হয় না — যেমন ৩ সুতা '
                  'মানে ৩/৮ ইঞ্চি বা ৯.৫২৫ মিমি, কিন্তু কারখানা তা গোল করে ১০ মিমি '
                  'রড বানায়, নিচের তালিকায় সেই ফারাক দেখানো আছে।'
              : "The inch fraction and the mm bar the shop sells never quite "
                  'match — 3 suta is 3/8 inch, 9.525 mm exactly, but the mill '
                  'rounds it to a 10 mm bar. The table below shows that gap.',
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: context.t(const L10nText('সুতার তালিকা', 'Suta table')),
          icon: Icons.table_rows_outlined,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: [
                DataColumn(
                    label:
                        Text(context.t(const L10nText('সুতা', 'Suta')))),
                DataColumn(
                    label:
                        Text(context.t(const L10nText('ইঞ্চি', 'Inch')))),
                DataColumn(
                    label: Text(context
                        .t(const L10nText('মিমি (নমিনাল)', 'mm (nominal)')))),
                DataColumn(
                    label: Text(context
                        .t(const L10nText('ফারাক (মিমি)', 'Gap (mm)')))),
              ],
              rows: [
                for (final s in SutaSize.values)
                  DataRow(cells: [
                    DataCell(Text(Bn.localiseDigits('${s.suta}', locale))),
                    DataCell(Text(Bn.localiseDigits(s.inchLabel, locale))),
                    DataCell(Text(Bn.number(s.nominalMm.toDouble(),
                        decimals: 0, locale: locale))),
                    DataCell(Text(Bn.number(s.roundingMm,
                        decimals: 2, locale: locale))),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------- জ্যামিতি

class _GeometryTab extends StatefulWidget {
  const _GeometryTab();

  @override
  State<_GeometryTab> createState() => _GeometryTabState();
}

class _GeometryTabState extends State<_GeometryTab> {
  Shape _shape = Shape.rectangle;
  final List<TextEditingController> _controllers = [];
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    _buildControllers();
  }

  void _buildControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    final locale = context.locale;
    for (var i = 0; i < _shape.inputs.length; i++) {
      _controllers.add(TextEditingController(
        text: Bn.localiseDigits('10', locale),
      )..addListener(() => setState(() {})));
    }
  }

  void _onShapeChanged(Shape shape) {
    setState(() {
      _shape = shape;
      _buildControllers();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _takesDiameter =>
      _shape == Shape.circle ||
      _shape == Shape.cylinder ||
      _shape == Shape.cone ||
      _shape == Shape.sphere;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final dims = [for (final c in _controllers) Bn.parse(c.text) ?? 0.0];

    CalcResult? result;
    String? error;
    try {
      result = const Geometry().compute(_shape, dims);
    } on CalcException catch (e) {
      error = e.of(locale);
    }

    final inputs = _shape.inputs;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        Text(
          locale.isBangla
              ? 'কোন আকৃতি মাপবেন বেছে নিন, তারপর মাপগুলো লিখুন — বৃত্তাকার '
                  'জিনিসের জন্য সবচেয়ে চওড়া জায়গা (ব্যাস) মাপুন, কেন্দ্র থেকে নয়।'
              : "Pick the shape, then type its measurements. For anything "
                  'round, measure across the widest part — the diameter, not '
                  'the radius.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<Shape>(
          initialValue: _shape,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.t(const L10nText('আকৃতি', 'Shape')),
          ),
          items: [
            for (final s in Shape.values)
              DropdownMenuItem(value: s, child: Text(context.t(s.label))),
          ],
          onChanged: (s) => s == null ? null : _onShapeChanged(s),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _controllers.length && i < inputs.length; i++) ...[
          _NumberField(
            controller: _controllers[i],
            label: inputs[i],
            helper: (_takesDiameter && i == 0)
                ? const L10nText(
                    'ব্যাস — সবচেয়ে চওড়া জায়গা, কেন্দ্র থেকে নয়',
                    'Diameter — the widest point, not from the centre',
                  )
                : null,
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        if (error != null)
          CautionBox(text: error)
        else if (result != null)
          CalcResultView(result: result),
      ],
    );
  }
}
