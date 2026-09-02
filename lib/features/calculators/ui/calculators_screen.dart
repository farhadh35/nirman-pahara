import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/i18n/strings.dart';
import 'calc_spec.dart';
import 'calculator_screen.dart';

/// The calculators, grouped by the moment on a site a person reaches for them.
///
/// A flat list stopped working once there were more than a handful: a reader
/// scanning twenty titles for "the one about the truck that just arrived" is
/// reading a glossary, not finding a tool. The headings are situations —
/// a delivery turning up, a pour starting, a wall being finished — because that
/// is what the reader knows they are in the middle of. What material the tool
/// happens to work on is the last thing they are thinking about.
class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final groups = CalcSpec.groups;

    return Scaffold(
      appBar: AppBar(title: Text(context.t(S.calculate))),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: groups.length,
        itemBuilder: (context, gi) {
          final group = groups[gi];
          final specs = CalcSpec.inGroup(group);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(top: gi == 0 ? 8 : 28, bottom: 2),
                child: Text(
                  group.title.of(locale),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  group.subtitle.of(locale),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              for (final spec in specs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      title: Text(spec.title.of(locale),
                          style: theme.textTheme.titleMedium),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(spec.subtitle.of(locale)),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CalculatorScreen(spec: spec),
                        ),
                      ),
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
