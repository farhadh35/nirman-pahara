import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../core/content/checklist_models.dart';
import '../../../core/content/models.dart';
import '../../../core/util/bn.dart';
import '../../lookups/logic/lookup_tables.dart';
import '../../prices/logic/price_models.dart';
import '../logic/source_index.dart';

/// Everything the app rests on, in one place.
///
/// A source button used to hang off every card, every checklist item, every
/// table row and both price screens. That put a reference affordance in front
/// of readers who wanted to read, and still left anyone asking "what is this
/// app based on?" with no way to answer except walking the whole of it.
class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<SourceIndex> _load(BuildContext context) async {
    final content = context.content;
    final locale = context.locale;
    final results = await Future.wait<Object>([
      content.guide(),
      content.checklists(),
      content.lookups(),
      content.prices(),
    ]);
    return SourceIndex.build(
      guide: results[0] as GuidePack,
      checklists: results[1] as List<ChecklistPack>,
      lookups: results[2] as LookupPack,
      prices: results[3] as PricePack,
      locale: locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    return Scaffold(
      appBar: AppBar(title: Text(bn ? 'সূত্র' : 'Sources')),
      body: ContentBuilder<SourceIndex>(
        future: _load(context),
        builder: (context, index) => _body(context, index),
      ),
    );
  }

  Widget _body(BuildContext context, SourceIndex index) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final bn = locale.isBangla;
    final shown = index.search(_search.text);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: bn
                  ? 'যেমন: BNBC, তফসিল, বিধিমালা'
                  : 'e.g. BNBC, schedule, gazette',
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _search.clear(),
                    ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              if (_search.text.isEmpty) ...[
                Text(
                  bn
                      ? '${Bn.digits('${index.useCount}')}টি কারিগরি বক্তব্য '
                          '${Bn.digits('${index.entries.length}')}টি সূত্রের '
                          'উপর দাঁড়ানো। এর '
                          '${Bn.digits('${index.pendingCount}')}টি প্রকৌশলীর '
                          'যাচাই বাকি, অ্যাপে হলুদ চিহ্ন দেওয়া।'
                      : '${index.useCount} technical statements, resting on '
                          '${index.entries.length} sources. '
                          '${index.pendingCount} await an engineer\'s check '
                          'and are marked amber in the app.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
              ],
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    bn ? 'কোনো সূত্র মেলেনি।' : 'No matching source.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              for (final entry in shown) _SourceCard(entry: entry),
            ],
          ),
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.entry});

  final SourceEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final bn = locale.isBangla;

    // Grouped by area so a reader can see at a glance whether a source is
    // behind the guide, the checklists, the tables or the prices.
    final byArea = <String, List<SourceUse>>{};
    for (final u in entry.uses) {
      byArea.putIfAbsent(u.area.of(locale), () => []).add(u);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: Text(entry.source.of(locale),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                bn
                    ? '${Bn.digits('${entry.uses.length}')}টি বক্তব্যে'
                    : '${entry.uses.length} statement'
                        '${entry.uses.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (entry.pending > 0) ...[
                const SizedBox(width: 8),
                const ReviewBadge(status: ReviewStatus.review),
              ],
            ],
          ),
        ),
        children: [
          for (final area in byArea.keys) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(area,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
            ),
            for (final use in byArea[area]!)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(use.where,
                              style: theme.textTheme.bodyMedium),
                          if (use.clause.isNotEmpty)
                            Text(
                              use.clause,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
