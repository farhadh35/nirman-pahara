import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_scope.dart';
import '../logic/update_check.dart';

/// The settings row that answers the question it asks.
///
/// The home prompt only ever appears when there is news, which means a reader
/// who wants to know *now* has nowhere to ask. This is that place. It runs the
/// same Play check and says what came back — including "you are up to date",
/// which is the answer most readers will get and the one worth showing.
///
/// Opening the store page is the fallback, not the behaviour: that is what a
/// sideloaded copy or a phone without Play services gets, and the reader is
/// told that is what happened rather than being dropped into a browser with no
/// explanation.
class UpdateSettingsTile extends StatefulWidget {
  const UpdateSettingsTile({super.key, this.check = const UpdateCheck()});

  final UpdateCheck check;

  @override
  State<UpdateSettingsTile> createState() => _UpdateSettingsTileState();
}

class _UpdateSettingsTileState extends State<UpdateSettingsTile> {
  bool _working = false;

  Future<void> _check() async {
    setState(() => _working = true);
    final info = await widget.check.available();

    // Asking by hand counts as asking: the home prompt should not repeat the
    // question on the next launch.
    final prefs = await SharedPreferences.getInstance();
    await widget.check.markAsked(prefs);

    if (!mounted) return;
    setState(() => _working = false);

    if (info == null) {
      // Play answered "nothing newer", or could not answer at all. The two are
      // indistinguishable from here, so say the honest thing and leave the
      // store page one tap away.
      await _offerStore();
      return;
    }
    await _install();
  }

  Future<void> _install() async {
    setState(() => _working = true);
    final ok = await widget.check.startFlexible();
    if (!mounted) return;
    setState(() => _working = false);
    if (!ok) {
      await _offerStore();
      return;
    }
    final bn = context.locale.isBangla;
    _say(bn ? 'হালনাগাদ হয়ে গেছে।' : 'Updated.');
  }

  Future<void> _offerStore() async {
    final bn = context.locale.isBangla;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text(bn
          ? 'প্লে স্টোর থেকে জানা গেল না। পাতাটি খুলে নিজে দেখে নিন।'
          : 'Play could not answer. Open the page and look for yourself.'),
      action: SnackBarAction(
        label: bn ? 'খুলুন' : 'Open',
        onPressed: () async {
          final opened = await widget.check.openStore();
          if (opened || !mounted) return;
          _say(bn ? 'প্লে স্টোর খোলা গেল না।' : 'Could not open the Play Store.');
        },
      ),
    ));
  }

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.system_update_outlined),
        title: Text(bn ? 'নতুন সংস্করণ দেখুন' : 'Check for updates'),
        subtitle: Text(bn
            ? 'প্লে স্টোরকে জিজ্ঞেস করবে। কিছু পাঠানো হয় না।'
            : 'Asks the Play Store. Nothing is sent.'),
        trailing: _working
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right),
        onTap: _working ? null : _check,
      ),
    );
  }
}
