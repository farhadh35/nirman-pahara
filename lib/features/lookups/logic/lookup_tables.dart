import '../../../core/content/models.dart';
import '../../../core/i18n/app_locale.dart';

/// The "what should it be?" tables.
///
/// Not calculators. A person standing at a pour does not want to enter numbers;
/// they want to know whether 1:6 was right for that wall, how many days the
/// slab should have been watered, and whether the shuttering could come off
/// today. These are the answers, each carrying where it came from.
class LookupPack {
  const LookupPack({
    required this.version,
    required this.note,
    required this.tables,
  });

  final String version;
  final L10nText note;
  final List<LookupTable> tables;

  LookupTable? byId(String id) {
    for (final t in tables) {
      if (t.id == id) return t;
    }
    return null;
  }

  factory LookupPack.fromJson(Map<String, dynamic> j) => LookupPack(
        version: j['version'] as String,
        note: _text(j['note'])!,
        tables: [
          for (final t in j['tables'] as List)
            LookupTable.fromJson((t as Map).cast<String, dynamic>()),
        ],
      );
}

class LookupTable {
  const LookupTable({
    required this.id,
    required this.title,
    required this.lead,
    required this.columns,
    required this.rows,
    this.footer,
  });

  final String id;
  final L10nText title;

  /// Why this table matters, in the reader's terms.
  final L10nText lead;

  final List<L10nText> columns;
  final List<LookupRow> rows;

  /// The caveat that keeps the table from being read as more than it is.
  final L10nText? footer;

  /// Rows whose subject or value answers [query].
  List<LookupRow> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return [
      for (final r in rows)
        if (r.matches(q)) r,
    ];
  }

  factory LookupTable.fromJson(Map<String, dynamic> j) => LookupTable(
        id: j['id'] as String,
        title: _text(j['title'])!,
        lead: _text(j['lead'])!,
        columns: [
          for (final c in j['columns'] as List) _text(c)!,
        ],
        rows: [
          for (final r in j['rows'] as List)
            LookupRow.fromJson((r as Map).cast<String, dynamic>()),
        ],
        footer: _text(j['footer']),
      );
}

class LookupRow {
  const LookupRow({
    required this.subject,
    required this.value,
    required this.extra,
    required this.status,
    required this.source,
  });

  /// What the row is about — the work, the member, the material.
  final L10nText subject;

  /// The answer, as printed.
  final String value;

  /// A second column where the table has one; empty otherwise.
  final L10nText extra;

  final ReviewStatus status;

  /// Where the figure came from, shown on the সূত্র tap.
  final String source;

  bool matches(String lowerQuery) =>
      subject.bn.toLowerCase().contains(lowerQuery) ||
      (subject.en ?? '').toLowerCase().contains(lowerQuery) ||
      value.toLowerCase().contains(lowerQuery);

  factory LookupRow.fromJson(Map<String, dynamic> j) => LookupRow(
        subject: _text(j['k'])!,
        value: j['v'] as String,
        extra: _text(j['x']) ?? const L10nText('', ''),
        status: ReviewStatus.parse(j['status'] as String?),
        source: j['src'] as String,
      );
}

L10nText? _text(Object? raw) {
  if (raw is! Map) return null;
  return L10nText(raw['bn'] as String, raw['en'] as String?);
}
