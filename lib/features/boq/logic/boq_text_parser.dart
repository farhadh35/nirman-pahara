import 'boq_models.dart';

/// Reads a bill of quantities out of the plain text of a departmental
/// statement — the layout produced when the issued PDF is converted to text.
///
/// The real statements are awkward: a description often wraps onto its own
/// line with the figures following underneath, sub-items sit under a parent
/// serial with no serial of their own, and negatives are printed in brackets.
/// The parser therefore carries a pending serial and description forward until
/// it meets the row of figures that belongs to them.
class BoqTextParser {
  const BoqTextParser();

  /// A serial only counts when the rest of the line has words in it. The
  /// figure columns are full of numbers that look like serials otherwise.
  static final _serial = RegExp(r'^\s*(\d{1,2}(?:\.\d{1,2})?)\s{2,}(.*)$');
  static final _unit = RegExp(
      r'\b(Cum|Sqm|sqm|cum|kg|rm|No|no|nos|Nos|each|m|Rft|Sft)\b');
  static final _totalRow = RegExp(r'\b(Grand Total|Total)\b', caseSensitive: false);

  BoqDocument parse(String text, {String title = ''}) {
    final lines = text.split('\n');
    final out = <BoqLine>[];
    var serial = '';
    var description = '';
    String? unit;
    double? statedSchedule;
    double? statedMeasured;
    var totalRows = 0;
    var documentTitle = title;

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) continue;
      if (documentTitle.isEmpty && line.trim().length > 30 &&
          !_looksLikeHeader(line)) {
        documentTitle = line.trim();
      }
      if (_looksLikeHeader(line)) {
        description = '';
        unit = null;
        continue;
      }

      final numbers = _trailingNumbers(line);

      if (_totalRow.hasMatch(line) && numbers.length >= 2) {
        totalRows++;
        // The document's own totals: schedule first, then measured.
        statedSchedule ??= numbers[numbers.length - 3 < 0 ? 0 : numbers.length - 3];
        statedMeasured ??= numbers[numbers.length - 2];
        serial = '';
        description = '';
        continue;
      }

      final m = _serial.firstMatch(line);
      final hasWords = m != null && RegExp(r'[A-Za-z]').hasMatch(m.group(2)!);
      final rest = m == null ? line : m.group(2)!;
      if (m != null && hasWords) serial = m.group(1)!;

      final unitMatch = _unit.firstMatch(rest);
      if (unitMatch != null) unit = unitMatch.group(1);
      final head =
          unitMatch == null ? rest : rest.substring(0, unitMatch.start);
      final text0 = head
          .split(RegExp(r'\s{2,}'))
          .where((f) => _asNumber(f) == null)
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (text0.isNotEmpty) {
        description = description.isEmpty ? text0 : '$description $text0';
      }

      // A priced row carries schedule quantity, measured quantity, the
      // difference, the rate and three amounts. Fewer figures than that means
      // a description line, a spacer, or the document's own title — which is
      // full of digits from the package number and must not become a line.
      if (numbers.length < 5) continue;
      if (serial.isEmpty && unit == null) continue;
      // Spacer rows under a parent item carry nothing but zeros.
      if (numbers.every((n) => n == 0)) {
        description = '';
        continue;
      }

      out.add(BoqLine(
        serial: serial,
        description: _clean(description.isEmpty ? rest.trim() : description),
        unit: unit,
        scheduleQuantity: numbers[0],
        measuredQuantity: numbers[1],
        rate: numbers.length >= 4 ? numbers[3] : null,
        scheduleAmount: numbers.length >= 5 ? numbers[4] : null,
        measuredAmount: numbers.length >= 6 ? numbers[5] : null,
        // The full row is seven figures: two quantities, the difference, the
        // rate and three amounts. Anything shorter means a blank column, and
        // the positions can no longer be trusted.
        columnsTrusted: numbers.length >= 7,
      ));
      description = '';
      unit = null;
    }

    return BoqDocument(
      title: documentTitle,
      lines: out,
      statedScheduleTotal: statedSchedule,
      statedMeasuredTotal: statedMeasured,
      totalRowCount: totalRows,
    );
  }

  /// Column headings sometimes wrap so that a stray word ("Taka" from "Rate
  /// in Taka") lands at the head of the first data row.
  String _clean(String description) => description
      .replaceFirst(RegExp(r'^(Taka|in Taka|Rate in Taka)\s+'), '')
      .trim();

  bool _looksLikeHeader(String line) {
    const markers = [
      'Sl. No.', 'Short Description', 'Schedule', 'Measued', 'Measured',
      'Quantity', 'Page ', 'Rate in', 'Remaining', 'CIVIL WORKS',
      'Works need to done', 'Performed Works', 'Tender ID', 'Package no',
      'Package No', 'Report on',
    ];
    return markers.any(line.contains);
  }

  /// The figures at the end of a row.
  ///
  /// Reading every number on the line pulls digits out of the description
  /// itself — "up to 1.5m depth" is not a quantity — so the columns are taken
  /// as the unbroken run of numeric fields at the right-hand end of the row.
  List<double> _trailingNumbers(String line) {
    final fields = line.trim().split(RegExp(r'\s{2,}'));
    final tail = <double>[];
    for (var i = fields.length - 1; i >= 0; i--) {
      final v = _asNumber(fields[i]);
      if (v == null) break;
      tail.insert(0, v);
    }
    return tail;
  }

  double? _asNumber(String field) {
    final raw = field.trim();
    if (raw.isEmpty) return null;
    if (raw == '-') return 0;
    final negative = raw.startsWith('(') && raw.endsWith(')');
    final cleaned = raw.replaceAll(RegExp(r'[(),]'), '').trim();
    if (cleaned.isEmpty) return null;
    if (!RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(cleaned)) return null;
    final v = double.tryParse(cleaned);
    if (v == null) return null;
    return negative ? -v : v;
  }
}
