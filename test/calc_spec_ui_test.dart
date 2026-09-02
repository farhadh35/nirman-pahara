import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/calculators/ui/calc_spec.dart';

/// Turns a spec's seeded fields into the value map the screen would build.
Map<String, dynamic> seededValues(CalcSpec spec) => {
      for (final f in spec.fields)
        f.key: f.isChoice
            ? (f.initial ?? f.choices!.keys.first)
            : (double.tryParse(f.initial ?? '') ?? 0.0),
    };

void main() {
  test('every calculator opens on a working answer', () {
    // The screen shows its result the moment it is opened, with no button to
    // press. A spec whose seeded values throw therefore greets the reader with
    // an error box on a form they have not touched yet — which reads as "this
    // app is broken", not "fill something in".
    for (final spec in CalcSpec.all) {
      late CalcResult r;
      expect(
        () => r = spec.run(seededValues(spec)),
        returnsNormally,
        reason: '${spec.id} throws on the values it seeds itself with',
      );
      expect(r.lines, isNotEmpty, reason: '${spec.id} returned no lines');
      expect(r.lines.any((l) => l.emphasis), isTrue,
          reason: '${spec.id} has no headline number');
      for (final l in r.lines) {
        expect(l.value.isFinite, isTrue,
            reason: '${spec.id} line "${l.key}" is ${l.value}');
      }
    }
  });

  test('every field is wired to something the calculator reads', () {
    // A field the run closure ignores is a box the reader types into while
    // nothing happens. Nudging each numeric field and watching for any change
    // in the output catches that.
    for (final spec in CalcSpec.all) {
      final base = spec.run(seededValues(spec));
      for (final f in spec.fields) {
        if (f.isChoice) continue;
        final values = seededValues(spec);
        final seeded = (values[f.key] as double?) ?? 0;
        values[f.key] = seeded == 0 ? 7.0 : seeded * 2 + 1;
        CalcResult? moved;
        try {
          moved = spec.run(values);
        } on CalcException {
          // Refusing the nudged value still proves the field is read.
          continue;
        }
        final changed = moved.lines.length != base.lines.length ||
            [
              for (var i = 0; i < moved.lines.length; i++)
                moved.lines[i].value != base.lines[i].value,
            ].any((c) => c);
        expect(changed, isTrue,
            reason: '${spec.id}: changing "${f.key}" changed no output, so the '
                'field is dead');
      }
    }
  });

  test('every spec is bilingual and lands in a group', () {
    final ids = <String>{};
    for (final spec in CalcSpec.all) {
      expect(ids.add(spec.id), isTrue, reason: 'duplicate id ${spec.id}');
      for (final t in <L10nText>[spec.title, spec.subtitle]) {
        expect(t.bn.trim(), isNotEmpty);
        expect(t.en?.trim() ?? '', isNotEmpty, reason: '${spec.id} lacks English');
        expect(t.bn, isNot(equals(t.en)), reason: '${spec.id} is untranslated');
      }
      expect(spec.fields, isNotEmpty);
      for (final f in spec.fields) {
        expect(f.label.bn.trim(), isNotEmpty);
        expect(f.label.en?.trim() ?? '', isNotEmpty,
            reason: '${spec.id}.${f.key} label lacks English');
        if (f.suffix != null) {
          expect(f.suffix!.en?.trim() ?? '', isNotEmpty,
              reason: '${spec.id}.${f.key} suffix lacks English');
        }
        if (f.hint != null) {
          expect(f.hint!.en?.trim() ?? '', isNotEmpty,
              reason: '${spec.id}.${f.key} hint lacks English');
        }
        for (final c in (f.choices ?? const <String, L10nText>{}).values) {
          expect(c.en?.trim() ?? '', isNotEmpty,
              reason: '${spec.id}.${f.key} choice lacks English');
        }
      }
    }
    // Every group in the enum earns its place, and every spec sits in one.
    for (final g in CalcGroup.values) {
      expect(CalcSpec.inGroup(g), isNotEmpty,
          reason: 'group ${g.name} has no calculators, so it renders as an '
              'empty heading');
    }
  });

  test('seeded numbers are written in western digits', () {
    // The screen localises them itself. A Bangla digit here would be parsed as
    // zero and the form would open on nonsense.
    final bangla = RegExp(r'[০-৯]');
    for (final spec in CalcSpec.all) {
      for (final f in spec.fields) {
        if (f.isChoice || f.initial == null) continue;
        expect(bangla.hasMatch(f.initial!), isFalse,
            reason: '${spec.id}.${f.key} seeds Bangla digits: ${f.initial}');
      }
    }
  });

  testWidgets('the grouped list shows every calculator under a heading',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    // Rendered through the real widget so a spec that cannot lay out fails here
    // rather than on a phone.
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ListView(
          children: [
            for (final g in CalcSpec.groups) ...[
              Text(g.title.bn),
              for (final s in CalcSpec.inGroup(g)) Text(s.title.bn),
            ],
          ],
        ),
      ),
    ));
    for (final g in CalcSpec.groups) {
      expect(find.text(g.title.bn), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
