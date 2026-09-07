import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../sources/ui/not_government_notice.dart';
import '../../../core/content/rights_models.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/util/bn.dart';

/// The complaint ladder and the letter templates.
class RightsScreen extends StatelessWidget {
  const RightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.t(S.rights))),
      body: ContentBuilder<RightsPack>(
        future: context.content.rights(),
        builder: (context, pack) {
          final track = context.appState.track;
          final letters = pack.lettersFor(track);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // These letters are written under the Right to Information Act
              // and the procurement rules. Drafting a letter under an Act is
              // not acting for the office that will receive it.
              const NotGovernmentNotice(),
              const SizedBox(height: 14),
              Text(context.t(S.letters), style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final l in letters) ...[
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      context.t(l.title),
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(context.t(l.description)),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LetterScreen(template: l),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Fills a letter template in and lets the user copy the result out.
class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key, required this.template});

  final LetterTemplate template;

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final f in widget.template.fields) {
      _controllers[f.key] = TextEditingController()
        ..addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final bn = context.locale.isBangla;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(bn ? 'চিঠিটি ফেলে দেবেন?' : 'Discard this letter?'),
        content: Text(
          bn
              ? 'যা লিখেছেন তা সংরক্ষণ করা হয়নি। ফিরে গেলে আর ফেরানো যাবে না।'
              : 'What you have written is not saved anywhere. Going back cannot '
                    'be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(bn ? 'লেখা চালিয়ে যান' : 'Keep writing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(bn ? 'ফেলে দিন' : 'Discard'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = {for (final e in _controllers.entries) e.key: e.value.text};
    final rendered = widget.template.render(values, context.locale);
    // A field left blank renders as its label in brackets, which is visible in
    // the preview but easy to miss near the bottom of a long letter. This one
    // goes to a government office, and an application with "[আপনার নাম]" still
    // in it is one that comes back — after the twenty working days the reader
    // was waiting on.
    final blank = [
      for (final f in widget.template.fields)
        if ((values[f.key] ?? '').trim().isEmpty) f.label.of(context.locale),
    ];

    final started = values.values.any((v) => v.trim().isEmpty == false);

    // Nothing here is written down anywhere. A letter to a government office
    // is typed slowly, often from a paper the reader is holding, and one back
    // gesture took all of it with no warning at all. Deleting an inspection
    // asks first; so should throwing away an application.
    return PopScope(
      canPop: !started,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !mounted) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard()) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.t(widget.template.title))),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            Text(
              context.t(widget.template.description),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            for (final f in widget.template.fields) ...[
              TextField(
                controller: _controllers[f.key],
                maxLines: f.multiline ? 4 : 1,
                keyboardType: switch (f.keyboard) {
                  LetterKeyboard.phone => TextInputType.phone,
                  LetterKeyboard.number => TextInputType.number,
                  LetterKeyboard.text =>
                    f.multiline ? TextInputType.multiline : TextInputType.text,
                },
                decoration: InputDecoration(
                  alignLabelWithHint: f.multiline,
                  labelText: context.t(f.label),
                  helperText: f.hint == null ? null : context.t(f.hint!),
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 8),
            SectionCard(
              title: context.t(S.preview),
              icon: Icons.description_outlined,
              child: SelectableText(
                rendered,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.9),
              ),
            ),
            if (widget.template.footnote != null) ...[
              const SizedBox(height: 12),
              CautionBox(
                text: context.t(widget.template.footnote!),
                icon: Icons.info_outline,
              ),
            ],
            const SizedBox(height: 16),
            if (blank.isNotEmpty) ...[
              CautionBox(
                text: context.locale.isBangla
                    ? '${Bn.digits('${blank.length}')}টি ঘর এখনো খালি — '
                          '${blank.join(', ')}. খালি ঘরগুলো চিঠিতে বর্গবন্ধনীর '
                          'মধ্যে দেখা যাচ্ছে; ওভাবে পাঠালে আবেদন ফেরত আসতে পারে।'
                    : '${blank.length} field${blank.length == 1 ? '' : 's'} still '
                          'empty — ${blank.join(', ')}. They appear in the letter '
                          'inside square brackets, and an application sent like '
                          'that can come back.',
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: () => copyToClipboard(context, rendered),
              icon: const Icon(Icons.copy_all_outlined),
              label: Text(context.t(S.copy)),
            ),
          ],
        ),
      ),
    );
  }
}
