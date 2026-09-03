import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../app/widgets/common.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/util/bn.dart';
import '../logic/boq_analyzer.dart';
import '../logic/expected_items.dart';
import '../logic/schedule_importer.dart';

/// Import a departmental rate schedule and see what in it is worth asking
/// about.
///
/// The document these statements carry — scheduled quantity beside measured
/// quantity, with a rate and three money columns — is the one place where a
/// citizen can see what was promised against what was done, in numbers, before
/// the final bill is paid.
class ScheduleCheckScreen extends StatefulWidget {
  const ScheduleCheckScreen({super.key});

  @override
  State<ScheduleCheckScreen> createState() => _ScheduleCheckScreenState();
}

class _ScheduleCheckScreenState extends State<ScheduleCheckScreen> {
  ImportResult? _result;
  List<BoqFinding> _findings = const [];
  bool _busy = false;
  String? _error;
  WorkProfile? _profile;

  Future<void> _pick() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          ...ScheduleImporter.supportedExtensions,
          'pdf',
        ],
      );
      final path = picked?.files.single.path;
      if (path == null) {
        setState(() => _busy = false);
        return;
      }
      final result = await const ScheduleImporter().read(File(path));
      setState(() {
        _result = result;
        _findings =
            const BoqAnalyzer().analyse(result.document, profile: _profile);
        _busy = false;
      });
    } catch (_) {
      // Not `on Exception`. A file that is not really a spreadsheet — renamed,
      // half-downloaded, or a photo with the wrong extension — throws
      // UnsupportedError, which is an Error and not an Exception, so it walked
      // straight past that clause. The screen was then left with _busy still
      // true: a spinner that never stopped, on the likeliest failure there is.
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.locale.isBangla
            ? 'ফাইলটি পড়া গেল না। এটি হয়তো আসল স্প্রেডশিট নয় — নাম বদলানো, '
                'অসম্পূর্ণ ডাউনলোড, বা অন্য কোনো ফাইল। যে সফটওয়্যারে শিডিউলটি '
                'আছে সেখান থেকে আবার .xlsx বা .csv করে সেভ করে দেখুন।'
            : 'The file could not be read. It may not be a real spreadsheet — '
                'renamed, half-downloaded, or something else entirely. Try '
                'saving it again as .xlsx or .csv from whatever holds the '
                'schedule.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    final theme = Theme.of(context);
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: Text(bn ? 'শিডিউল যাচাই' : 'Check a rate schedule'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          if (result == null) _intro(context),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _profile?.id,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: bn ? 'কী ধরনের কাজ' : 'What kind of work',
              helperText: bn
                  ? 'বললে কোন আইটেম থাকার কথা ছিল অথচ নেই, সেটাও দেখা যাবে'
                  : 'Tell it, and it can also look for items that should be '
                      'there and are not',
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(bn ? 'বলছি না' : 'Not saying'),
              ),
              for (final p in ExpectedItems.all)
                DropdownMenuItem(value: p.id, child: Text(p.name.of(context.locale))),
            ],
            onChanged: (v) => setState(() {
              _profile = v == null ? null : ExpectedItems.byId(v);
              final doc = _result?.document;
              if (doc != null) {
                _findings =
                    const BoqAnalyzer().analyse(doc, profile: _profile);
              }
            }),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _pick,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
            label: Text(
              result == null
                  ? (bn ? 'ফাইল বেছে নিন' : 'Choose a file')
                  : (bn ? 'অন্য ফাইল' : 'Another file'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            CautionBox(text: _error!),
          ],
          if (result != null) ...[
            const SizedBox(height: 16),
            // A summary of a read that did not happen is noise on top of the
            // reason it did not happen.
            if (result.ok) ...[
              _summary(context, result),
              const SizedBox(height: 12),
            ],
            if (result.warning != null)
              CautionBox(text: result.warning!.of(context.locale)),
            if (result.ok) ...[
              const SizedBox(height: 20),
              Text(
                _findings.isEmpty
                    ? (bn ? 'জিজ্ঞেস করার মতো কিছু পাওয়া যায়নি'
                        : 'Nothing found worth asking about')
                    : (bn ? 'যা জিজ্ঞেস করার মতো' : 'Worth asking about'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final f in _findings) ...[
                _FindingCard(finding: f),
                const SizedBox(height: 12),
              ],
              if (_findings.isEmpty)
                CautionBox(
                  icon: Icons.check_circle_outline,
                  text: bn
                      ? 'এই কাগজে হিসাবের অসঙ্গতি চোখে পড়েনি। তার মানে কাজ ঠিক '
                          'হয়েছে তা নয় — কাগজ আর মাঠ এক জিনিস নয়।'
                      : 'No arithmetic problem stood out in this document. That '
                          'does not mean the work is sound — paper and site are '
                          'not the same thing.',
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => copyToClipboard(context, _asText(context)),
                icon: const Icon(Icons.copy_all_outlined),
                label: Text(context.t(S.copy)),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final bn = context.locale.isBangla;
    return SectionCard(
      title: bn ? 'কী দিতে হবে' : 'What to import',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bn
                ? 'দপ্তর থেকে পাওয়া রেট শিডিউল বা পরিমাপের বিবরণী — যেখানে প্রতিটি '
                    'কাজের পাশে তফসিলের পরিমাণ, মাপা পরিমাণ, রেট আর টাকার অঙ্ক '
                    'লেখা থাকে। কাগজটা RTI আবেদনে চাওয়া যায়।'
                : 'The rate schedule or measurement statement issued by the '
                    'department — the one carrying, for each item, the scheduled '
                    'quantity, the measured quantity, the rate and the amounts. '
                    'You can ask for it under RTI.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            bn
                ? 'এক্সেল (.xlsx), সিএসভি (.csv), ওয়ার্ড (.docx) বা সাধারণ লেখা '
                    '(.txt) — এই ফাইলগুলো পড়া যায়।'
                : 'Spreadsheet (.xlsx), CSV, Word (.docx) or plain text (.txt) '
                    'can be read.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context, ImportResult result) {
    final bn = context.locale.isBangla;
    final locale = context.locale;
    final theme = Theme.of(context);
    final doc = result.document;
    final flags =
        _findings.where((f) => f.severity == BoqSeverity.flag).length;

    return SectionCard(
      title: bn ? 'যা পড়া হলো' : 'What was read',
      icon: Icons.table_chart_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (doc.title.isNotEmpty)
            Text(doc.title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          ValueRow(
            label: bn ? 'লাইন পড়া হয়েছে' : 'Lines read',
            value: Bn.number(doc.lines.length.toDouble(),
                decimals: 0, locale: locale),
          ),
          ValueRow(
            label: bn ? 'জিজ্ঞাসার বিষয়' : 'Points to ask about',
            value: Bn.number(_findings.length.toDouble(),
                decimals: 0, locale: locale),
            emphasis: true,
          ),
          if (flags > 0)
            ValueRow(
              label: bn ? 'এর মধ্যে গুরুতর' : 'Of those, serious',
              value:
                  Bn.number(flags.toDouble(), decimals: 0, locale: locale),
              emphasis: true,
            ),
        ],
      ),
    );
  }

  String _asText(BuildContext context) {
    final locale = context.locale;
    final bn = locale.isBangla;
    final b = StringBuffer()
      ..writeln(bn ? 'শিডিউল যাচাইয়ের ফল' : 'RATE SCHEDULE REVIEW')
      ..writeln('=' * 40);
    final doc = _result?.document;
    if (doc != null && doc.title.isNotEmpty) b.writeln(doc.title);
    b.writeln();
    var n = 1;
    for (final f in _findings) {
      b.writeln('${n++}. ${f.title.of(locale)}'
          '${f.serial == null ? '' : ' (${f.serial})'}');
      b.writeln('   ${f.detail.of(locale)}');
      b.writeln('   ${bn ? 'যা চাইবেন' : 'What to ask for'}: '
          '${f.ask.of(locale)}');
      b.writeln();
    }
    b.writeln('-' * 40);
    b.writeln(bn
        ? 'এই তালিকা কাগজের হিসাব দেখে তৈরি। এটি কোনো নিরীক্ষা বা অভিযোগ নয় — '
            'প্রতিটি বিষয়ে ব্যাখ্যা চাওয়ার জন্য।'
        : 'This list comes from the arithmetic on the document. It is not an '
            'audit and not an allegation — each point is something to ask for '
            'an explanation about.');
    return b.toString();
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({required this.finding});

  final BoqFinding finding;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final bn = locale.isBangla;
    final theme = Theme.of(context);
    final colour = switch (finding.severity) {
      BoqSeverity.flag => theme.colorScheme.error,
      BoqSeverity.question => AppTheme.warningOn(context),
      BoqSeverity.note => theme.colorScheme.onSurfaceVariant,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  switch (finding.severity) {
                    BoqSeverity.flag => Icons.error_outline,
                    BoqSeverity.question => Icons.help_outline,
                    BoqSeverity.note => Icons.info_outline,
                  },
                  size: 20,
                  color: colour,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(finding.title.of(locale),
                      style: theme.textTheme.titleSmall),
                ),
                if (finding.serial != null)
                  Text(
                    // The serial as the document prints it. A reader points at
                    // this line on the paper and an official finds the same row
                    // — converting it to Bangla digits would mean the two are
                    // no longer looking at the same thing.
                    finding.serial!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(finding.detail.of(locale),
                style: theme.textTheme.bodyMedium),
            if (finding.amount != null && finding.amount! > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${bn ? 'জড়িত টাকা' : 'Money involved'}: '
                '${Bn.takaWords(finding.amount!, locale: locale)}',
                style: theme.textTheme.titleSmall?.copyWith(color: colour),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.request_page_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(finding.ask.of(locale),
                        style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
