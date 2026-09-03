import 'package:flutter/foundation.dart';
import 'boq_models.dart';

/// Reads a rate schedule out of tabular rows — a spreadsheet, or the cells of
/// a table in a Word document.
///
/// Far more reliable than reading the same table out of flowed text, because
/// the columns are already separated. The header row is located by looking for
/// the words the departmental statements actually use, so a sheet with an
/// extra title row above the table still works.
class ScheduleRowParser {
  const ScheduleRowParser();

  // 's.l' and 'sl.' are here because real sheets head the column "S.L No.",
  // which contains neither 'sl' nor 'serial'.
  static const _serialWords = ['sl', 's.l', 'sl.', 'serial', 'item', 'no.',
      'ক্রমিক'];
  static const _descWords = ['description', 'particular', 'বিবরণ', 'কাজ'];
  static const _unitWords = ['unit', 'একক'];
  static const _scheduleQtyWords = ['schedule quantity', 'scheduled quantity',
      'schedule qty', 'তফসিল পরিমাণ'];
  static const _measuredQtyWords = ['measued quantity', 'measured quantity',
      'measured qty', 'মাপা পরিমাণ'];
  /// Used only when neither a scheduled nor a measured quantity column was
  /// named. An estimate heads its column plain "Quantity"; matching that
  /// eagerly would swallow "Measured Quantity" on a running bill and set the
  /// two columns against each other the wrong way round.
  static const _bareQtyWords = ['quantity', 'qty', 'পরিমাণ'];
  /// Same reasoning as [_bareQtyWords]: an estimate heads its money column
  /// plainly "Amount", and without this its arithmetic cannot be checked.
  static const _bareAmtWords = ['amount', 'টাকা'];
  static const _rateWords = ['rate', 'দর', 'রেট'];
  static const _scheduleAmtWords = ['schedule amount', 'তফসিল টাকা'];
  static const _measuredAmtWords = ['measured amount', 'measued amount',
      'মাপা টাকা'];

  /// The Bangla column headings this parser can actually find.
  ///
  /// The Right to Information letter in assets/content/rights.json asks an
  /// office to supply a BoQ with these columns kept separate, because a sheet
  /// headed any other way imports with the quantity or the amount missing and
  /// every line then looks as though it was billed against nothing. The letter
  /// and this list have to say the same thing, so a test holds them together:
  /// widening the parser without widening the letter is fine, but narrowing it
  /// leaves the reader asking for a shape the app can no longer read.
  @visibleForTesting
  static const columnHeadingsBn = <String>[
    'ক্রমিক',
    'বিবরণ',
    'একক',
    'পরিমাণ',
    'দর',
    'টাকা',
    'তফসিল পরিমাণ',
    'মাপা পরিমাণ',
  ];

  BoqDocument parse(List<List<String>> rows, {String title = ''}) {
    final header = _findHeader(rows);
    if (header == null) {
      return BoqDocument(title: title, lines: const []);
    }
    final map = _columns(rows[header]);
    final lines = <BoqLine>[];
    double? statedSchedule;
    double? statedMeasured;
    var totalRows = 0;

    var serial = '';
    for (var r = header + 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.every((c) => c.trim().isEmpty)) continue;

      final joined = row.join(' ').toLowerCase();
      if (joined.contains('total')) {
        totalRows++;
        statedSchedule ??= _num(_cell(row, map['scheduleAmount']));
        statedMeasured ??= _num(_cell(row, map['measuredAmount']));
        continue;
      }

      final thisSerial = _cell(row, map['serial']).trim();
      if (thisSerial.isNotEmpty) serial = thisSerial;

      final description = _cell(row, map['description']).trim();
      final scheduleQty = _num(_cell(row, map['scheduleQuantity']));
      final measuredQty = _num(_cell(row, map['measuredQuantity']));
      final rate = _num(_cell(row, map['rate']));
      final scheduleAmt = _num(_cell(row, map['scheduleAmount']));
      final measuredAmt = _num(_cell(row, map['measuredAmount']));

      final hasFigures = [scheduleQty, measuredQty, rate, scheduleAmt,
              measuredAmt]
          .any((v) => v != null && v != 0);
      if (description.isEmpty && !hasFigures) continue;

      lines.add(BoqLine(
        serial: serial,
        description: description,
        unit: _cell(row, map['unit']).trim().isEmpty
            ? null
            : _cell(row, map['unit']).trim(),
        scheduleQuantity: scheduleQty,
        measuredQuantity: measuredQty,
        rate: rate,
        scheduleAmount: scheduleAmt,
        measuredAmount: measuredAmt,
        // In a spreadsheet the columns are named, so their meaning is not in
        // doubt the way it is when reading flowed text.
        columnsTrusted: true,
      ));
    }

    return BoqDocument(
      title: title,
      lines: lines,
      statedScheduleTotal: statedSchedule,
      statedMeasuredTotal: statedMeasured,
      totalRowCount: totalRows,
      hasMeasuredColumn: map['measuredQuantity'] != null ||
          map['measuredAmount'] != null,
    );
  }

  int? _findHeader(List<List<String>> rows) {
    for (var i = 0; i < rows.length && i < 30; i++) {
      final joined = rows[i].join(' ').toLowerCase();
      final hits = [
        _descWords.any(joined.contains),
        _unitWords.any(joined.contains),
        _rateWords.any(joined.contains) ||
            _scheduleQtyWords.any(joined.contains) ||
            _bareQtyWords.any(joined.contains),
      ].where((h) => h).length;
      if (hits >= 2) return i;
    }
    return null;
  }

  Map<String, int?> _columns(List<String> header) {
    int? find(List<String> words) {
      for (var i = 0; i < header.length; i++) {
        final h = header[i].toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        if (words.any(h.contains)) return i;
      }
      return null;
    }

    // Amount columns must be matched before the bare "rate"/"quantity" words,
    // which would otherwise swallow them.
    var scheduleQty = find(_scheduleQtyWords);
    final measuredQty = find(_measuredQtyWords);
    // An estimate names one plain "Quantity" column. Without this the sheet
    // imports with no quantity at all, and every line then looks as though it
    // was billed against nothing.
    scheduleQty ??= measuredQty == null ? find(_bareQtyWords) : null;
    var scheduleAmt = find(_scheduleAmtWords);
    final measuredAmt = find(_measuredAmtWords);
    scheduleAmt ??= measuredAmt == null ? find(_bareAmtWords) : null;
    return {
      'serial': find(_serialWords),
      'description': find(_descWords),
      'unit': find(_unitWords),
      'scheduleQuantity': scheduleQty,
      'measuredQuantity': measuredQty,
      'scheduleAmount': scheduleAmt,
      'measuredAmount': measuredAmt,
      'rate': find(_rateWords),
    };
  }

  String _cell(List<String> row, int? index) =>
      index == null || index >= row.length ? '' : row[index];

  double? _num(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t == '-') return null;
    final negative = t.startsWith('(') && t.endsWith(')');
    final cleaned = t.replaceAll(RegExp(r'[(),\s৳]'), '');
    if (cleaned.isEmpty) return null;
    final v = double.tryParse(cleaned);
    if (v == null) return null;
    return negative ? -v : v;
  }
}
