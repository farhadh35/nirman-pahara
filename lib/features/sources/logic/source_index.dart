import '../../../core/content/checklist_models.dart';
import '../../../core/content/models.dart';
import '../../../core/i18n/app_locale.dart';
import '../../lookups/logic/lookup_tables.dart';
import '../../prices/logic/price_models.dart';

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

  int get pendingCount => entries.fold(
      0, (sum, e) => sum + e.uses.where((u) => u.status.needsBadge).length);

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
      final key = source.bn.trim();
      if (key.isEmpty) return;
      label.putIfAbsent(key, () => source);
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
        SourceEntry(source: label[key]!, uses: bySource[key]!),
    ]..sort((a, b) {
        // Most-relied-upon first: a source behind forty claims matters more to
        // a reader checking the app than one behind a single row.
        final byUses = b.uses.length.compareTo(a.uses.length);
        return byUses != 0 ? byUses : a.source.bn.compareTo(b.source.bn);
      });
    return SourceIndex(entries);
  }
}

class SourceEntry {
  const SourceEntry({required this.source, required this.uses});

  final L10nText source;
  final List<SourceUse> uses;

  /// True when nothing resting on this source has been signed off yet.
  bool get allPending => uses.every((u) => u.status.needsBadge);

  int get pending => uses.where((u) => u.status.needsBadge).length;

  bool matches(String lowerQuery) =>
      source.bn.toLowerCase().contains(lowerQuery) ||
      (source.en ?? '').toLowerCase().contains(lowerQuery) ||
      uses.any((u) =>
          u.where.toLowerCase().contains(lowerQuery) ||
          u.area.bn.toLowerCase().contains(lowerQuery) ||
          (u.area.en ?? '').toLowerCase().contains(lowerQuery));
}
