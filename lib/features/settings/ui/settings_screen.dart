import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/app_info.dart';
import '../../../app/widgets/common.dart';
import '../../../core/util/bn.dart';
import '../../../core/content/models.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/i18n/strings.dart';
import '../../sources/ui/sources_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final locale = context.locale;

    return Scaffold(
      appBar: AppBar(title: Text(context.t(S.settings))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          SectionCard(
            title: context.t(S.language),
            icon: Icons.translate,
            child: RadioGroup<AppLocale>(
              groupValue: state.locale,
              onChanged: (v) => state.locale = v!,
              child: Column(
                children: [
                  for (final l in AppLocale.values)
                    RadioListTile<AppLocale>(
                      value: l,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.endonym),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.t(S.textSize),
            icon: Icons.format_size,
            child: RadioGroup<TextScalePreference>(
              groupValue: state.textScale,
              onChanged: (v) => state.textScale = v!,
              child: Column(
                children: [
                  for (final t in TextScalePreference.values)
                    RadioListTile<TextScalePreference>(
                      value: t,
                      contentPadding: EdgeInsets.zero,
                      title: Text(locale.isBangla
                          ? t.labelBn
                          : _englishScaleLabel(t)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.t(S.track),
            icon: Icons.tune,
            child: RadioGroup<Track>(
              groupValue: state.track,
              onChanged: (v) => state.track = v!,
              child: Column(
                children: [
                  for (final t in Track.choices)
                    RadioListTile<Track>(
                      value: t,
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.label.of(locale)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.t(S.whoRunsThis),
            icon: Icons.handshake_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t(S.notGovernment),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(context.t(S.adDisclosure),
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(context.t(S.privacyLine),
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.lock_open, size: 18, color: AppTheme.okOn(context)),
                    const SizedBox(width: 8),
                    Text(context.t(S.noPaywall),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: AppTheme.okOn(context))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(context.locale.isBangla ? 'সূত্র' : 'Sources'),
              subtitle: Text(context.locale.isBangla
                  ? 'অ্যাপের কারিগরি বক্তব্য কোথা থেকে এসেছে'
                  : 'What the technical content rests on'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SourcesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.t(S.about),
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueRow(
                  label: locale.isBangla ? 'সংস্করণ' : 'Version',
                  value: Bn.localiseDigits(AppInfo.versionLabel, locale),
                ),
                const SizedBox(height: 8),
                Text(context.t(AppInfo.copyright),
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(context.t(AppInfo.licence),
                    style: theme.textTheme.bodySmall),
                const Divider(height: 24),
                Text(
                  locale.isBangla ? 'যা ব্যবহার করা হয়েছে' : 'Built on',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                for (final a in AppInfo.attributions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name, style: theme.textTheme.bodyMedium),
                        Text(a.detail.of(locale),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _englishScaleLabel(TextScalePreference t) => switch (t) {
        TextScalePreference.normal => 'Normal',
        TextScalePreference.large => 'Large',
        TextScalePreference.extraLarge => 'Extra large',
      };
}
