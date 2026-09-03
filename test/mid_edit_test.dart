import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/calculators/ui/calc_spec.dart';
import 'package:nirman_pahara/features/calculators/ui/calculator_screen.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

Future<Widget> _wrap(WidgetTester tester, Widget child) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  return AppScope(
    state: await AppState.load(),
    content: ContentRepository(reader: (p) => File(p).readAsString()),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('mid_edit'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(home: child),
  );
}

void main() {
  // Clearing a box to type a new number is the most ordinary thing a person
  // does on these screens, and it used to be answered with a warning: "the area
  // must be greater than zero", in an amber box, while their thumb was still on
  // the keyboard. They had not made a mistake. They had made an empty box.
  testWidgets('emptying a field waits, and does not scold', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final spec = CalcSpec.byId('plaster')!;
    await tester.pumpWidget(await _wrap(tester, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();

    // It opens with an answer.
    expect(find.text('ফলাফল'), findsOneWidget);

    // The reader clears the area to type a different one.
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    expect(find.text('ফলাফল'), findsNothing, reason: 'a stale result stayed up');
    expect(find.text('উপরের ঘরগুলো পূরণ করুন'), findsOneWidget);
    // The calculator's own complaint is for a value they typed, not for a gap.
    expect(find.textContaining('শূন্যের বেশি হতে হবে'), findsNothing,
        reason: 'an empty box was treated as a wrong answer');
  });

  testWidgets('a zero they actually typed still gets the real message',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final spec = CalcSpec.byId('plaster')!;
    await tester.pumpWidget(await _wrap(tester, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '০');
    await tester.pumpAndSettle();

    // Typing a zero is a claim about the wall, and it is wrong, so say so.
    expect(find.textContaining('শূন্যের বেশি হতে হবে'), findsOneWidget);
    expect(find.text('উপরের ঘরগুলো পূরণ করুন'), findsNothing);
  });

  testWidgets('an optional field left empty does not block the answer',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Brickwork's openings box is optional; an empty one must not stop the
    // wall being calculated.
    final spec = CalcSpec.byId('brickwork')!;
    await tester.pumpWidget(await _wrap(tester, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();

    // Only non-choice fields render as a TextField, so the box's position in
    // the form is not its position in the spec.
    final boxes = spec.fields.where((f) => !f.isChoice).toList();
    final openings = boxes.indexWhere((f) => f.key == 'openings');
    expect(openings, greaterThan(-1), reason: 'no optional openings box');
    expect(boxes[openings].optional, isTrue);
    await tester.enterText(find.byType(TextField).at(openings), '');
    await tester.pumpAndSettle();

    expect(find.text('ফলাফল'), findsOneWidget);
  });

  testWidgets('something typed that is not a number says so', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final spec = CalcSpec.byId('plaster')!;
    await tester.pumpWidget(await _wrap(tester, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();

    // The keypad allows a dot and a comma, so this is a thing a thumb makes.
    // It parses to nothing, was substituted with zero, and the reader was told
    // the area must be greater than zero — which sends them looking at the
    // wrong thing.
    await tester.enterText(find.byType(TextField).first, '১.২.৩');
    await tester.pumpAndSettle();

    expect(find.textContaining('সংখ্যা হিসেবে পড়া যাচ্ছে না'), findsOneWidget);
    expect(find.textContaining('শূন্যের বেশি হতে হবে'), findsNothing,
        reason: 'the reader is told the number is too small, not unreadable');
    expect(find.text('উপরের ঘরগুলো পূরণ করুন'), findsNothing,
        reason: 'the box is not empty, it is unreadable');
  });

  testWidgets('a comma is grouping, not a mistake', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final spec = CalcSpec.byId('plaster')!;
    await tester.pumpWidget(await _wrap(tester, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();

    // People write large numbers with separators, and stripping them is the
    // intended behaviour — this must not be caught by the new check.
    await tester.enterText(find.byType(TextField).first, '১,২০০');
    await tester.pumpAndSettle();

    expect(find.text('ফলাফল'), findsOneWidget);
    expect(find.textContaining('সংখ্যা হিসেবে পড়া যাচ্ছে না'), findsNothing);
  });

  testWidgets('clearing an optional box uses its stated default, not zero',
      (tester) async {
    // The brick stack seeds a 5% gap and says so underneath. Clearing that box
    // used to hand the calculator 0.0 rather than nothing, so the default was
    // never reached: the expected brick count rose by about 5% and the
    // assumption line claimed 0% had been chosen. On the calculator whose
    // purpose is to tell someone a delivery came up short, that inflates the
    // number a short delivery is measured against.
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final spec = CalcSpec.byId('brick_stack')!;
    await tester.pumpWidget(await _wrap(tester, CalculatorScreen(spec: spec)));
    await tester.pumpAndSettle();
    expect(find.textContaining('৫% ফাঁক'), findsOneWidget,
        reason: 'the seeded gap is not being stated');

    // Clear the optional gap box. It is optional, so nothing blocks the run.
    final gap = find.byType(TextField).at(3);
    await tester.enterText(gap, '');
    await tester.pumpAndSettle();

    expect(find.textContaining('০% ফাঁক'), findsNothing,
        reason: 'an empty box was read as a deliberate zero');
    expect(find.textContaining('৫% ফাঁক'), findsOneWidget,
        reason: 'the stated default was not applied');
  });
}
