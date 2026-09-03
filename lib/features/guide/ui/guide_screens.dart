import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../core/content/models.dart';
import '../../../core/i18n/strings.dart';
import '../../sources/ui/sources_screen.dart';
import '../../../core/util/bn.dart';
import '../diagrams/guide_diagrams.dart';

/// The module list — the entry point into the guide.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.t(S.learn))),
      body: ContentBuilder<GuidePack>(
        future: context.content.guide(),
        builder: (context, pack) {
          final modules = pack.forTrack(context.appState.track);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(
                '${context.t(S.updatedOn)}: '
                '${Bn.localiseDigits(pack.updated, context.locale)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              for (final m in modules) ...[
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    title: Text(context.t(m.title),
                        style: theme.textTheme.titleMedium),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(context.t(m.summary)),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GuideModuleScreen(module: m),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              // One link, at the end. The source used to hang off every card,
              // which put a reference affordance in front of someone who came
              // here to read.
              Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(
                      context.locale.isBangla ? 'সূত্র' : 'Sources'),
                  subtitle: Text(context.locale.isBangla
                      ? 'এখানকার প্রতিটি কথা কোথা থেকে এসেছে'
                      : 'Where all of this comes from'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const SourcesScreen()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Card-by-card reader for one module.
class GuideModuleScreen extends StatefulWidget {
  const GuideModuleScreen({super.key, required this.module});

  final GuideModule module;

  @override
  State<GuideModuleScreen> createState() => _GuideModuleScreenState();
}

class _GuideModuleScreenState extends State<GuideModuleScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.module.cards;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t(widget.module.title)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: cards.isEmpty ? 0 : (_page + 1) / cards.length,
            minHeight: 4,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: cards.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, i) => _GuideCardView(card: cards[i]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Text(
                '${Bn.number(_page + 1.0, decimals: 0, locale: context.locale)}'
                ' / '
                '${Bn.number(cards.length.toDouble(), decimals: 0, locale: context.locale)}',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(width: 12),
              if (_page > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _controller.previousPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    ),
                    child: Text(
                      context.t(S.back),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: _page == cards.length - 1
                      ? () => Navigator.of(context).pop()
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                  child: Text(
                    context.t(_page == cards.length - 1 ? S.done : S.next),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCardView extends StatelessWidget {
  const _GuideCardView({required this.card});

  final GuideCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diagram =
        guideDiagram(context, card.diagram, bn: context.locale.isBangla);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Text(context.t(card.title), style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        ReviewBadge(status: card.status),
        const SizedBox(height: 10),
        Text(context.t(card.body), style: theme.textTheme.bodyLarge),
        if (diagram != null) ...[
          const SizedBox(height: 20),
          diagram,
        ],
        if (card.watchFor.isNotEmpty) ...[
          const SizedBox(height: 22),
          SectionCard(
            title: context.t(S.watchFor),
            icon: Icons.visibility_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in card.watchFor)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A bullet, not a checkbox: these are things to look
                        // at, and an empty checkbox invites a tap that does
                        // nothing.
                        Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: Icon(Icons.circle,
                              size: 8, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(context.t(w),
                              style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],

      ],
    );
  }
}
