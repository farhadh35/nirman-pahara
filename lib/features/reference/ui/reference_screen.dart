import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../core/content/models.dart';
import '../../guide/ui/guide_screens.dart';

/// The engineer's reference tier.
///
/// Reached only from its own entry at the bottom of home, never from the guide
/// list: [GuidePack.forTrack] excludes these modules and [GuidePack.reference]
/// returns exactly them, so the two lists cannot overlap.
///
/// The separation is the point. A homeowner working out whether their plaster is
/// thick enough should not have to scroll past pile group efficiency, and a
/// sub-assistant engineer looking for tie beam detailing should not have to wade
/// through what a brick is.
class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bn = context.locale.isBangla;
    return Scaffold(
      appBar: AppBar(
        title: Text(bn ? 'প্রকৌশলীর রেফারেন্স' : "Engineer's reference"),
      ),
      body: ContentBuilder<GuidePack>(
        future: context.content.guide(),
        builder: (context, pack) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  bn
                      ? 'এই অংশ প্রকৌশলী, সাইট সুপারভাইজার ও উপ-সহকারী প্রকৌশলীদের '
                          'জন্য। এখানকার মাপ ও ডিটেইল নকশার বিকল্প নয় — সাইটের '
                          'অনুমোদিত নকশাই চূড়ান্ত।'
                      : 'This section is for engineers, site supervisors and '
                          'sub-assistant engineers. Nothing here replaces a '
                          "drawing: the site's approved drawing governs.",
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final m in pack.reference) ...[
              Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          ],
        ),
      ),
    );
  }
}
