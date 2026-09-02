import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/features/boq/logic/boq_analyzer.dart';
import 'package:nirman_pahara/features/boq/logic/boq_text_parser.dart';
import 'package:nirman_pahara/features/boq/logic/expected_items.dart';

String _fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();

void main() {
  const parser = BoqTextParser();
  const analyzer = BoqAnalyzer();

  group('Profiles', () {
    test('every expected item explains itself in both languages', () {
      for (final profile in ExpectedItems.all) {
        expect(profile.name.needsTranslation, isFalse, reason: profile.id);
        for (final item in profile.items) {
          expect(item.name.needsTranslation, isFalse, reason: item.id);
          expect(item.why.needsTranslation, isFalse, reason: item.id);
          expect(item.keywords, isNotEmpty, reason: item.id);
        }
      }
    });

    test('a road profile does not demand brickwork', () {
      final ids = ExpectedItems.road.items.map((i) => i.id);
      expect(ids, contains('sub_base'));
      expect(ids, contains('base_course'));
      expect(ids, isNot(contains('brickwork')));
    });

    test('a godown insists on a damp proof course and ventilation', () {
      final critical = ExpectedItems.godown.items
          .where((i) => i.critical)
          .map((i) => i.id);
      expect(critical, contains('dpc'));
      expect(critical, contains('ventilation'));
    });

    test('matching is on the words the schedules actually print', () {
      final dpc = ExpectedItems.godown.items.firstWhere((i) => i.id == 'dpc');
      expect(dpc.matches('Damp proof course over plinth'), isTrue);
      expect(dpc.matches('D.P.C. work'), isTrue);
      expect(dpc.matches('Brick work in superstructure'), isFalse);
    });
  });

  group('Against the real boundary wall statement', () {
    test('finds the items present and does not invent absences', () {
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      final missing = ExpectedItems.boundaryWall
          .missingFrom(doc.lines.map((l) => l.description))
          .map((i) => i.id);

      // The statement carries excavation, sand filling, concrete, steel,
      // shuttering, brickwork and plaster, so none of those may be reported.
      expect(missing, isNot(contains('excavation')));
      expect(missing, isNot(contains('concrete')));
      expect(missing, isNot(contains('reinforcement')));
      expect(missing, isNot(contains('shuttering')));
      expect(missing, isNot(contains('brickwork')));
      expect(missing, isNot(contains('plaster')));
    });

    test('as a godown, the missing damp proof course is raised', () {
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      final findings =
          analyzer.analyse(doc, profile: ExpectedItems.godown);
      final dpc = findings.where((f) => f.title.en!.contains('Damp proof'));
      expect(dpc, isNotEmpty);
      expect(dpc.first.severity, BoqSeverity.question);
      expect(dpc.first.ask.en, contains('separate package'));
    });

    test('without a profile, nothing is said about missing items', () {
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      final findings = analyzer.analyse(doc);
      expect(findings.where((f) => f.title.en!.contains('Not in the schedule')),
          isEmpty);
    });

    test('a missing item is phrased as a question, never as a verdict', () {
      final doc = parser.parse(_fixture('boq_sample_boundary_wall.txt'));
      for (final f in analyzer
          .analyse(doc, profile: ExpectedItems.godown)
          .where((f) => f.title.en!.contains('Not in the schedule'))) {
        expect(f.detail.en, contains('normally carries'));
        expect(f.ask.en, contains('Ask whether'));
        for (final word in ['missing', 'omitted', 'failed']) {
          expect(f.title.en!.toLowerCase(), isNot(contains(word)));
        }
      }
    });
  });

  group('Against the road statement', () {
    test('a road with no sub-base or base course is raised', () {
      final doc = parser.parse(_fixture('boq_sample_road.txt'));
      final findings = analyzer.analyse(doc, profile: ExpectedItems.road);
      final titles = findings.map((f) => f.title.en!).toList();
      // The statement is a concrete road; it carries no sub-base or macadam
      // base line, which for a road profile is worth a question.
      expect(titles.any((t) => t.contains('Sub-base')), isTrue);
      expect(titles.any((t) => t.contains('Base course')), isTrue);
    });
  });
}
