import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/app/app_scope.dart';
import 'package:nirman_pahara/app/app_state.dart';
import 'package:nirman_pahara/app/theme.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/features/boq/ui/schedule_check_screen.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_store.dart';
import 'package:nirman_pahara/features/prices/logic/sor_rate_store.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for the system file chooser, handing back a file already on disk.
class _PickedFile with MockPlatformInterfaceMixin implements FilePicker {
  _PickedFile(this.path);

  /// Null stands for the reader backing out of the chooser without picking.
  final String? path;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    if (path == null) return null;
    return FilePickerResult([PlatformFile(path: path, name: 'boq', size: 0)]);
  }

  /// Everything else on the interface. If the screen ever starts calling one
  /// of them this fails loudly rather than quietly answering null.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
      '${invocation.memberName} is not stood in for by this test');
}

/// The check-a-schedule screen, driven the way somebody with a bill drives it.
///
/// This is the feature the Right to Information letter now asks documents for,
/// and until now nothing had ever carried a real file through the screen —
/// only through the parser underneath it.
Future<Widget> _app() async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  final prefs = await SharedPreferences.getInstance();
  final content = ContentRepository(reader: (p) => File(p).readAsString());
  await content.loadAll();
  return AppScope(
    state: await AppState.load(),
    content: content,
    store: PrefsInspectionStore(prefs),
    evidence: EvidenceStore(
      directory: () async => Directory.systemTemp.createTempSync('boq'),
    ),
    rates: SorRateStore(prefs),
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const ScheduleCheckScreen(),
    ),
  );
}

void main() {
  /// Tap the import button and let the real file read finish.
  ///
  /// Reading a spreadsheet is real disk work, and under the test binding's
  /// fake clock it never completes — pumpAndSettle would sit there until it
  /// gave up. runAsync hands those futures the real event loop.
  Future<void> importAndSettle(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.byType(FilledButton).first);
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String? pick) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    FilePicker.platform = _PickedFile(pick);
    late Widget app;
    await tester.runAsync(() async => app = await _app());
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('a real statement goes in and comes back as findings',
      (tester) async {
    await open(tester, 'test/fixtures/boq_sample_boundary_wall.txt');

    // Before the import, so the assertion below cannot be satisfied by
    // something the empty screen already says.
    expect(find.textContaining('লাইন'), findsNothing);

    await importAndSettle(tester);

    expect(tester.takeException(), isNull);
    // The screen has to show something about the document it just read, not
    // sit on the empty state as though nothing was picked.
    expect(find.textContaining('লাইন'), findsWidgets,
        reason: 'the imported statement produced no visible result');
  });

  testWidgets('backing out of the chooser leaves the screen usable',
      (tester) async {
    // The spinner used to be left running on the paths that did not return a
    // file, which is the commonest thing to do with a file chooser: open it,
    // change your mind, close it.
    await open(tester, null);

    await importAndSettle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'the screen is still spinning after the reader picked nothing');
    final button = tester.widget<FilledButton>(find.byType(FilledButton).first);
    expect(button.onPressed, isNotNull,
        reason: 'the reader cannot try again');
  });

  testWidgets('a file that is not a schedule says so and stays usable',
      (tester) async {
    // A renamed photograph, a half-finished download. This is the path that
    // used to throw an Error rather than an Exception and leave the spinner up.
    final dir = Directory.systemTemp.createTempSync('notaboq');
    addTearDown(() => dir.deleteSync(recursive: true));
    final junk = File('${dir.path}/not-a-schedule.xlsx')
      ..writeAsBytesSync(List<int>.filled(64, 7));

    await open(tester, junk.path);
    await importAndSettle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'the spinner never stopped on an unreadable file');
    expect(find.textContaining('পড়া গেল না'), findsOneWidget,
        reason: 'the reader is not told the file could not be read');
  });
}
