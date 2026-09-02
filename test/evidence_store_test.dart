import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/inspection/logic/evidence_store.dart';

void main() {
  late Directory tmp;
  late EvidenceStore store;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('evidence_test');
    store = EvidenceStore(directory: () async => Directory('${tmp.path}/e'));
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  File sourceImage(String name) {
    final f = File('${tmp.path}/$name')..writeAsBytesSync([1, 2, 3]);
    return f;
  }

  test('a photograph is copied in and addressed by name', () async {
    final name = await store.add(sourceImage('shot.jpg'),
        runId: 'r1', itemId: 'r3');
    expect(name, startsWith('r1_r3_'));
    expect(name, endsWith('.jpg'));

    final stored = await store.file(name);
    expect(stored, isNotNull);
    expect(stored!.readAsBytesSync(), [1, 2, 3]);
  });

  test('the original is left alone — this copies, it does not move', () async {
    final src = sourceImage('shot.jpg');
    await store.add(src, runId: 'r1', itemId: 'r3');
    expect(src.existsSync(), isTrue);
  });

  test('an unknown name returns null rather than throwing', () async {
    expect(await store.file('nope.jpg'), isNull);
  });

  test('removing deletes the file', () async {
    final name =
        await store.add(sourceImage('a.jpg'), runId: 'r1', itemId: 'i1');
    await store.remove(name);
    expect(await store.file(name), isNull);
  });

  test('removing a name that is already gone is not an error', () async {
    await store.remove('missing.jpg');
  });

  test('deleting a run takes its photographs and nobody else\'s', () async {
    final mine =
        await store.add(sourceImage('a.jpg'), runId: 'r1', itemId: 'i1');
    final other =
        await store.add(sourceImage('b.jpg'), runId: 'r2', itemId: 'i1');

    await store.removeForRun('r1');

    expect(await store.file(mine), isNull);
    expect(await store.file(other), isNotNull);
  });

  test('an unusual extension is preserved, and a missing one defaults', () async {
    final png =
        await store.add(sourceImage('a.PNG'), runId: 'r1', itemId: 'i1');
    expect(png, endsWith('.png'));
    final none =
        await store.add(sourceImage('noext'), runId: 'r1', itemId: 'i2');
    expect(none, endsWith('.jpg'));
  });

  test('the directory is created on first use', () async {
    expect(Directory('${tmp.path}/e').existsSync(), isFalse);
    await store.add(sourceImage('a.jpg'), runId: 'r1', itemId: 'i1');
    expect(Directory('${tmp.path}/e').existsSync(), isTrue);
  });
}
