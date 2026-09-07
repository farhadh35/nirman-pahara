import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import 'sources_screen.dart';

/// "This is not a government app", said where somebody actually looks.
///
/// Google Play rejected this app twice under Misleading Claims for showing
/// government information — PWD rates, the building code, the gazette — with
/// no link to the original and no statement of who the app is. The first fix
/// put both on the store listing and on the sources page. That was not enough,
/// and the reason is worth writing down: the sources page is three taps deep
/// behind settings, and the store disclaimer sat two thousand characters into
/// a description Play collapses after eighty. A disclaimer nobody reaches is
/// not a disclaimer.
///
/// So this goes on the first screen of the app, on the home screen, and on
/// every screen that puts a government figure in front of the reader. Tapping
/// it opens the reference list, where each government work carries the address
/// its own publisher issues it from.
class NotGovernmentNotice extends StatelessWidget {
  const NotGovernmentNotice({super.key, this.tappable = true});

  /// False on the first-run screen, which has no navigator stack worth
  /// pushing onto — the reader has not chosen a language yet.
  final bool tappable;

  /// The sentence itself, so a test can assert on it without building a tree.
  static const bn = 'নির্মাণ পাহারা সরকারি অ্যাপ নয় — কোনো সরকারি দপ্তরের সঙ্গে '
      'যুক্ত নয়। সরকারি নথির তথ্য এখানে কেবল তুলে ধরা হয়েছে।';
  static const en = 'Nirman Pahara is not a government app and is not '
      'affiliated with any government body. Government documents are '
      'reproduced here for reference only.';

  static const bnMore = 'মূল উৎসের ঠিকানা দেখুন';
  static const enMore = 'See the original sources';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bangla = context.locale.isBangla;
    // Brand green rather than the amber CautionBox uses. On the prices screen
    // the two sit one above the other, and in amber they read as a single
    // block of warning — which flattens both. This is a standing fact about
    // who the app is, not a caution about what the reader just typed.
    final colour = theme.colorScheme.primary;

    final body = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colour.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_outlined, size: 18, color: colour),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bangla ? bn : en, style: theme.textTheme.bodySmall),
                if (tappable) ...[
                  const SizedBox(height: 2),
                  Text(
                    bangla ? bnMore : enMore,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (!tappable) return body;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SourcesScreen()),
      ),
      child: body,
    );
  }
}
