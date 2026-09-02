import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/locale_fields.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/util/bn.dart';
import '../../calculators/logic/calc_result.dart';
import '../../calculators/ui/calculator_screen.dart';
import '../../measure/logic/land_units.dart';
import '../logic/far_calculator.dart';
import '../logic/far_rules.dart';

/// What the gazette allows on a plot, given the road in front of it.
///
/// Kept off the calculators page on purpose. Everything there is arithmetic a
/// reader can argue with a contractor about; this is a statutory table, and
/// being wrong here does not cost a few thousand taka of brick, it costs a
/// building. So it gets its own door, its own screen, and a refusal that says
/// "the gazette does not permit this" rather than quietly showing a zero.
class FarScreen extends StatelessWidget {
  const FarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.isBangla
            ? 'জমিতে কতটুকু করা যাবে'
            : 'What the plot allows'),
      ),
      body: ContentBuilder<FarPack>(
        future: context.content.far(),
        builder: (context, pack) => _FarForm(pack: pack),
      ),
    );
  }
}

class _FarForm extends StatefulWidget {
  const _FarForm({required this.pack});

  final FarPack pack;

  @override
  State<_FarForm> createState() => _FarFormState();
}

class _FarFormState extends State<_FarForm> {
  final _area = TextEditingController();
  final _road = TextEditingController();
  final _storeys = TextEditingController();

  LandUnit _areaUnit = LandUnit.katha;
  bool _roadInFeet = false;
  String _useCode = 'A1';
  String _zone = 'central';
  bool _seeded = false;
  AppLocale? _seededLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (!_seeded) {
      _seeded = true;
      // Seeded in the reader's own digits, like every other form in the app.
      _area.text = Bn.localiseDigits('3', locale);
      _road.text = Bn.localiseDigits('12', locale);
      for (final c in [_area, _road, _storeys]) {
        c.addListener(() => setState(() {}));
      }
    } else if (_seededLocale != locale) {
      followLocaleDigits([_area, _road, _storeys], locale);
    }
    _seededLocale = locale;
  }

  @override
  void dispose() {
    for (final c in [_area, _road, _storeys]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Uses that carry a zone split. Only housing does; everything else is one
  /// row for the whole city.
  bool get _isZoned =>
      widget.pack.uses.any((u) => u.code == _useCode && u.zone != null);

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);
    final bn = locale.isBangla;

    final areaValue = Bn.parse(_area.text) ?? 0;
    final roadValue = Bn.parse(_road.text) ?? 0;
    final roadM = _roadInFeet ? roadValue * 0.3048 : roadValue;
    final storeys = Bn.parse(_storeys.text)?.round();

    // Same rule as the calculators: an empty box is an unfinished question, not
    // a wrong answer, and it should not be answered with a refusal.
    final unfinished =
        _area.text.trim().isEmpty || _road.text.trim().isEmpty;

    CalcResult? result;
    String? error;
    if (!unfinished) {
      try {
        result = FarCalculator(pack: widget.pack).compute(
          plotAreaSft: _areaUnit.toSquareFeet(areaValue),
          roadWidthM: roadM,
          useCode: _useCode,
          zone: _isZoned ? _zone : null,
          storeys: storeys != null && storeys > 0 ? storeys : null,
        );
      } on CalcException catch (e) {
        error = e.of(locale);
      } catch (_) {
        error = bn ? 'ঘরগুলো পূরণ করুন।' : 'Fill in the fields.';
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      children: [
        Text(
          bn
              ? 'রাস্তা যত চওড়া, ইমারত তত বড় — গেজেট এই হিসাবটাই সারণিতে বেঁধে '
                  'দিয়েছে। আপনার জমির মাপ আর সামনের রাস্তার মাপ দিন।'
              : 'The wider the road, the more building the plot carries. The '
                  'gazette fixes that in one table. Give it your plot and the '
                  'road in front of it.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _number(
                context,
                _area,
                bn ? 'জমির পরিমাণ' : 'Plot size',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<LandUnit>(
                initialValue: _areaUnit,
                isExpanded: true,
                decoration: InputDecoration(labelText: bn ? 'একক' : 'Unit'),
                items: [
                  for (final u in const [
                    LandUnit.katha,
                    LandUnit.decimal,
                    LandUnit.bigha,
                    LandUnit.squareFoot,
                    LandUnit.squareMetre,
                  ])
                    DropdownMenuItem(value: u, child: Text(u.label.of(locale)))
                ],
                onChanged: (u) => setState(() => _areaUnit = u ?? _areaUnit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _number(
                context,
                _road,
                bn ? 'সামনের রাস্তার প্রশস্ততা' : 'Width of the road in front',
                hint: bn
                    ? 'নালা-ফুটপাত সহ, এক পাশের সীমানা থেকে অন্য পাশ পর্যন্ত'
                    : 'Boundary to boundary, drain and footpath included',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<bool>(
                initialValue: _roadInFeet,
                isExpanded: true,
                decoration: InputDecoration(labelText: bn ? 'একক' : 'Unit'),
                items: [
                  DropdownMenuItem(
                      value: false, child: Text(bn ? 'মিটার' : 'metre')),
                  DropdownMenuItem(
                      value: true, child: Text(bn ? 'ফুট' : 'feet')),
                ],
                onChanged: (v) => setState(() => _roadInFeet = v ?? false),
              ),
            ),
          ],
        ),
        if (_roadInFeet && roadValue > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              bn
                  ? '= ${Bn.number(roadM, decimals: 2, locale: locale)} মিটার'
                  : '= ${Bn.number(roadM, decimals: 2, locale: locale)} m',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _useCode,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: bn ? 'ইমারত কী কাজে লাগবে' : 'What the building is for',
          ),
          items: [
            for (final code in widget.pack.useCodes)
              DropdownMenuItem(
                value: code,
                child: Text(
                  '$code — ${_labelFor(code)}',
                  overflow: TextOverflow.ellipsis,
                ),
              )
          ],
          onChanged: (v) => setState(() => _useCode = v ?? _useCode),
        ),
        if (_isZoned) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _zone,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: bn ? 'জমি কোন এলাকায়' : 'Which area the plot is in',
            ),
            items: [
              for (final z in widget.pack.zones)
                DropdownMenuItem(
                  value: z.id,
                  child: Text(z.labelBn, overflow: TextOverflow.ellipsis),
                )
            ],
            onChanged: (v) => setState(() => _zone = v ?? _zone),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              bn
                  ? 'বাসাবাড়ির ক্ষেত্রে গেজেট এলাকা অনুযায়ী আলাদা FAR দেয়। '
                      'অন্য ব্যবহারে একই সারি পুরো শহরে খাটে।'
                  : 'For housing the gazette sets FAR by area. Every other use '
                      'has one row for the whole city.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _number(
          context,
          _storeys,
          bn ? 'কয় তলা ভাবছেন (ইচ্ছা হলে)' : 'How many storeys, if you like',
          hint: bn
              ? 'দিলে প্রতি তলায় গড়ে কত মেঝে পড়ে তা-ও দেখাবে'
              : 'Fill it in and it also shows the average floor plate',
        ),
        const SizedBox(height: 24),
        if (unfinished)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              bn
                  ? 'জমির মাপ আর রাস্তার মাপ দিলে হিসাব দেখা যাবে।'
                  : 'Fill in the plot size and the road width to see the '
                      'answer.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else if (error != null)
          CautionBox(text: error)
        else if (result != null)
          CalcResultView(result: result),
        const SizedBox(height: 20),
        SectionCard(
          title: bn ? 'এই সারণি কী বলে না' : 'What this table does not say',
          icon: Icons.gavel_outlined,
          child: Text(
            bn
                ? 'FAR শুধু বলে সব তলা মিলিয়ে কত মেঝে হতে পারে। কতটুকু জমিতে '
                    'ইমারত বসবে, চারপাশে কত জায়গা ছাড়তে হবে, কত উঁচু করা যাবে — '
                    'এগুলো আলাদা নিয়ম, আর সেগুলোও একই খাম ছোট করে। যেটি আগে বাধে '
                    'সেটিই চূড়ান্ত। নকশা করানোর আগে রাজউকে যাচাই করে নিন।'
                : 'FAR only caps the floor area added across every storey. How '
                    'much of the plot may be built on, how much has to be left '
                    'clear on each side, and how high it may go are separate '
                    'rules that cut the same envelope. Whichever bites first '
                    'governs. Check with RAJUK before paying for a design.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _labelFor(String code) {
    for (final u in widget.pack.uses) {
      if (u.code == code) return u.labelBn;
    }
    return code;
  }

  Widget _number(
    BuildContext context,
    TextEditingController controller,
    String label, {
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\s]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 3,
      ),
    );
  }
}
