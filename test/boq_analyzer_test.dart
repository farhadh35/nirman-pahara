import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/boq/logic/boq_analyzer.dart';
import 'package:nirman_pahara/features/boq/logic/boq_models.dart';
import 'package:nirman_pahara/features/boq/logic/boq_text_parser.dart';

/// Two real measurement statements from an example food godown campus
/// , in the layout the departments actually issue.
String _fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();

void main() {
  const parser = BoqTextParser();
  const analyzer = BoqAnalyzer();

  group('Parsing a real departmental statement', () {
    test('reads the priced lines out of the boundary wall statement', () {
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      expect(doc.lines.length, greaterThan(10));

      final excavation = doc.lines.first;
      expect(excavation.serial, '1.01');
      expect(excavation.description, contains('Earth work'));
      expect(excavation.unit, 'Cum');
      expect(excavation.scheduleQuantity, 189.96);
      expect(excavation.measuredQuantity, 19.11);
      expect(excavation.rate, 336.00);
      expect(excavation.scheduleAmount, 63826.56);
      expect(excavation.measuredAmount, 6420.96);
    });

    test('keeps negatives that the sheet prints in brackets', () {
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      // 125 mm brick work: measured beyond scheduled, so the remaining
      // balance is printed as (102,812.84).
      final brick = doc.lines.firstWhere(
          (l) => l.description.contains('125 mm non exposed brick'));
      expect(brick.scheduleQuantity, 178.36);
      expect(brick.measuredQuantity, 265.20);
    });

    test('reads the road statement too', () {
      final doc = parser.parse(_fixture('boq_sample_road.txt'));
      expect(doc.lines, isNotEmpty);
      expect(doc.lines.any((l) => l.description.contains('deformed bar')),
          isTrue);
    });
  });

  group('What the analyser finds in the real statements', () {
    test('flags an item billed although the schedule carried none', () {
      // Dismantling of the old boundary wall: schedule 0.00, measured 33.46,
      // Tk 40,152 billed.
      final doc = parser.parse(_fixture('boq_sample_road.txt'));
      final findings = analyzer.analyse(doc);
      final unscheduled = findings.where(
          (f) => f.title.en!.contains('schedule carried none'));
      expect(unscheduled, isNotEmpty);
      expect(unscheduled.first.severity, BoqSeverity.flag);
      expect(unscheduled.first.ask.en, contains('variation order'));
    });

    test('flags the plaster-in-dado overrun in the boundary wall statement',
        () {
      // Scheduled 19.85 sqm, measured 266.73 sqm — more than thirteen times.
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      final findings = analyzer.analyse(doc);
      final overruns = findings.where(
          (f) => f.title.en!.contains('beyond the schedule'));
      expect(overruns, isNotEmpty);
      expect(
        overruns.any((f) => f.detail.en!.contains('Dado')),
        isTrue,
        reason: 'the 19.85 to 266.73 jump should be surfaced',
      );
    });

    test('flags scheduled work with nothing measured', () {
      // 250 mm thick brick wall: 41.16 sqm scheduled, nothing done.
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      final notDone = analyzer
          .analyse(doc)
          .where((f) => f.title.en!.contains('nothing done'));
      expect(notDone, isNotEmpty);
    });

    test('every finding asks for a document rather than making an accusation',
        () {
      for (final name in [
        'boq_sample_road.txt',
        'boq_sample_boundary_wall.txt',
      ]) {
        final findings = analyzer.analyse(parser.parse(_fixture(name)));
        expect(findings, isNotEmpty, reason: name);
        for (final f in findings) {
          expect(f.ask.bn.trim(), isNotEmpty);
          expect(f.title.needsTranslation, isFalse);
          expect(f.detail.needsTranslation, isFalse);
          for (final word in ['দুর্নীতি', 'চুরি', 'ঘুষ']) {
            expect(f.detail.bn, isNot(contains(word)), reason: name);
          }
          for (final word in ['corruption', 'theft', 'fraud', 'bribe']) {
            expect(f.detail.en!.toLowerCase(), isNot(contains(word)),
                reason: name);
          }
        }
      }
    });
  });

  group('Checks on constructed cases', () {
    BoqDocument doc(List<BoqLine> lines,
            {double? schedule, double? measured}) =>
        BoqDocument(
          title: 't',
          lines: lines,
          statedScheduleTotal: schedule,
          statedMeasuredTotal: measured,
          // A single printed total, so comparing it against the sum of the
          // lines is a fair comparison.
          totalRowCount: schedule == null ? 0 : 1,
        );

    test('catches quantity times rate not matching the amount', () {
      final findings = analyzer.analyse(doc([
        const BoqLine(
          serial: '1.01',
          description: 'Padded line',
          unit: 'Cum',
          scheduleQuantity: 10,
          measuredQuantity: 10,
          rate: 100,
          scheduleAmount: 1500, // should be 1000
          measuredAmount: 1000,
        ),
      ]));
      final arithmetic =
          findings.where((f) => f.title.en!.contains('does not equal'));
      expect(arithmetic, isNotEmpty);
      expect(arithmetic.first.amount, closeTo(500, 0.01));
    });

    test('lets ordinary rounding pass', () {
      final findings = analyzer.analyse(doc([
        const BoqLine(
          serial: '1.01',
          description: 'Rounded line',
          scheduleQuantity: 3,
          measuredQuantity: 3,
          rate: 333.333,
          scheduleAmount: 1000,
          measuredAmount: 1000,
        ),
      ]));
      expect(findings.where((f) => f.title.en!.contains('does not equal')),
          isEmpty);
    });

    test('catches the same description priced two ways', () {
      final findings = analyzer.analyse(doc([
        const BoqLine(
            serial: '1.05',
            description: 'Concrete work with stone chips',
            rate: 7730),
        const BoqLine(
            serial: '2.05',
            description: 'Concrete work with stone chips',
            rate: 12154),
      ]));
      expect(findings.where((f) => f.title.en!.contains('two different rates')),
          isNotEmpty);
    });

    test('catches a printed total that the lines do not add up to', () {
      final findings = analyzer.analyse(doc([
        const BoqLine(
            serial: '1', description: 'a', scheduleAmount: 100,
            measuredAmount: 100),
      ], schedule: 500, measured: 100));
      expect(findings.where((f) => f.title.en!.contains('printed total')),
          isNotEmpty);
    });

    test('a clean statement produces nothing to answer for', () {
      final findings = analyzer.analyse(doc([
        const BoqLine(
          serial: '1.01',
          description: 'Honest line',
          unit: 'Cum',
          scheduleQuantity: 10,
          measuredQuantity: 10,
          rate: 100,
          scheduleAmount: 1000,
          measuredAmount: 1000,
        ),
      ], schedule: 1000, measured: 1000));
      expect(findings, isEmpty);
    });
  });
}
