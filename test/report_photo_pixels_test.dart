import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nirman_pahara/core/content/checklist_models.dart';
import 'package:nirman_pahara/core/content/content_repository.dart';
import 'package:nirman_pahara/core/i18n/app_locale.dart';
import 'package:nirman_pahara/features/inspection/logic/inspection_run.dart';
import 'package:nirman_pahara/features/inspection/logic/photo_ref.dart';
import 'package:nirman_pahara/features/inspection/report/report_document.dart';
import 'package:nirman_pahara/features/inspection/report/report_sheet.dart';

Future<String> _fromDisk(String path) => File(path).readAsString();

/// Does the photograph actually reach the page?
///
/// The existing layout test compares the size of the rendered PNG with and
/// without a photograph, which grows either way because the layout reserves
/// the box whether or not anything is painted into it. So it would pass on a
/// report with an empty white rectangle where the evidence should be. This
/// looks for the photograph's own colour in the output instead.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a photograph is painted into the page, not just given room',
      () async {
    final repo = ContentRepository(reader: _fromDisk);
    final road = (await repo.checklistById('road_rural'))!;

    final dir = Directory.systemTemp.createTempSync('pixels');
    addTearDown(() => dir.deleteSync(recursive: true));

    // Magenta, deliberately: the sheet's own palette is ink, grey, green and
    // the alert red #C62828 — and an earlier version of this test looked for
    // crimson, which matched that red and counted the section heading as
    // though it were the photograph. Nothing on this page can produce magenta,
    // so finding it is proof the image itself was drawn.
    final swatch = img.Image(width: 64, height: 64);
    img.fill(swatch, color: img.ColorRgb8(255, 0, 255));
    final file = File('${dir.path}/red.jpg')
      ..writeAsBytesSync(img.encodeJpg(swatch, quality: 100));

    final run = InspectionRun(
      id: 'r1',
      pack: road,
      projectName: 'Ward 3 road',
      location: 'Palashbari',
      tenderId: 'LGED-2026-0142',
      date: DateTime(2026, 7, 12, 9, 30),
    );
    final finding = run.findings.values.first
      ..answer = ItemAnswer.problem
      ..note = 'seen at 9am'
      ..photos.add(PhotoRef(name: 'red.jpg', takenAt: DateTime(2026, 7, 12)));
    expect(finding.hasPhotos, isTrue);

    final png = await const ReportDocument().rasterise(
      ReportSheet(
        run: run,
        locale: AppLocale.bn,
        photoFiles: {'red.jpg': file},
      ),
      width: 620,
    );

    final out = img.decodePng(png)!;
    var magenta = 0;
    for (var y = 0; y < out.height; y++) {
      for (var x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);
        if (p.r > 200 && p.g < 70 && p.b > 200) magenta++;
      }
    }
    expect(magenta, greaterThan(200),
        reason: 'the photograph never reached the page: the report has a box '
            'where the evidence should be, and nothing says so');
  });
}
