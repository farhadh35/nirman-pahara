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

  static const _serialWords = ['sl', 'serial', 'item', 'ক্রমিক'];
  static const _descWords = ['description', 'particular', 'বিবরণ', 'কাজ'];
  static const _unitWords = ['unit', 'একক'];
  static const _scheduleQtyWords = ['schedule quantity', 'scheduled quantity',
      'schedule qty', 'তফসিল পরিমাণ'];
  static const _measuredQtyWords = ['measued quantity', 'measured quantity',
      'measured qty', 'মাপা পরিমাণ'];
  static const _rateWords = ['rate', 'দর', 'রেট'];
  static const _scheduleAmtWords = ['schedule amount', 'তফসিল টাকা'];
  static const _measuredAmtWords = ['measured amount', 'measued amount',
      'মাপা টাকা'];

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
    );
  }

  int? _findHeader(List<List<String>> rows) {
    for (var i = 0; i < rows.length && i < 30; i++) {
      final joined = rows[i].join(' ').toLowerCase();
      final hits = [
        _descWords.any(joined.contains),
        _unitWords.any(joined.contains),
        _rateWords.any(joined.contains) ||
            _scheduleQtyWords.any(joined.contains),
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
    return {
      'serial': find(_serialWords),
      'description': find(_descWords),
      'unit': find(_unitWords),
      'scheduleQuantity': find(_scheduleQtyWords),
      'measuredQuantity': find(_measuredQtyWords),
      'scheduleAmount': find(_scheduleAmtWords),
      'measuredAmount': find(_measuredAmtWords),
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
