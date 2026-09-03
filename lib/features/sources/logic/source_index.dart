import '../../../core/content/checklist_models.dart';
import '../../../core/content/models.dart';
import '../../../core/i18n/app_locale.dart';
import '../../lookups/logic/lookup_tables.dart';
import '../../prices/logic/price_models.dart';
import 'reference_work.dart';

/// One place a source is used.
class SourceUse {
  const SourceUse({
    required this.area,
    required this.where,
    required this.clause,
    required this.status,
  });

  /// Which part of the app — the guide, a checklist, the tables, the prices.
  final L10nText area;

  /// The card, item or row that rests on it.
  final String where;

  /// The clause or item number inside the source, where one is known.
  final String clause;

  final ReviewStatus status;
}

/// Everything the app cites, gathered under the source that carries it.
///
/// The app used to hang a "সূত্র" button off every card, every checklist item,
/// every table row and both price screens — a hundred and seventy-seven of
/// them. Each opened a sheet naming one or two sources, which meant a reader
/// who wanted to know what the app rests on had to walk the whole app to find
/// out, and a reader who did not care had a button in the way on every screen.
///
/// One page instead, with each source named once and every place it is used
/// listed under it. The amber "not yet checked" badge stays where the claim is,
/// because that is a warning about the sentence in front of you rather than a
/// reference.
class SourceIndex {
  const SourceIndex(this.entries);

  final List<SourceEntry> entries;

  bool get isEmpty => entries.isEmpty;

  int get useCount =>
      entries.fold(0, (sum, e) => sum + e.uses.length);

  List<SourceEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries;
    return [
      for (final e in entries)
        if (e.matches(q)) e,
    ];
  }

  /// Gathers from every pack that carries a citation.
  ///
  /// Anything with no source at all is simply absent — this page is a
  /// bibliography, not an inventory, and a card that states no number
  /// legitimately cites nothing.
  static SourceIndex build({
    required GuidePack guide,
    required List<ChecklistPack> checklists,
    required LookupPack lookups,
    required PricePack prices,
    required AppLocale locale,
  }) {
    final bySource = <String, List<SourceUse>>{};
    final label = <String, L10nText>{};

    void add(L10nText source, SourceUse use) {
      final raw = source.bn.trim();
      if (raw.isEmpty) return;
      // Cite at the precision the claim needs, list at the level of the work:
      // "BNBC 2020, পার্ট ৬ — ল্যাপ ও ডেভেলপমেন্ট লেংথ" is BNBC 2020 on a
      // reference list, not a fifth separate code.
      final work = ReferenceWork.match(raw);
      final key = work?.id ?? raw;
      label.putIfAbsent(key, () => work?.title ?? source);
      bySource.putIfAbsent(key, () => []).add(use);
    }

    const guideArea = L10nText('শিখুন', 'Guide');
    for (final module in [...guide.modules, ...guide.reference]) {
      for (final card in module.cards) {
        for (final c in card.citations) {
          add(
            c.source,
            SourceUse(
              area: guideArea,
              where: '${module.code} · ${card.title.of(locale)}',
              clause: c.clause?.of(locale) ?? '',
              status: c.status,
            ),
          );
        }
      }
    }

    const checkArea = L10nText('পরিদর্শন', 'Inspection');
    for (final pack in checklists) {
      for (final stage in pack.stages) {
        for (final item in stage.items) {
          for (final c in item.citations) {
            add(
              c.source,
              SourceUse(
                area: checkArea,
                where: '${pack.title.of(locale)} · ${item.question.of(locale)}',
                clause: c.clause?.of(locale) ?? '',
                status: c.status,
              ),
            );
          }
        }
      }
    }

    const tableArea = L10nText('মাপ ও তালিকা', 'Tables');
    for (final table in lookups.tables) {
      for (final row in table.rows) {
        if (row.source.trim().isEmpty) continue;
        add(
          L10nText(row.source, row.source),
          SourceUse(
            area: tableArea,
            where: '${table.title.of(locale)} · ${row.subject.of(locale)}',
            clause: '',
            status: row.status,
          ),
        );
      }
    }

    const priceArea = L10nText('দাম যাচাই', 'Prices');
    for (final m in prices.materials) {
      for (final c in m.sources) {
        add(
          c.source,
          SourceUse(
            area: priceArea,
            where: m.name.of(locale),
            clause: c.clause?.of(locale) ?? '',
            status: c.status,
          ),
        );
      }
    }
    for (final b in prices.benchmarks) {
      for (final c in b.sources) {
        add(
          c.source,
          SourceUse(
            area: priceArea,
            where: b.country.of(locale),
            clause: c.clause?.of(locale) ?? '',
            status: c.status,
          ),
        );
      }
    }

    final entries = [
      for (final key in bySource.keys)
        SourceEntry(
          source: label[key]!,
          uses: bySource[key]!,
          work: ReferenceWork.all.where((w) => w.id == key).firstOrNull,
        ),
    ]..sort((a, b) {
        // Grouped by kind on the page, so order within a kind is alphabetical.
        final byKind = a.kindOrder.compareTo(b.kindOrder);
        return byKind != 0 ? byKind : a.source.bn.compareTo(b.source.bn);
      });
    return SourceIndex(entries);
  }
}

class SourceEntry {
  const SourceEntry({
    required this.source,
    required this.uses,
    this.work,
  });

  final L10nText source;
  final List<SourceUse> uses;

  /// Null when a citation matched no known work and stands as its own entry.
  final ReferenceWork? work;

  WorkKind get kind => work?.kind ?? WorkKind.practice;

  /// The number printed beside this entry, and beside every claim that
  /// rests on it. Null only for a source matching no known work.
  int? get number => work?.number;

  int get kindOrder => WorkKind.values.indexOf(kind);

  bool matches(String lowerQuery) =>
      source.bn.toLowerCase().contains(lowerQuery) ||
      (source.en ?? '').toLowerCase().contains(lowerQuery) ||
      uses.any((u) =>
          u.where.toLowerCase().contains(lowerQuery) ||
          u.area.bn.toLowerCase().contains(lowerQuery) ||
          (u.area.en ?? '').toLowerCase().contains(lowerQuery));
}
