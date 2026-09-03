import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/locale_fields.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/util/bn.dart';
import '../../../core/util/grouped_number_formatter.dart';
import '../logic/calc_result.dart';
import 'calc_spec.dart';

/// One screen that renders every calculator from its [CalcSpec].
///
/// The result appears under the form and updates as the user types — no
/// "Calculate" button, because on a site people change one number at a time and
/// watch what it does.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, required this.spec});

  final CalcSpec spec;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _choices = {};
  bool _seeded = false;
  AppLocale? _seededLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _seed();
    _followLocale();
  }

  /// Rewrites what is already in the boxes when the reader changes language.
  ///
  /// The seed runs once, so switching to English left "১০০" sitting in the area
  /// box while the result underneath it read "100 sft" — the same number in two
  /// scripts on one screen. Only the digits change; whatever the reader typed
  /// is kept.
  void _followLocale() {
    final locale = context.locale;
    if (_seededLocale == locale) return;
    _seededLocale = locale;
    for (final f in widget.spec.fields) {
      if (f.isChoice) continue;
      followLocaleDigits([_controllers[f.key]!], locale, grouped: f.money);
    }
  }

  void _seed() {
    if (_seeded) return;
    _seeded = true;
    // Seeded here rather than in initState because the starting values are
    // written in the reader's own digits: a Bangla-first app that prints
    // "৪০ ফুট" in the answer must not put "40" in the box above it.
    final locale = context.locale;
    _seededLocale = locale;
    for (final f in widget.spec.fields) {
      if (f.isChoice) {
        _choices[f.key] = f.initial ?? f.choices!.keys.first;
      } else {
        final seed = Bn.localiseDigits(f.initial ?? '', locale);
        _controllers[f.key] = TextEditingController(
          text: f.money && seed.isNotEmpty
              ? Bn.number(Bn.parse(seed) ?? 0, decimals: 0, locale: locale)
              : seed,
        )..addListener(() => setState(() {}));
      }
    }
  }

  @override
  void didUpdateWidget(CalculatorScreen old) {
    super.didUpdateWidget(old);
    // Every calculator is pushed as its own route today, so this never fires in
    // the app as it stands. It fires the moment anything rebuilds this widget
    // with a different spec — a tab, a master-detail pane on a tablet, a test —
    // and without it the seeded controllers belong to the previous calculator
    // and every lookup for a field the new one owns is a null dereference.
    if (old.spec.id == widget.spec.id) return;
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _choices.clear();
    _seeded = false;
    _seededLocale = null;
    _seed();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> get _values => {
        for (final f in widget.spec.fields)
          f.key: f.isChoice ? _choices[f.key] : _typed(f.key),
      };

  /// What is in a box, or null when it is empty.
  ///
  /// Null rather than zero, because several optional fields carry a default of
  /// their own — a 5% wastage on soling and on paint, a 5% gap in a brick
  /// stack, a 10% wastage on tiles — and the calculator only reaches that
  /// default when the value is absent. Handing it 0.0 instead meant clearing
  /// the box silently swapped the stated allowance for none: the brick-stack
  /// count rose about 5%, on the calculator whose whole purpose is telling
  /// someone their delivery came up short, and the assumption line underneath
  /// read "০% ফাঁক ধরা হয়েছে" as though they had chosen it.
  ///
  /// A blank required box is caught before the run; text that will not parse
  /// is caught too. So this returns null only where null is the right answer.
  double? _typed(String key) {
    final text = _controllers[key]!.text;
    return text.trim().isEmpty ? null : Bn.parse(text);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final theme = Theme.of(context);

    // A box the reader has emptied to retype is not a mistake, and telling them
    // "the area must be greater than zero" while their thumb is still on the
    // keyboard reads as the app scolding them for nothing. A blank required box
    // means the question is unfinished; only a value they actually typed earns
    // the calculator's own complaint.
    final unfinished = widget.spec.fields.any((f) =>
        !f.isChoice && !f.optional && _controllers[f.key]!.text.trim().isEmpty);
    // Typed, but not a number. Different from blank and different again from a
    // number the calculator rejects, and each deserves its own answer.
    final unreadable = !unfinished &&
        widget.spec.fields.any((f) {
          if (f.isChoice) return false;
          final t = _controllers[f.key]!.text.trim();
          return t.isNotEmpty && Bn.parse(t) == null;
        });

    CalcResult? result;
    String? error;
    if (!unfinished && !unreadable) {
      try {
        result = widget.spec.run(_values);
      } on CalcException catch (e) {
        error = e.of(locale);
      } catch (_) {
        error = context.t(S.fillTheFields);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.t(widget.spec.title))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Text(
            context.t(widget.spec.subtitle),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          for (final f in widget.spec.fields) ...[
            if (f.isChoice)
              _ChoiceField(
                field: f,
                value: _choices[f.key]!,
                onChanged: (v) => setState(() => _choices[f.key] = v),
              )
            else
              _NumberField(
                field: f,
                controller: _controllers[f.key]!,
                values: _values,
              ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          if (unreadable)
            CautionBox(text: context.t(S.notANumber))
          else if (unfinished)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.t(S.fillTheFields),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else if (error != null)
            CautionBox(text: error)
          else if (result != null)
            CalcResultView(result: result),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.field,
    required this.controller,
    required this.values,
  });

  final CalcField field;
  final TextEditingController controller;

  /// The whole form, so a field that renames itself with another field's
  /// choice can read that choice.
  final Map<String, dynamic> values;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Bangla digits are accepted too; Bn.parse normalises them.
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9০-৯.,\s]')),
        if (field.money) GroupedNumberFormatter(context.locale),
      ],
      decoration: InputDecoration(
        labelText: context.t(field.labelFor(values)),
        helperText: field.hintFor(values) == null
            ? null
            : context.t(field.hintFor(values)!),
        helperMaxLines: 3,
        suffixText: field.suffixFor(values) == null
            ? null
            : context.t(field.suffixFor(values)!),
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final CalcField field;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: context.t(field.label)),
      items: [
        for (final e in field.choices!.entries)
          DropdownMenuItem(value: e.key, child: Text(context.t(e.value)))
      ],
      onChanged: (v) => v == null ? null : onChanged(v),
    );
  }
}

/// Renders a [CalcResult]: the numbers, then the formula and assumptions under
/// them.
///
/// Public because the plot-rules screen shows its answer the same way. A second
/// copy of this would be a second place for the two to drift apart, and the
/// formula block is the part of the app that has to look identical everywhere:
/// it is what a reader shows the contractor.
class CalcResultView extends StatelessWidget {
  const CalcResultView({super.key, required this.result});

  final CalcResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final headline = result.lines.where((l) => l.emphasis).toList();
    final rest = result.lines.where((l) => !l.emphasis).toList();

    String format(CalcLine l) =>
        '${Bn.number(l.value, decimals: l.decimals, locale: locale)} '
        '${l.unit.of(locale)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: context.t(S.result),
          icon: Icons.calculate_outlined,
          child: Column(
            children: [
              for (final l in headline)
                ValueRow(
                  label: l.label.of(locale),
                  value: format(l),
                  emphasis: true,
                ),
              if (rest.isNotEmpty) ...[
                const Divider(height: 24),
                for (final l in rest)
                  ValueRow(label: l.label.of(locale), value: format(l)),
              ],
            ],
          ),
        ),
        if (result.note != null) ...[
          const SizedBox(height: 12),
          CautionBox(text: result.note!.of(locale)),
        ],
        const SizedBox(height: 12),
        SectionCard(
          title: context.t(S.howCalculated),
          icon: Icons.functions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The formula and the assumptions are built in the logic layer,
              // which has no locale, so their numbers arrive western while the
              // headline above them has already been rendered in Bangla. Same
              // card, two scripts, explaining the same figure. These are
              // numbers a person reads, so they follow the reader's script.
              Text(Bn.localiseDigits(result.formula.of(locale), locale),
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text(context.t(S.assumptions),
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              for (final a in result.assumptions)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                            Bn.localiseDigits(a.of(locale), locale),
                            style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => copyToClipboard(context, _asText(context)),
          icon: const Icon(Icons.copy_all_outlined),
          label: Text(context.t(S.copy)),
        ),
      ],
    );
  }

  String _asText(BuildContext context) {
    final locale = context.locale;
    final b = StringBuffer();
    for (final l in result.lines) {
      b.writeln('${l.label.of(locale)}: '
          '${Bn.number(l.value, decimals: l.decimals, locale: locale)} '
          '${l.unit.of(locale)}');
    }
    b.writeln();
    b.writeln(Bn.localiseDigits(result.formula.of(locale), locale));
    for (final a in result.assumptions) {
      b.writeln('• ${Bn.localiseDigits(a.of(locale), locale)}');
    }
    if (result.note != null) {
      b.writeln();
      b.writeln(result.note!.of(locale));
    }
    return b.toString();
  }
}
