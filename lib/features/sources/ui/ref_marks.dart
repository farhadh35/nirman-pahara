import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../core/util/bn.dart';
import '../logic/reference_work.dart';
import 'sources_screen.dart';

/// The reference numbers a claim rests on, printed as `[৫]`.
///
/// This replaced a source line under every card and a review badge beside it.
/// Both said the same few things over and over: the same three works, and the
/// same sentence about an engineer not having read it yet. A number says where
/// to look and says it in four characters, and the answer lives in one place
/// that states each work once.
///
/// Tapping opens the reference page at this entry.
class RefMarks extends StatelessWidget {
  const RefMarks({super.key, required this.sources});

  /// Raw citation texts, exactly as the content gives them. Anything matching
  /// no known work is dropped rather than printed as a number leading nowhere.
  final List<String> sources;

  List<int> get _numbers {
    final seen = <int>{};
    for (final s in sources) {
      final n = ReferenceWork.numberFor(s);
      if (n != null) seen.add(n);
    }
    return seen.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final numbers = _numbers;
    if (numbers.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final locale = context.locale;
    final label =
        '[${numbers.map((n) => Bn.localiseDigits('$n', locale)).join(', ')}]';

    // Read aloud, "[৫]" is nothing. Say what the number is for.
    final spoken = numbers.length == 1
        ? (locale.isBangla ? 'সূত্র $label' : 'Reference $label')
        : (locale.isBangla ? 'সূত্র $label' : 'References $label');

    void open() => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SourcesScreen(focus: numbers.first),
          ),
        );

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: spoken,
        // excludeSemantics drops everything the child contributed, the
        // InkWell's tap action included — so the action has to be given again
        // here. Without it the node announces "button" and does nothing when
        // a screen reader activates it, which is worse than being unlabelled:
        // it reads as a working control.
        onTap: open,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: open,
          child: Padding(
            // Deliberately smaller than AppTheme.minTapTarget: this is a
            // secondary mark beside a sentence, not an action, and a 56dp
            // block of empty space beside every claim would push the content
            // it annotates off the screen. The padding still brings it to
            // about 40dp at normal text and past 50 at the largest.
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
