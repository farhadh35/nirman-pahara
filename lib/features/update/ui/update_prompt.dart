import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_scope.dart';
import '../logic/update_check.dart';

/// A line on the home screen, and only when there is something to say.
///
/// It draws nothing until Play has confirmed a newer version exists, so a
/// reader with no connection, a sideloaded copy, or the current version sees
/// an ordinary home screen. Dismissing it is remembered for a day, and the
/// check itself is skipped inside that day — opening the app twenty times on a
/// site costs twenty nothing-at-alls.
class UpdatePrompt extends StatefulWidget {
  const UpdatePrompt({super.key, this.check = const UpdateCheck()});

  final UpdateCheck check;

  @override
  State<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends State<UpdatePrompt> {
  bool _show = false;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _look();
  }

  Future<void> _look() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await widget.check.dueForCheck(prefs)) return;
    final info = await widget.check.available();
    if (info == null) return;
    await widget.check.markAsked(prefs);
    if (mounted) setState(() => _show = true);
  }

  Future<void> _update() async {
    setState(() => _working = true);
    final ok = await widget.check.startFlexible();
    if (!ok) await widget.check.openStore();
    if (mounted) setState(() => _working = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final bn = context.locale.isBangla;
    final colour = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.withValues(alpha: 0.32)),
        ),
        child: Row(
          children: [
            Icon(Icons.system_update_outlined, size: 18, color: colour),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                bn ? 'নতুন সংস্করণ এসেছে।' : 'A newer version is available.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (_working)
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else ...[
              TextButton(
                onPressed: () => setState(() => _show = false),
                child: Text(bn ? 'পরে' : 'Later'),
              ),
              FilledButton(
                onPressed: _update,
                child: Text(bn ? 'হালনাগাদ' : 'Update'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
