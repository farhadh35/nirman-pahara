import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../sources/ui/not_government_notice.dart';

/// A directory of soil-test firms, architects and engineers — not yet built.
///
/// The book carries such lists, and they were deliberately left out: they were
/// printed in 2019 with telephone numbers, and a number read in 2026 sends
/// somebody to a line that has changed hands, with nothing in the app able to
/// know it has. Shipping a stale directory is worse than shipping none.
///
/// This page says so rather than leaving a reader wondering why an app about
/// choosing a soil-test firm never tells them where to find one. It carries no
/// listings, takes no payment for inclusion, and says what a list would have to
/// satisfy before it could appear — which is also the standard any future
/// version of this page has to meet.
class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bn = context.locale.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(bn ? 'প্রতিষ্ঠানের তালিকা' : 'Directory of firms'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          const NotGovernmentNotice(),
          const SizedBox(height: 16),
          Text(
            bn ? 'এখনো আসেনি' : 'Not here yet',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            bn
                ? 'মাটি পরীক্ষার প্রতিষ্ঠান, আর্কিটেক্ট ও স্ট্রাকচারাল ডিজাইন '
                    'ফার্মের একটা তালিকা এখানে আসার কথা। এখনো দেওয়া হয়নি, আর '
                    'কারণটা বলে রাখা ভালো।'
                : 'A list of soil-test firms, architects and structural design '
                    'practices belongs here. It is not here yet, and the reason '
                    'is worth stating.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          CautionBox(
            icon: Icons.schedule,
            text: bn
                ? 'যে তালিকাগুলো পাওয়া যায়, সেগুলোর ফোন নম্বর ২০১৯ সালের। '
                    'পুরোনো নম্বর হাতবদল হয়ে যায়, আর অ্যাপের পক্ষে সেটা জানার '
                    'উপায় নেই। ভুল নম্বরে পাঠানোর চেয়ে না পাঠানো ভালো।'
                : 'The lists that exist carry telephone numbers from 2019. Old '
                    'numbers change hands, and the app has no way of knowing when '
                    'they have. Sending you to a wrong number is worse than '
                    'sending you nowhere.',
          ),
          const SizedBox(height: 22),
          Text(
            bn ? 'তালিকা এলে যা মানতে হবে' : 'What a list here would have to meet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _Rule(
            bn: bn,
            bnText: 'প্রতিটি ভুক্তির পাশে কবে যাচাই করা হয়েছে সেই তারিখ থাকবে।',
            enText: 'Every entry carries the date it was last checked.',
          ),
          _Rule(
            bn: bn,
            bnText: 'তালিকায় থাকার জন্য কোনো টাকা নেওয়া হবে না — এই অ্যাপ যাদের '
                'কাজ যাচাই করতে শেখায়, তাদের কাছ থেকে বিজ্ঞাপন নেওয়া হয় না।',
            enText: 'No payment is taken for inclusion. This app does not take '
                'advertising from the trades whose work it teaches you to check.',
          ),
          _Rule(
            bn: bn,
            bnText: 'তালিকা মানে সুপারিশ নয়। কারা কাজ করে, সেটুকুই।',
            enText: 'A listing is not a recommendation. It says only who does the '
                'work.',
          ),
          const SizedBox(height: 22),
          Text(
            bn
                ? 'ততক্ষণ পর্যন্ত: মাটি পরীক্ষার রিপোর্ট কীভাবে পড়তে হয় আর নকশায় '
                    'কী দেখতে হয়, সেটা গাইডের অধ্যায়গুলোতে আছে। কাকে দিয়ে করাবেন '
                    'তার চেয়ে কাজটা ঠিক হলো কি না — সেটা যাচাই করা বেশি জরুরি।'
                : 'Until then: how to read a soil report, and what to look for in '
                    'a drawing, are in the guide chapters. Checking that the work '
                    'was done properly matters more than who was engaged to do it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.bn, required this.bnText, required this.enText});

  final bool bn;
  final String bnText;
  final String enText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Icon(Icons.circle,
                size: 6, color: theme.colorScheme.primary),
          ),
          Expanded(child: Text(bn ? bnText : enText)),
        ],
      ),
    );
  }
}
