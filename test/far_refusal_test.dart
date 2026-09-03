import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/calculators/logic/calc_result.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/rules/logic/far_calculator.dart';
import 'package:nirman_pahara/features/rules/logic/far_rules.dart';
import 'package:nirman_pahara/features/rules/ui/far_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

/// What the screen does when Table 5 has no figure to give.
///
/// The gazette prints a dash for a use a road will not carry. The app used to
/// answer that with a sentence and nothing else — the reader learned their road
/// would not do, and was left with no idea what would. The table already knows.
void main() {
  late FarPack pack;

  setUp(() async {
    pack = await ContentRepository(reader: _fromDisk).far();
  });

  /// A use and a road width the gazette refuses, found in the table itself
  /// rather than hard-coded, so this keeps working if the data is re-extracted.
  ({FarUse use, double roadM}) aRefusal() {
    for (final use in pack.uses) {
      final firstAllowed = use.narrowestPermittedBand;
      if (firstAllowed != null && firstAllowed > 0) {
        // A width inside a band the gazette leaves blank for this use.
        return (use: use, roadM: pack.roadBands[firstAllowed - 1].fromM);
      }
    }
    throw StateError('no refused combination in the table');
  }

  test('a refusal says which road would carry the use', () {
    final refused = aRefusal();
    final narrowest = refused.use.narrowestPermittedBand!;

    try {
      FarCalculator(pack: pack).compute(
        plotAreaSft: 2160,
        roadWidthM: refused.roadM,
        useCode: refused.use.code,
        zone: refused.use.zone,
      );
      fail('the table has no figure here, so this should have refused');
    } on CalcException catch (e) {
      for (final locale in AppLocale.values) {
        final text = e.of(locale);
        expect(text, contains(RoadBand.fmtMetres(pack.roadBands[narrowest].fromM)),
            reason: 'the refusal does not say what road would carry it: $text');
      }
    }
  });

  testWidgets('a refusal puts the gazette row on the screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    final content = ContentRepository(reader: _fromDisk);
    late Widget app;
    await tester.runAsync(() async {
      await content.loadAll();
      await content.far();
      app = AppScope(
        state: await AppState.load(),
        content: content,
        store: PrefsInspectionStore(prefs),
        evidence: EvidenceStore(
          directory: () async => Directory.systemTemp.createTempSync('far'),
        ),
        rates: SorRateStore(prefs),
        child: const MaterialApp(home: FarScreen()),
      );
    });
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // A road narrower than the table's first band, typed the way a reader
    // would. The seeded use is permitted at every width the table covers, so
    // the refusal has to come from the road being off the bottom of it.
    await tester.enterText(find.byType(TextField).at(1), '১');
    await tester.pumpAndSettle();

    expect(find.text('সারণি-৫ — এই ব্যবহারের সারি'), findsOneWidget,
        reason: 'the refusal left the reader with a sentence and no table');
    // Every band the gazette prints, so the reader can see which width would
    // carry the use rather than only that theirs does not.
    for (final band in pack.roadBands) {
      expect(find.text(band.label.bn), findsOneWidget,
          reason: 'the row omits the ${band.label.bn} column');
    }
    expect(tester.takeException(), isNull);
  });

  test('a width the gazette refuses is a dash, never a zero', () {
    // The table prints a blank for a use a road will not carry. Rendering that
    // as 0 would read as "no floor area allowed here", which is a different
    // and much weaker statement than "not this use, on this road".
    final refused = aRefusal();
    expect(refused.use.far.any((f) => f == null), isTrue);
    final band = pack.roadBands.indexWhere(
        (b) => b.fromM == refused.roadM);
    expect(refused.use.far[band], isNull,
        reason: 'the chosen combination is not actually refused');
  });
}
