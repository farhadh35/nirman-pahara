import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/boq/logic/boq_analyzer.dart';
import 'package:nirman_pahara/features/boq/logic/schedule_importer.dart';
import 'package:nirman_pahara/features/boq/logic/schedule_row_parser.dart';

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('import_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  File write(String name, String content) =>
      File('${tmp.path}/$name')..writeAsStringSync(content);

  /// Columns in the order the departmental statements actually print them.
  const csv = '''
Re-Construction Of Boundary wall at Example LSD-1,,,,,,,
Sl. No.,Short Description,Unit,Schedule Quantity,Measued Quantity,Rate in Taka,Schedule Amount,Measured Amount
1.01,Earth work in Excavation up to 1.5m depth,Cum,189.96,19.11,336.00,63826.56,6420.96
1.11,250mm thick brick wall,Sqm,41.16,0.00,8164,336030.24,0
1.12,Plaster in Dado,Sqm,19.85,266.73,373.00,7404.05,99489.78
1.13,Dismantling of old wall,Sqm,0,33.46,1200.00,0,40152.00
,Total,,,,,407260.85,146062.74
''';

  group('Reading a spreadsheet-shaped schedule', () {
    test('reads a CSV with the departmental column names', () async {
      final result =
          await const ScheduleImporter().read(write('schedule.csv', csv));
      expect(result.route, ImportRoute.spreadsheet);
      expect(result.ok, isTrue);

      final first = result.document.lines.first;
      expect(first.serial, '1.01');
      expect(first.description, contains('Earth work'));
      expect(first.unit, 'Cum');
      expect(first.scheduleQuantity, 189.96);
      expect(first.measuredQuantity, 19.11);
      expect(first.rate, 336.00);
      expect(first.scheduleAmount, 63826.56);
      expect(first.measuredAmount, 6420.96);
    });

    test('picks up the document title above the header row', () async {
      final result =
          await const ScheduleImporter().read(write('schedule.csv', csv));
      expect(result.document.title, contains('Example'));
    });

    test('the findings match what the numbers say', () async {
      final result =
          await const ScheduleImporter().read(write('schedule.csv', csv));
      final findings = const BoqAnalyzer().analyse(result.document);

      expect(
        findings.any((f) => f.title.en!.contains('schedule carried none')),
        isTrue,
        reason: 'dismantling has no scheduled quantity but is billed',
      );
      expect(
        findings.any((f) => f.title.en!.contains('nothing done')),
        isTrue,
        reason: 'the 250 mm wall was scheduled and not built',
      );
      expect(
        findings.any((f) => f.detail.en!.contains('Dado')),
        isTrue,
        reason: 'the dado plaster overran by more than twelve times',
      );
    });

    test('spreadsheet columns are trusted, so arithmetic is checked', () async {
      final result = await const ScheduleImporter().read(write(
        'padded.csv',
        'Sl. No.,Short Description,Unit,Schedule Quantity,Measued Quantity,'
            'Rate in Taka,Schedule Amount,Measured Amount\n'
            '1.01,Padded line,Cum,10,10,100,1500,1000\n',
      ));
      final findings = const BoqAnalyzer().analyse(result.document);
      expect(findings.any((f) => f.title.en!.contains('does not equal')),
          isTrue);
    });
  });

  group('Other formats', () {
    test('plain text is read, and says the columns were inferred', () async {
      final file = write('statement.txt',
          File('test/fixtures/boq_sample_boundary_wall.txt').readAsStringSync());
      final result = await const ScheduleImporter().read(file);
      expect(result.route, ImportRoute.text);
      expect(result.ok, isTrue);
      expect(result.warning!.en, contains('inferred'));
    });

    test('a PDF is refused, with the reason and a way forward', () async {
      final result =
          await const ScheduleImporter().read(write('statement.pdf', 'x'));
      expect(result.route, ImportRoute.unsupported);
      expect(result.ok, isFalse);
      // The refusal has to explain itself: guessing columns out of a PDF turns
      // into a confident claim about someone's money.
      expect(result.warning!.en, contains('guessing'));
      expect(result.warning!.en, contains('spreadsheet'));
      expect(result.warning!.bn, contains('এক্সেল'));
    });

    test('a refused import reports nothing as read', () async {
      // Nothing was read, so there is no summary to show — only the reason.
      final result =
          await const ScheduleImporter().read(write('statement.pdf', 'x'));
      expect(result.ok, isFalse);
      expect(result.document.lines, isEmpty);
      expect(result.warning, isNotNull);
    });

    test('an unknown extension is refused politely', () async {
      final result =
          await const ScheduleImporter().read(write('notes.rtf', 'x'));
      expect(result.route, ImportRoute.unsupported);
      expect(result.warning, isNotNull);
    });
  });

  group('Header detection', () {
    test('finds the header even with title rows above it', () {
      final doc = const ScheduleRowParser().parse([
        ['Some project title', '', ''],
        ['', '', ''],
        ['Sl. No.', 'Description', 'Unit', 'Rate in Taka'],
        ['1.01', 'A line', 'Cum', '100'],
      ]);
      expect(doc.lines.single.description, 'A line');
    });

    test('a sheet with no recognisable header yields nothing, not nonsense',
        () {
      final doc = const ScheduleRowParser().parse([
        ['alpha', 'beta'],
        ['1', '2'],
      ]);
      expect(doc.lines, isEmpty);
    });
  });
}
