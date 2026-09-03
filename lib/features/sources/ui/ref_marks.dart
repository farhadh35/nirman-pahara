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

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SourcesScreen(focus: numbers.first),
          ),
        ),
        child: Padding(
          // Small, but the tap target still clears a fingertip.
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
