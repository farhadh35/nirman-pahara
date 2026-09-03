import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/util/bn.dart';
import '../logic/lookup_tables.dart';

/// The "what should it be?" screen — mix ratios, curing days, striking times,
/// sand fineness, cost share. A reader standing at a pour or reading a bill
/// wants the number the work is being checked against, not a calculator.
///
/// Reached with no arguments: the pack is loaded here, not passed in, so any
/// entry point can push this screen directly.
class LookupsScreen extends StatefulWidget {
  const LookupsScreen({super.key});

  @override
  State<LookupsScreen> createState() => _LookupsScreenState();
}

class _LookupsScreenState extends State<LookupsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Free text, not a number field carrying an answer — no digit seeding
    // needed here.
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    return Scaffold(
      appBar: AppBar(
        title: Text(bn ? 'মাপ ও তালিকা' : 'Standards & tables'),
      ),
      body: ContentBuilder<LookupPack>(
        future: context.content.lookups(),
        builder: (context, pack) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: bn
                      ? 'যেমন: প্লাস্টার, কিউরিং, সাটারিং'
                      : 'e.g. plaster, curing, formwork',
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: bn ? 'মুছুন' : 'Clear',
                          onPressed: () => _searchController.clear(),
                        ),
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            Expanded(child: _Results(pack: pack, query: _query)),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.pack, required this.query});

  final LookupPack pack;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bn = context.locale.isBangla;
    final q = query.trim();

    final entries = <(LookupTable table, List<LookupRow> rows)>[
      for (final table in pack.tables)
        if (table.search(q).isNotEmpty) (table, table.search(q)),
    ];

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            bn
                ? 'এই লেখায় কিছু পাওয়া যায়নি। অন্য বানানে খুঁজে দেখুন।'
                : 'Nothing matches that. Try a different word.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        if (q.isEmpty) ...[
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                context.t(pack.note),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        for (final entry in entries) ...[
          _TableCard(table: entry.$1, rows: entry.$2),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.rows});

  final LookupTable table;
  final List<LookupRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: context.t(table.title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t(table.lead),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final row in rows) _LookupRowTile(row: row),
          if (table.footer != null) ...[
            const Divider(height: 20),
            Text(
              context.t(table.footer!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LookupRowTile extends StatelessWidget {
  const _LookupRowTile({required this.row});

  final LookupRow row;

  void _showSource(BuildContext context) {
    final locale = context.locale;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.subject.of(locale),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(context.t(S.sources),
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Text(row.source, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              ReviewBadge(status: row.status),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extra = context.t(row.extra);
    return InkWell(
      onTap: () => _showSource(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    context.t(row.subject),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  // Stored western, shown in the reader's script — the row's
                  // second column was already Bangla, so "28" sat next to
                  // "২০ ঘণ্টা" in the same line.
                  Bn.localiseDigits(row.value, context.locale),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.info_outline,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
            if (extra.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  extra,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ReviewBadge(status: row.status),
          ],
        ),
      ),
    );
  }
}
