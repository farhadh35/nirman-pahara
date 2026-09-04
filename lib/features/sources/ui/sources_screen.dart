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
  final _controller = ScrollController();
  bool _scrolled = false;
  int _attempts = 0;

  /// Where the focused entry sits in the list, and how many entries there are.
  /// Only needed when that entry has not been built yet — see [_revealFocus].
  int? _focusIndex;
  int _entryCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  /// Bring the tapped entry into view.
  ///
  /// The obvious version — hang a GlobalKey on the entry and call
  /// [Scrollable.ensureVisible] — works only for an entry already on screen. A
  /// ListView builds just the children its viewport can see, so for anything
  /// below the fold the key has no context and ensureVisible does nothing at
  /// all, silently: the reader taps [২১] and arrives at the top of the page
  /// with no idea which of twenty-one works they asked for. On a phone that is
  /// most of them.
  ///
  /// So: jump to roughly where the entry must be, let the viewport build it,
  /// then ask again on the next frame and scroll exactly. The estimate is
  /// crude — headings make entries uneven — but it only has to get close
  /// enough for the target to be built, and each pass gets closer.
  void _revealFocus() {
    if (_scrolled || widget.focus == null || !mounted) return;
    if (!_controller.hasClients) return;

    final target = _focusKey.currentContext;
    if (target != null) {
      _scrolled = true;
      Scrollable.ensureVisible(target,
          duration: const Duration(milliseconds: 250), alignment: 0.15);
      return;
    }

    // Not built yet. Give up rather than loop if the entry does not exist, or
    // if the estimate stops moving.
    if (_focusIndex == null || _entryCount == 0 || _attempts >= 6) {
      _scrolled = true;
      return;
    }
    _attempts++;
    final max = _controller.position.maxScrollExtent;
    final approx = (max * (_focusIndex! / _entryCount)).clamp(0.0, max);
    if ((approx - _controller.offset).abs() < 1) {
      _scrolled = true;
      return;
    }
    _controller.jumpTo(approx);
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealFocus());
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

    // Flat position of each entry, so an unbuilt focus target can still be
    // aimed at. Counted over the same order the page renders in.
    _entryCount = 0;
    _focusIndex = null;
    for (final heading in byHeading.keys) {
      for (final e in byHeading[heading]!) {
        if (e.number != null && e.number == widget.focus) {
          _focusIndex = _entryCount;
        }
        _entryCount++;
      }
    }

    return ListView(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Google Play rejected this app for showing government figures — the
        // PWD rate schedules, the building code, the gazette — without saying
        // where they came from or who the app is. Both halves of that are
        // fixed here: every government work below carries the address its
        // publisher issues it from, and this says plainly that reproducing a
        // figure is not the same as speaking for the office that set it.
        CautionBox(
          icon: Icons.account_balance_outlined,
          text: locale.isBangla
              ? 'নির্মাণ পাহারা কোনো সরকারি দপ্তর নয় এবং কোনো সরকারি সংস্থার '
                  'সঙ্গে যুক্ত নয়। নিচের সরকারি নথিগুলোর তথ্য এখানে তুলে ধরা '
                  'হয়েছে মাত্র; প্রতিটির সঙ্গে প্রকাশকের নিজস্ব ঠিকানা দেওয়া '
                  'আছে, মিলিয়ে দেখে নিন।'
              : 'Nirman Pahara is not a government body and is not affiliated '
                  'with or endorsed by any government entity. The government '
                  'documents below are reproduced here for reference only; '
                  'each carries the address its own publisher issues it from, '
                  'so you can check it against the original.',
        ),
        const SizedBox(height: 16),
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
                          // Selectable rather than tappable: the app opens no
                          // browser and asks for no network, so the address is
                          // put where it can be read and copied instead of
                          // hidden behind a link that would need both.
                          if (entry.work?.url != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: SelectableText(
                                entry.work!.url!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  height: 1.4,
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
