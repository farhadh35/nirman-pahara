import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_run.dart';
import 'package:nirman_pahara/features/inspection/logic/photo_ref.dart';
import 'package:nirman_pahara/features/inspection/report/report_document.dart';
import 'package:nirman_pahara/features/inspection/report/report_sheet.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

void main() {
  late ChecklistPack road;
  late Directory tmp;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('report_doc');
    final repo = ContentRepository(reader: _fromDisk);
    road = (await repo.checklistById('road_rural'))!;
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  InspectionRun buildRun() {
    final run = InspectionRun(
      id: 'r1',
      pack: road,
      projectName: 'ওয়ার্ড ৩ সড়ক',
      location: 'পালাশবাড়ি',
      tenderId: 'LGED-2026-0142',
      date: DateTime(2026, 7, 12, 9, 30),
    );
    run.findings['r3']!
      ..answer = ItemAnswer.problem
      ..note = '১২ জুলাই সকাল ৯টা — সাব-বেজ ১০০ মিমি।'
      ..photos.add(PhotoRef(
        name: 'a.jpg',
        takenAt: DateTime(2026, 7, 12, 9, 35),
        latitude: 24.89431,
        longitude: 89.37215,
        outcome: LocationOutcome.recorded,
      ));
    run.findings['r4']!.answer = ItemAnswer.unsure;
    return run;
  }

  testWidgets('renders a report page off-screen at the requested width',
      (tester) async {
    final png = (await tester.runAsync(() => const ReportDocument().rasterise(
          ReportSheet(
            run: buildRun(),
            locale: AppLocale.bn,
            photoFiles: const {},
          ),
          width: 620,
        )))!;

    expect(png, isNotEmpty);
    // PNG magic number — a real image came back, not an empty buffer.
    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);

    final decoded = (await tester.runAsync(() => decodeImageFromList(png)))!;
    expect(decoded.width, 620);
    // Tall enough to hold a header, a summary and two findings.
    expect(decoded.height, greaterThan(400));
  });

  testWidgets('wraps the page into a PDF', (tester) async {
    const document = ReportDocument();
    final pdf = (await tester.runAsync(() async {
      final png = await document.rasterise(
        ReportSheet(
          run: buildRun(),
          locale: AppLocale.en,
          photoFiles: const {},
        ),
        width: 620,
      );
      return document.toPdf(png);
    }))!;

    expect(pdf, isNotEmpty);
    // %PDF- header.
    expect(String.fromCharCodes(pdf.sublist(0, 5)), '%PDF-');
  });

  testWidgets('writes the document where it is told to', (tester) async {
    const document = ReportDocument();
    final file = (await tester.runAsync(() async {
      final png = await document.rasterise(
        ReportSheet(
          run: buildRun(),
          locale: AppLocale.bn,
          photoFiles: const {},
        ),
        width: 400,
      );
      return document.write(
        await document.toPdf(png),
        Directory('${tmp.path}/exports'),
        'report.pdf',
      );
    }))!;

    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(1000));
  });

  testWidgets('a run with nothing wrong still produces a page',
      (tester) async {
    final run = InspectionRun(
      id: 'r2',
      pack: road,
      projectName: 'Clean road',
      date: DateTime(2026, 7, 12),
    );
    for (final f in run.findings.values) {
      f.answer = ItemAnswer.ok;
    }

    final png = (await tester.runAsync(() => const ReportDocument().rasterise(
          ReportSheet(run: run, locale: AppLocale.en, photoFiles: const {}),
          width: 620,
        )))!;
    expect(png, isNotEmpty);
  });
}
