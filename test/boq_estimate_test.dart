import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/boq/logic/boq_analyzer.dart';
import 'package:nirman_pahara/features/boq/logic/boq_text_parser.dart';
import 'package:nirman_pahara/features/boq/logic/schedule_importer.dart';
import 'package:nirman_pahara/features/boq/logic/schedule_row_parser.dart';

/// An estimate, not a running bill.
///
/// A running account statement measures work against a schedule and prints
/// seven figures a row. An estimate is written before anything is built: it
/// names one plain "Quantity" column, heads its serial "S.L No.", numbers its
/// lines 1.05(a) and 1.22(b), and prints three figures. Every one of those
/// details defeated the parsers, which had only ever been shown running bills.
///
/// Columns and item numbering follow a real office-building estimate issued by
/// a district food office.
void main() {
  const rowParser = ScheduleRowParser();
  const textParser = BoqTextParser();
  const analyzer = BoqAnalyzer();

  const csv = '''
Bill Of Quantity, Construction of office building,,,,
S.L No.,Description of works,Quantity,Unit,Rate(Tk),Amount(Tk)
1.01,Earth work in excavation of foundation trenches,40.14,cum,153.00,6141.42
1.02,One layer brick flat soling in foundation & floor,80.46,sqm,607.00,48839.22
1.05(a),Mass concrete in foundation & floor (1:3:6),2.80,cum,9083.00,25432.40
1.11(a),10" Brick work in superstructure (1:6),26.29,cum,9340.00,245548.60
1.22(b),R.C.C work with brick chips (1:2:4) in raft slab,5.60,cum,10035.00,56196.00
,Total,,,,382157.64
''';

  group('An estimate read from a spreadsheet', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('estimate_test'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('finds the quantity column when it is headed plainly "Quantity"',
        () async {
      final file = File('${tmp.path}/estimate.csv')..writeAsStringSync(csv);
      final doc = (await const ScheduleImporter().read(file)).document;

      expect(doc.lines, hasLength(5));
      for (final l in doc.lines) {
        expect(l.scheduleQuantity, isNotNull, reason: l.serial);
        expect(l.scheduleQuantity, greaterThan(0), reason: l.serial);
      }
      // Without this the sheet imported with no quantity at all, and the
      // analyser then read every line as billed against nothing.
      expect(doc.lines.first.scheduleQuantity, 40.14);
      expect(doc.lines.first.rate, 153.0);
    });

    test('finds the serial column when it is headed "S.L No."', () {
      final doc = rowParser.parse([
        ['S.L No.', 'Description of works', 'Quantity', 'Unit', 'Rate(Tk)'],
        ['1.05(a)', 'Mass concrete in foundation', '2.80', 'cum', '9083.00'],
      ]);
      expect(doc.lines.single.serial, '1.05(a)');
    });

    test('knows it carries no measured column', () async {
      final file = File('${tmp.path}/estimate.csv')..writeAsStringSync(csv);
      final doc = (await const ScheduleImporter().read(file)).document;
      expect(doc.hasMeasuredColumn, isFalse);
    });

    test('reports nothing about work being done or not done', () async {
      final file = File('${tmp.path}/estimate.csv')..writeAsStringSync(csv);
      final doc = (await const ScheduleImporter().read(file)).document;
      final titles =
          analyzer.analyse(doc).map((f) => f.title.en ?? f.title.bn).toList();

      // An estimate is written before the work exists. Asking whether it was
      // executed would report every line of an ordinary document.
      expect(titles, isNot(contains('Scheduled, but nothing done')));
      expect(titles,
          isNot(contains('Billed although the schedule carried none')));
    });

    test('still checks the arithmetic, which does mean something here', () {
      final doc = rowParser.parse([
        ['S.L No.', 'Description of works', 'Quantity', 'Unit', 'Rate(Tk)',
            'Amount(Tk)'],
        // 2.80 x 9083 is 25,432.40, not 52,432.40.
        ['1.05(a)', 'Mass concrete', '2.80', 'cum', '9083.00', '52432.40'],
      ]);
      final titles =
          analyzer.analyse(doc).map((f) => f.title.en ?? f.title.bn);
      expect(titles,
          contains('Quantity times rate does not equal the amount'));
    });
  });

  group('Inch marks in a description', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('inch_test'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('a bare inch mark does not swallow the rest of the row', () async {
      // 10" brick work and 5" walls are on nearly every Bangladeshi bill. A
      // double quote read as an opening quote ate every comma after it, and the
      // line arrived with no quantity and no rate at all.
      final file = File('${tmp.path}/inch.csv')
        ..writeAsStringSync('S.L No.,Description of works,Quantity,Unit,'
            'Rate(Tk),Amount(Tk)\n'
            '1.11(a),10" Brick work in superstructure (1:6),26.29,cum,'
            '9340.00,245548.60\n');
      final doc = (await const ScheduleImporter().read(file)).document;

      final line = doc.lines.single;
      expect(line.description, contains('Brick work'));
      expect(line.scheduleQuantity, 26.29);
      expect(line.rate, 9340.00);
      expect(line.unit, 'cum');
    });

    test('a properly quoted field still works', () async {
      final file = File('${tmp.path}/quoted.csv')
        ..writeAsStringSync('S.L No.,Description of works,Quantity,Unit,'
            'Rate(Tk),Amount(Tk)\n'
            '1.01,"Earth work, including shoring",40.14,cum,153.00,6141.42\n');
      final doc = (await const ScheduleImporter().read(file)).document;
      expect(doc.lines.single.description, 'Earth work, including shoring');
      expect(doc.lines.single.scheduleQuantity, 40.14);
    });
  });

  group('An estimate read from flowed text', () {
    const text = '''
Bill Of Quantity, Construction of office building (3 room)
S.L No.   Description of works                          Quantity  Unit   Rate      Amount
1.01      Earth work in excavation of foundation        40.14     cum    153.00    6141.42
1.05(a)   Mass concrete in foundation & floor (1:3:6)   2.80      cum    9083.00   25432.40
1.22(b)   R.C.C work with brick chips (1:2:4)           5.60      cum    10035.00  56196.00
''';

    test('reads lines whose serial carries a bracketed suffix', () {
      final doc = textParser.parse(text);
      // The old serial pattern demanded a bare two-level number, so 1.05(a)
      // and 1.22(b) never matched and their lines were dropped entirely.
      expect(doc.lines.map((l) => l.serial),
          containsAll(<String>['1.01', '1.05(a)', '1.22(b)']));
    });

    test('reads a three-figure row, which a running bill never has', () {
      final doc = textParser.parse(text);
      expect(doc.lines, hasLength(3));
      final concrete =
          doc.lines.firstWhere((l) => l.serial == '1.05(a)');
      expect(concrete.scheduleQuantity, 2.80);
      expect(concrete.rate, 9083.00);
      expect(concrete.scheduleAmount, 25432.40);
      expect(concrete.measuredQuantity, isNull);
      expect(doc.hasMeasuredColumn, isFalse);
    });
  });

  group('A running bill is unchanged', () {
    test('still sets the measured quantity against the scheduled one', () {
      final doc = textParser.parse(
          File('test/fixtures/boq_sample_boundary_wall.txt').readAsStringSync());
      expect(doc.hasMeasuredColumn, isTrue);
      final priced =
          doc.lines.where((l) => l.measuredQuantity != null).toList();
      expect(priced, isNotEmpty,
          reason: 'the measured column must still be read');
    });
  });
}
