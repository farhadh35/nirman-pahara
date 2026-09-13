import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:nirman_pahara/features/update/logic/update_check.dart';
import 'package:nirman_pahara/features/update/ui/update_settings_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The settings row that has to answer, not deflect.
///
/// The row this replaced opened the Play Store page and nothing else. A reader
/// who wanted to know whether they were current was handed a web page and left
/// to work it out from a version number. These tests hold the row to asking
/// the question and reporting what came back.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'locale': AppLocale.bn.name}));

  testWidgets('the row asks Play; it does not just open a page', (tester) async {
    final check = _FakeCheck();
    await tester.pumpWidget(await _wrap(UpdateSettingsTile(check: check)));
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(check.checked, 1, reason: 'the row must run the check itself');
    expect(check.storeOpened, 0,
        reason: 'the store page is the fallback, not the behaviour');
  });

  testWidgets('when Play cannot answer, the reader is told before being sent away',
      (tester) async {
    final check = _FakeCheck();
    await tester.pumpWidget(await _wrap(UpdateSettingsTile(check: check)));
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget,
        reason: 'silence leaves the reader guessing whether anything happened');
    expect(check.storeOpened, 0,
        reason: 'the store is offered, not taken on the reader\'s behalf');
  });

  testWidgets('asking by hand quiets the home prompt for the day', (tester) async {
    // Otherwise the reader asks in settings, hears the answer, and gets asked
    // the same question by the home screen on the next launch.
    final check = _FakeCheck();
    await tester.pumpWidget(await _wrap(UpdateSettingsTile(check: check)));
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(await const UpdateCheck().dueForCheck(prefs), isFalse,
        reason: 'the manual check did not count as having asked');
  });

  testWidgets('a real update goes to Play, not to the browser', (tester) async {
    final check = _FakeCheck(hasUpdate: true);
    await tester.pumpWidget(await _wrap(UpdateSettingsTile(check: check)));
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(check.flexibleStarted, 1,
        reason: 'an in-app update is the whole point of using Play for this');
  });
}

/// Records what was asked of it, so a test can tell a row that checks from a
/// row that merely links.
class _FakeCheck extends UpdateCheck {
  _FakeCheck({this.hasUpdate = false});

  final bool hasUpdate;
  int checked = 0;
  int storeOpened = 0;
  int flexibleStarted = 0;

  @override
  Future<AppUpdateInfo?> available() async {
    checked++;
    if (!hasUpdate) return null;
    return AppUpdateInfo(
      updateAvailability: UpdateAvailability.updateAvailable,
      immediateUpdateAllowed: false,
      immediateAllowedPreconditions: null,
      flexibleUpdateAllowed: true,
      flexibleAllowedPreconditions: null,
      availableVersionCode: 99,
      installStatus: InstallStatus.unknown,
      packageName: 'bd.nirmanpahara.nirman_pahara',
      clientVersionStalenessDays: null,
      updatePriority: 0,
    );
  }

  @override
  Future<bool> startFlexible() async {
    flexibleStarted++;
    return true;
  }

  @override
  Future<bool> openStore() async {
    storeOpened++;
    return true;
  }
}

Future<Widget> _wrap(Widget child) async {
  final prefs = await SharedPreferences.getInstance();
  return AppScope(
    state: await AppState.load(),
    // Not loaded: this row reads no content, and loadAll() does real file I/O
    // that never completes under the widget-test clock.
    content: ContentRepository(reader: (p) => File(p).readAsString()),
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('update'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    ),
  );
}
