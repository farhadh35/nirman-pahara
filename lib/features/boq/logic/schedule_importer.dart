import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:xml/xml.dart';

import '../../../core/i18n/app_locale.dart';
import 'boq_models.dart';
import 'boq_text_parser.dart';
import 'schedule_row_parser.dart';

/// Which route a file took through the importer, so the screen can say how the
/// document was read and how much to trust it.
enum ImportRoute {
  spreadsheet,
  wordTable,
  text,
  unsupported,
}

class ImportResult {
  const ImportResult({
    required this.route,
    required this.document,
    this.warning,
  });

  final ImportRoute route;
  final BoqDocument document;

  /// Shown above the findings when the reading itself has a caveat.
  final L10nText? warning;

  bool get ok => document.lines.isNotEmpty;
}

/// Reads a departmental rate schedule out of the file the user picked.
///
/// Spreadsheets and Word tables give named columns and are read directly.
/// Plain text is read with the flowed-layout parser, which is more of a guess
/// and is labelled as such. PDF is deliberately not attempted in the app —
/// see [_pdfNotSupported].
class ScheduleImporter {
  const ScheduleImporter();

  static const supportedExtensions = ['xlsx', 'xls', 'csv', 'docx', 'txt'];

  Future<ImportResult> read(File file) async {
    final name = file.path.toLowerCase();
    if (name.endsWith('.xlsx') || name.endsWith('.xls')) {
      return _spreadsheet(file);
    }
    if (name.endsWith('.docx')) return _word(file);
    if (name.endsWith('.csv')) return _csv(file);
    if (name.endsWith('.txt')) return _text(file);
    if (name.endsWith('.pdf')) return _pdfNotSupported();
    return const ImportResult(
      route: ImportRoute.unsupported,
      document: BoqDocument(title: '', lines: []),
      warning: L10nText(
        'এই ধরনের ফাইল পড়া যায় না। এক্সেল (.xlsx), সিএসভি (.csv) বা ওয়ার্ড '
            '(.docx) ফাইল দিন।',
        'This kind of file cannot be read. Use a spreadsheet (.xlsx), a CSV, '
            'or a Word document (.docx).',
      ),
    );
  }

  Future<ImportResult> _spreadsheet(File file) async {
    final book = Excel.decodeBytes(await file.readAsBytes());
    for (final sheet in book.tables.values) {
      final rows = [
        for (final row in sheet.rows)
          [for (final cell in row) cell?.value?.toString() ?? '']
      ];
      final doc = const ScheduleRowParser()
          .parse(rows, title: _titleFrom(rows, file));
      if (doc.lines.isNotEmpty) {
        return ImportResult(route: ImportRoute.spreadsheet, document: doc);
      }
    }
    return ImportResult(
      route: ImportRoute.spreadsheet,
      document: BoqDocument(title: _fileName(file), lines: const []),
      warning: const L10nText(
        'শিটে চেনা কলাম পাওয়া যায়নি। শিরোনামের সারিতে বিবরণ, একক ও রেট — '
            'অন্তত এই কলামগুলো থাকা দরকার।',
        'No recognisable columns were found. The header row needs at least a '
            'description, a unit and a rate.',
      ),
    );
  }

  /// Word documents keep tables as rows of cells, which is exactly the shape
  /// the row parser wants; the text between tables is ignored.
  Future<ImportResult> _word(File file) async {
    final zip = ZipDecoder().decodeBytes(await file.readAsBytes());
    final entry = zip.files.where((f) => f.name == 'word/document.xml');
    if (entry.isEmpty) {
      return ImportResult(
        route: ImportRoute.unsupported,
        document: BoqDocument(title: _fileName(file), lines: const []),
        warning: const L10nText(
          'ওয়ার্ড ফাইলটি পড়া গেল না।',
          'The Word document could not be read.',
        ),
      );
    }
    final xml = XmlDocument.parse(
        utf8.decode(entry.first.content as List<int>, allowMalformed: true));
    final rows = <List<String>>[];
    for (final tr in xml.findAllElements('w:tr')) {
      rows.add([
        for (final tc in tr.findElements('w:tc'))
          tc
              .findAllElements('w:t')
              .map((t) => t.innerText)
              .join()
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim()
      ]);
    }
    if (rows.isEmpty) {
      // No table: fall back to reading the flowed text.
      final text = xml
          .findAllElements('w:p')
          .map((p) => p.findAllElements('w:t').map((t) => t.innerText).join())
          .join('\n');
      return ImportResult(
        route: ImportRoute.text,
        document: const BoqTextParser().parse(text, title: _fileName(file)),
        warning: _textWarning,
      );
    }
    return ImportResult(
      route: ImportRoute.wordTable,
      document:
          const ScheduleRowParser().parse(rows, title: _fileName(file)),
    );
  }

  Future<ImportResult> _csv(File file) async {
    final rows = [
      for (final line in const LineSplitter().convert(await file.readAsString()))
        _splitCsv(line)
    ];
    return ImportResult(
      route: ImportRoute.spreadsheet,
      document:
          const ScheduleRowParser().parse(rows, title: _titleFrom(rows, file)),
    );
  }

  Future<ImportResult> _text(File file) async => ImportResult(
        route: ImportRoute.text,
        document: const BoqTextParser()
            .parse(await file.readAsString(), title: _fileName(file)),
        warning: _textWarning,
      );

  /// PDF is not read in the app.
  ///
  /// Extracting a table out of a PDF means guessing which numbers belong to
  /// which column, and a wrong guess here produces a confident finding about
  /// someone's money that would not survive being questioned. The departments
  /// issue the same statements as spreadsheets, and converting is safer than
  /// guessing.
  ImportResult _pdfNotSupported() => const ImportResult(
        route: ImportRoute.unsupported,
        document: BoqDocument(title: '', lines: []),
        warning: L10nText(
          'পিডিএফ সরাসরি পড়া হয় না — টেবিলের কোন সংখ্যা কোন ঘরের, সেটা আন্দাজ '
              'করতে হয়, আর ভুল আন্দাজ থেকে ভুল অভিযোগ তৈরি হয়। একই কাগজ এক্সেলে '
              'চেয়ে নিন, বা পিডিএফটি এক্সেল/ওয়ার্ডে রূপান্তর করে দিন।',
          'PDFs are not read directly — it means guessing which number belongs '
              'in which column, and a wrong guess becomes a confident claim '
              'about someone\'s money. Ask for the same statement as a '
              'spreadsheet, or convert the PDF to Excel or Word first.',
        ),
      );

  static const _textWarning = L10nText(
    'ফাইলটি সাধারণ লেখা হিসেবে পড়া হয়েছে, তাই কলাম আন্দাজ করে নেওয়া হয়েছে। '
        'ফলাফল মিলিয়ে দেখে নিন।',
    'This file was read as flowed text, so the columns were inferred. Check '
        'the result against the document.',
  );

  String _fileName(File f) => f.uri.pathSegments.last;

  String _titleFrom(List<List<String>> rows, File file) {
    for (final row in rows.take(3)) {
      final joined = row.join(' ').trim();
      if (joined.length > 25) return joined;
    }
    return _fileName(file);
  }

  List<String> _splitCsv(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        quoted = !quoted;
      } else if (ch == ',' && !quoted) {
        out.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    out.add(buf.toString());
    return out;
  }
}
