import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nirman_pahara/features/inspection/logic/lost_capture.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Android can kill this app while the system camera is in front of it. The
/// picture is still taken; nothing on the ordinary path ever learns of it.
/// These are the cases that decide whether it comes back, and — more
/// importantly — the cases where it must not be attached to a guess.
void main() {
  late Directory tmp;
  late File shot;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('lost');
    shot = File('${tmp.path}/held.jpg')..writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  LostCapture picker({File? held, bool supported = true, bool throws = false}) =>
      LostCapture(
        supported: supported,
        retrieve: () async {
          if (throws) throw Exception('platform channel is not there');
          return held == null
              ? LostDataResponse.empty()
              : LostDataResponse(file: XFile(held.path));
        },
      );

  test('a photograph held by the platform comes back to the item it was for',
      () async {
    final lost = picker(held: shot);
    await lost.awaiting(runId: 'r1', itemId: 'b7a');

    final found = await lost.recover('r1');
    expect(found, isNotNull);
    expect(found!.itemId, 'b7a');
    expect(found.file.path, shot.path);
  });

  test('it is only handed over once', () async {
    final lost = picker(held: shot);
    await lost.awaiting(runId: 'r1', itemId: 'b7a');
    expect(await lost.recover('r1'), isNotNull);
    expect(await lost.recover('r1'), isNull,
        reason: 'the same photograph would be attached twice');
  });

  test('an image with no note about what it was of is left alone', () async {
    // The platform is holding something, but nothing says which item it
    // belongs to. Filing it against a guess is worse than not filing it.
    final lost = picker(held: shot);
    expect(await lost.recover('r1'), isNull);
  });

  test('a photograph is never given to a different inspection', () async {
    final lost = picker(held: shot);
    await lost.awaiting(runId: 'r1', itemId: 'b7a');
    expect(await lost.recover('r2'), isNull,
        reason: "one inspection collected another inspection's photograph");
    // And it is still there for the run it belongs to.
    expect(await lost.recover('r1'), isNotNull);
  });

  test('a camera that came back normally leaves nothing behind', () async {
    final lost = picker(held: shot);
    await lost.awaiting(runId: 'r1', itemId: 'b7a');
    await lost.settled();
    expect(await lost.recover('r1'), isNull);
  });

  test('the platform holding nothing keeps the note for the next ask',
      () async {
    // Being killed is not the only reason pickImage fails to return, so a
    // single empty answer must not throw away the note.
    final empty = picker();
    await empty.awaiting(runId: 'r1', itemId: 'b7a');
    expect(await empty.recover('r1'), isNull);
    expect(await picker(held: shot).recover('r1'), isNotNull);
  });

  test('nothing is asked of a platform that does not drop results', () async {
    final lost = picker(held: shot, supported: false);
    await lost.awaiting(runId: 'r1', itemId: 'b7a');
    expect(await lost.recover('r1'), isNull);
  });

  test('a platform that cannot answer is treated as holding nothing',
      () async {
    final lost = picker(throws: true);
    await lost.awaiting(runId: 'r1', itemId: 'b7a');
    expect(await lost.recover('r1'), isNull);
  });
}
