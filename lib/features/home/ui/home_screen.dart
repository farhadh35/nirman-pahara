import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/content/models.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/i18n/strings.dart';
import '../../calculators/ui/calculators_screen.dart';
import '../../lookups/ui/lookups_screen.dart';
import '../../measure/ui/measure_screen.dart';
import '../../rules/ui/far_screen.dart';
import '../../guide/ui/guide_screens.dart';
import '../../inspection/ui/inspection_screens.dart';
import '../../prices/ui/prices_screen.dart';
import '../../boq/ui/schedule_check_screen.dart';
import '../../reference/ui/reference_screen.dart';
import '../../rights/ui/rights_screen.dart';
import '../../settings/ui/settings_screen.dart';
import '../../sources/ui/not_government_notice.dart';

/// Five doors, deliberately large. Nothing else competes for attention.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t(S.appName)),
        actions: [
          IconButton(
            tooltip: context.t(S.settings),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(context.t(S.tagline), style: theme.textTheme.bodyLarge),
          const SizedBox(height: 10),
          // Above the doors, not below them. A reviewer — and a reader who
          // half-expects a government app because the app talks about
          // government work — has to meet this before anything else.
          const NotGovernmentNotice(),
          const SizedBox(height: 12),
          const _TrackChips(),
          const SizedBox(height: 20),
          _Door(
            icon: Icons.menu_book_outlined,
            title: context.t(S.learn),
            subtitle: context.t(S.learnSub),
            onTap: () => _go(context, const GuideScreen()),
          ),
          _Door(
            icon: Icons.checklist_rtl_outlined,
            title: context.t(S.inspect),
            subtitle: context.t(S.inspectSub),
            onTap: () => _go(context, const InspectionScreen()),
          ),
          _Door(
            icon: Icons.calculate_outlined,
            title: context.t(S.calculate),
            subtitle: context.t(S.calculateSub),
            onTap: () => _go(context, const CalculatorsScreen()),
          ),
          _Door(
            icon: Icons.straighten_outlined,
            title: context.locale.isBangla ? 'মাপজোখ' : 'Measuring tools',
            subtitle: context.locale.isBangla
                ? 'কাঠা-বিঘা-শতাংশ, সুতা থেকে মিলিমিটার, ক্ষেত্রফল ও আয়তন'
                : 'Katha, bigha and decimals; suta to millimetres; areas and '
                    'volumes',
            onTap: () => _go(context, const MeasureScreen()),
          ),
          _Door(
            icon: Icons.table_chart_outlined,
            title: context.locale.isBangla ? 'মাপ ও তালিকা' : 'Standards and tables',
            subtitle: context.locale.isBangla
                ? 'অনুপাত, কিউরিং, শাটার খোলার সময়, বালির এফএম'
                : 'Mix ratios, curing, striking times, sand fineness',
            onTap: () => _go(context, const LookupsScreen()),
          ),
          _Door(
            icon: Icons.apartment_outlined,
            title: context.locale.isBangla
                ? 'জমিতে কতটুকু করা যাবে'
                : 'What the plot allows',
            subtitle: context.locale.isBangla
                ? 'সামনের রাস্তার মাপ ধরে গেজেটের FAR সূচক'
                : "The gazette's FAR index, read off the road in front",
            onTap: () => _go(context, const FarScreen()),
          ),
          _Door(
            icon: Icons.trending_up,
            title: context.t(S.prices),
            subtitle: context.t(S.pricesSub),
            onTap: () => _go(context, const PricesScreen()),
          ),
          _Door(
            icon: Icons.fact_check_outlined,
            title: context.t(S.scheduleCheck),
            subtitle: context.t(S.scheduleCheckSub),
            onTap: () => _go(context, const ScheduleCheckScreen()),
          ),
          _Door(
            icon: Icons.gavel_outlined,
            title: context.t(S.rights),
            subtitle: context.t(S.rightsSub),
            onTap: () => _go(context, const RightsScreen()),
          ),
          // Last on the page on purpose: a homeowner should never arrive in the
          // detailing tier by scrolling, only by deciding to.
          _Door(
            icon: Icons.architecture_outlined,
            title: context.locale.isBangla
                ? 'প্রকৌশলীর রেফারেন্স'
                : "Engineer's reference",
            subtitle: context.locale.isBangla
                ? 'ডিটেইলিং, ফাউন্ডেশনের ধরন, বোর লগ'
                : 'Detailing, foundation types, bore logs',
            onTap: () => _go(context, const ReferenceScreen()),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, Widget screen) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
}

/// Lets the user flip between the government-works and own-house tracks
/// without going into settings, because most people try both.
class _TrackChips extends StatelessWidget {
  const _TrackChips();

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return Wrap(
      spacing: 8,
      children: [
        for (final t in Track.choices)
          ChoiceChip(
            label: Text(t.label.of(locale)),
            selected: context.appState.track == t,
            onSelected: (_) => context.appState.track = t,
          ),
      ],
    );
  }
}

class _Door extends StatelessWidget {
  const _Door({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// First run: language, then what the user is looking at. Two taps, no more —
/// anything longer and a first-time user on a borrowed phone gives up.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Null until the reader answers.
  ///
  /// The radio used to open with "সরকারি কাজ" already filled in, so anyone who
  /// tapped straight through had not answered the question — they had accepted
  /// a default. That is the wrong thing to guess at: the two tracks carry
  /// different complaint ladders, and a homeowner put on the government one is
  /// shown how to file a Right to Information application against their own
  /// contractor. One tap is a small price for the app knowing who it is
  /// talking to.
  Track? _picked;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final locale = context.locale;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          children: [
            Text(context.t(S.appName), style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(context.t(S.tagline), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            const NotGovernmentNotice(tappable: false),
            const SizedBox(height: 28),
            Text(context.t(S.language), style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                for (final l in AppLocale.values)
                  ChoiceChip(
                    label: Text(l.endonym),
                    selected: state.locale == l,
                    onSelected: (_) => state.locale = l,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Text(context.t(S.track), style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioGroup<Track>(
              groupValue: _picked,
              onChanged: (v) => setState(() => _picked = v),
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
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _picked == null
                  ? null
                  : () {
                      state.track = _picked!;
                      state.completeOnboarding();
                    },
              child: Text(context.t(S.next)),
            ),
            if (_picked == null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  locale.isBangla
                      ? 'দুটোর একটি বেছে নিন — পরে সেটিংসে বদলানো যাবে।'
                      : 'Pick one — it can be changed later in settings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
