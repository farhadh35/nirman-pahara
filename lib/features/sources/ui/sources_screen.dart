import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../core/content/checklist_models.dart';
import '../../../core/content/models.dart';
import '../../../core/util/bn.dart';
import '../../lookups/logic/lookup_tables.dart';
import '../../prices/logic/price_models.dart';
import '../logic/reference_work.dart';
import '../logic/source_index.dart';

/// The works this app is built on, listed once each.
///
/// A source button used to hang off every card, every checklist item, every
/// table row and both price screens. Collected here they came to a hundred and
/// twelve entries, most of them the same work cited at different depths —
/// BNBC 2020 five times over, the 2019 book twenty times by chapter. A list
/// that repeats itself is not a reference list, so the entries are works.
class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key, this.focus});

  /// The reference number the reader tapped to get here, if any. That entry is
  /// scrolled to and marked, because arriving at the top of a list of
  /// twenty-one works and hunting for number five is not an answer.
  final int? focus;

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  final _focusKey = GlobalKey();
  bool _scrolled = false;

  Future<SourceIndex> _load(BuildContext context) async {
    final content = context.content;
    final locale = context.locale;
    final packs = await Future.wait<Object>([
      content.guide(),
      content.checklists(),
      content.lookups(),
      content.prices(),
    ]);
    return SourceIndex.build(
      guide: packs[0] as GuidePack,
      checklists: packs[1] as List<ChecklistPack>,
      lookups: packs[2] as LookupPack,
      prices: packs[3] as PricePack,
      locale: locale,
    );
  }

  void _revealFocus() {
    if (_scrolled || widget.focus == null) return;
    final target = _focusKey.currentContext;
    if (target == null) return;
    _scrolled = true;
    Scrollable.ensureVisible(target,
        duration: const Duration(milliseconds: 250), alignment: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    return Scaffold(
      appBar: AppBar(title: Text(bn ? 'সূত্র' : 'References')),
      body: ContentBuilder<SourceIndex>(
        future: _load(context),
        builder: (context, index) => _list(context, index),
      ),
    );
  }

  Widget _list(BuildContext context, SourceIndex index) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealFocus());
    final theme = Theme.of(context);
    final locale = context.locale;

    // Grouped by the heading, not by the enum value. Two kinds share the words
    // "codes and standards" — a building code and a materials standard belong
    // under one heading — and grouping by the value printed that heading twice,
    // on the page whose entire point is that nothing appears twice.
    final byHeading = <String, List<SourceEntry>>{};
    for (final kind in WorkKind.values) {
      for (final e in index.entries) {
        if (e.kind != kind) continue;
        byHeading.putIfAbsent(kind.label.of(locale), () => []).add(e);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        for (final heading in byHeading.keys) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                heading,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final entry in byHeading[heading]!)
              Container(
                key: entry.number == widget.focus ? _focusKey : null,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: entry.number == widget.focus
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text(
                        entry.number == null
                            ? ''
                            : Bn.localiseDigits('${entry.number}', locale),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.source.of(locale),
                              style: theme.textTheme.bodyLarge),
                          if (entry.work?.detail != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                entry.work!.detail!.of(locale),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
          ],
      ],
    );
  }
}
