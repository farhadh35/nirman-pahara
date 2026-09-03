import 'dart:convert';
import 'dart:io';
import '../../sources/ui/ref_marks.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/common.dart';
import '../../../core/content/checklist_models.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/util/bn.dart';
import '../logic/inspection_run.dart';
import '../logic/photo_ref.dart';
import '../report/report_document.dart';
import '../report/report_sheet.dart';
import '../logic/inspection_store.dart';
import '../logic/lost_capture.dart';

/// Saved inspections first, then the packs to start a new one.
class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  Future<_InspectionHome>? _future;
  InspectionStore? _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.inspections;
    if (!identical(store, _store)) {
      _store?.removeListener(_reload);
      _store = store..addListener(_reload);
    }
    _future ??= _load();
  }

  @override
  void dispose() {
    _store?.removeListener(_reload);
    super.dispose();
  }

  Future<_InspectionHome> _load() async {
    final content = context.content;
    final store = context.inspections;
    final track = context.appState.track;
    final packs = await content.checklistsForTrack(track);
    final saved = await store.load(await content.checklists());
    return _InspectionHome(packs: packs, saved: saved);
  }

  void _reload() {
    if (!mounted) return;
    // Block body: an arrow here returns the Future to setState, which asserts.
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bn = context.locale.isBangla;
    return Scaffold(
      appBar: AppBar(title: Text(context.t(S.inspect))),
      body: ContentBuilder<_InspectionHome>(
        future: _future!,
        builder: (context, data) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            if (data.saved.isNotEmpty) ...[
              Text(bn ? 'চলতি পরিদর্শন' : 'Your inspections',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final run in data.saved) ...[
                _SavedRunCard(run: run),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              Text(bn ? 'নতুন পরিদর্শন' : 'Start a new inspection',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
            ],
            for (final p in data.packs) ...[
              Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(context.t(p.title),
                      style: theme.textTheme.titleMedium),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(context.t(p.summary)),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => InspectionSetupScreen(pack: p),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _InspectionHome {
  const _InspectionHome({required this.packs, required this.saved});

  final List<ChecklistPack> packs;
  final List<InspectionRun> saved;
}

/// A run in progress, with enough on the card to tell two roads apart.
class _SavedRunCard extends StatelessWidget {
  const _SavedRunCard({required this.run});

  final InspectionRun run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale;
    final bn = locale.isBangla;
    final u = run.updatedAt;
    final date = Bn.localiseDigits(
      '${u.year}-${_two(u.month)}-${_two(u.day)} '
      '${_two(u.hour)}:${_two(u.minute)}',
      locale,
    );
    final progress =
        '${Bn.number(run.answered.length.toDouble(), decimals: 0, locale: locale)}'
        ' / '
        '${Bn.number(run.total.toDouble(), decimals: 0, locale: locale)}';

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(run.projectName, style: theme.textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${run.pack.title.of(locale)} · $date · '
              '${bn ? 'দেখা হয়েছে' : 'checked'} $progress'
              '${run.problems.isEmpty ? '' : ' · '
                  '${bn ? 'সমস্যা' : 'problems'} '
                  '${Bn.number(run.problems.length.toDouble(), decimals: 0, locale: locale)}'}'),
        ),
        trailing: IconButton(
          tooltip: bn ? 'মুছে ফেলুন' : 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => InspectionRunScreen(run: run),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bn = context.locale.isBangla;
    final store = context.inspections;
    final evidence = context.evidence;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(bn ? 'পরিদর্শন মুছে ফেলবেন?' : 'Delete this inspection?'),
        content: Text(bn
            ? 'এই পরিদর্শনের সব উত্তর ও নোট মুছে যাবে। এটা আর ফেরানো যাবে না।'
            : 'Every answer and note in this inspection will be removed. This '
                'cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.t(S.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(bn ? 'মুছে ফেলুন' : 'Delete'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await evidence.removeForRun(run.id);
      await store.delete(run.id);
    }
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

/// The signboard details, captured before the walk starts.
class InspectionSetupScreen extends StatefulWidget {
  const InspectionSetupScreen({super.key, required this.pack});

  final ChecklistPack pack;

  @override
  State<InspectionSetupScreen> createState() => _InspectionSetupScreenState();
}

class _InspectionSetupScreenState extends State<InspectionSetupScreen> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _tenderId = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _tenderId.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final navigator = Navigator.of(context);
    final store = context.inspections;
    final now = DateTime.now();
    final run = InspectionRun(
      id: InspectionRun.idFor(now),
      pack: widget.pack,
      projectName: _name.text.trim(),
      location: _location.text.trim(),
      tenderId: _tenderId.text.trim(),
      date: now,
    );
    await store.save(run);
    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => InspectionRunScreen(run: run)),
    );
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    return Scaffold(
      appBar: AppBar(title: Text(context.t(widget.pack.title))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          CautionBox(
            icon: Icons.photo_camera_outlined,
            text: bn
                ? 'শুরুর আগে সাইনবোর্ডের একটা ছবি তুলে রাখুন। বোর্ড হারিয়ে যায়, '
                    'ছবি থাকে।'
                : 'Photograph the signboard before you start. Boards disappear; '
                    'photographs do not.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: bn ? 'কাজের নাম' : 'Name of the work',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: InputDecoration(
              labelText: bn ? 'অবস্থান' : 'Location',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tenderId,
            decoration: InputDecoration(
              labelText: bn ? 'টেন্ডার / প্যাকেজ আইডি' : 'Tender / package ID',
              helperText: bn
                  ? 'সাইনবোর্ডে লেখা থাকে'
                  : 'It is on the signboard',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _name.text.trim().isEmpty ? null : _start,
            child: Text(bn ? 'পরিদর্শন শুরু করুন' : 'Start the inspection'),
          ),
          if (_name.text.trim().isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                bn ? 'কাজের নাম লিখুন' : 'Enter the name of the work',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// The walk itself: one card per item, grouped by stage.
class InspectionRunScreen extends StatefulWidget {
  const InspectionRunScreen({super.key, required this.run});

  final InspectionRun run;

  @override
  State<InspectionRunScreen> createState() => _InspectionRunScreenState();
}

class _InspectionRunScreenState extends State<InspectionRunScreen> {
  bool _askedForLostPhoto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_askedForLostPhoto) return;
    _askedForLostPhoto = true;
    _recoverLostPhoto();
  }

  /// Collect a photograph Android took while this app was being killed.
  ///
  /// Only ever attaches it to the item that was named before the camera
  /// opened, and only for this inspection — see [LostCapture].
  Future<void> _recoverLostPhoto() async {
    final evidence = context.evidence;
    final messenger = ScaffoldMessenger.of(context);
    final bn = context.locale.isBangla;
    final run = widget.run;

    final found = await LostCapture().recover(run.id);
    if (found == null || !mounted) return;

    final finding = run.findings[found.itemId];
    if (finding == null) return;
    try {
      finding.photos.add(await evidence.addWithContext(
        found.file,
        runId: run.id,
        itemId: found.itemId,
        takenAt: DateTime.now(),
      ));
    } catch (_) {
      return;
    }
    if (!mounted) return;
    _persist();
    messenger.showSnackBar(SnackBar(
      content: Text(bn
          ? 'ক্যামেরা বন্ধ হয়ে যাওয়ার আগে তোলা ছবিটি যোগ করা হয়েছে।'
          : 'Added the photograph taken before the camera closed.'),
    ));
  }

  /// Saved on every change rather than on exit: someone standing at a site
  /// closes the app, takes a call, or runs out of battery, and none of that
  /// should cost them the walk they have already done.
  void _persist() {
    setState(() {});
    context.inspections.save(widget.run);
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;
    final theme = Theme.of(context);
    final bn = context.locale.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(run.projectName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: run.progress, minHeight: 4),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          for (final stage in run.pack.stages) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(context.t(stage.title),
                  style: theme.textTheme.titleLarge),
            ),
            Text(
              context.t(stage.when),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in stage.items) ...[
              _ItemCard(
                finding: run.findings[item.id]!,
                runId: run.id,
                onChanged: _persist,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: run.answered.isEmpty
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => InspectionReportScreen(run: run),
                      ),
                    ),
            icon: const Icon(Icons.description_outlined),
            label: Text(bn ? 'রিপোর্ট তৈরি করুন' : 'Produce the report'),
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatefulWidget {
  const _ItemCard({
    required this.finding,
    required this.runId,
    required this.onChanged,
  });

  final Finding finding;
  final String runId;
  final VoidCallback onChanged;

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  /// Seeded from the saved note, so reopening an inspection shows what was
  /// written rather than an empty box that the next keystroke would replace.
  late final TextEditingController _note =
      TextEditingController(text: widget.finding.note);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finding = widget.finding;
    final onChanged = widget.onChanged;
    final item = finding.item;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t(item.question), style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(context.t(item.why),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            if (item.how != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.search, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(context.t(item.how!),
                        style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ],
            RefMarks(sources: [for (final c in item.citations) c.source.bn]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in ItemAnswer.values)
                  ChoiceChip(
                    label: Text(context.t(a.label)),
                    selected: finding.answer == a,
                    onSelected: (_) {
                      finding.answer = finding.answer == a ? null : a;
                      onChanged();
                    },
                  ),
              ],
            ),
            if (finding.isProblem || finding.hasPhotos) ...[
              const SizedBox(height: 12),
              _PhotoRow(
                finding: finding,
                runId: widget.runId,
                onChanged: onChanged,
              ),
            ],
            if (finding.isProblem) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLines: 3,
                onChanged: (v) {
                  finding.note = v;
                  onChanged();
                },
                decoration: InputDecoration(
                  // Without this a label on a multi-line field is centred
                  // vertically and reads as a stray hint in the middle of an
                  // empty box.
                  alignLabelWithHint: true,
                  labelText: context.locale.isBangla
                      ? 'কী দেখেছেন — তারিখ ও সময়সহ'
                      : 'What you saw, with date and time',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The finished report, ready to copy into a complaint.
class InspectionReportScreen extends StatefulWidget {
  const InspectionReportScreen({super.key, required this.run});

  final InspectionRun run;

  /// Keeps the shared file name recognisable without letting a project name
  /// containing a slash or a colon break the write.
  @visibleForTesting
  static String safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[^\w\u0980-\u09FF -]'), '').trim();
    if (cleaned.isEmpty) return 'report';

    // Filenames are capped at 255 bytes on the filesystems Android uses, and a
    // Bangla character is three bytes in UTF-8 — about eighty-five characters.
    // A government project name off a signboard goes past that without
    // trying: "ওয়ার্ড ৩ নম্বর সড়ক পুনর্নির্মাণ ও সম্প্রসারণ প্রকল্প, দ্বিতীয়
    // পর্যায়, ..." is a hundred and twenty. The write then failed and the
    // reader was told the PDF could not be built, which was not true — the
    // page had rendered, and only the name was too long.
    //
    // Trimmed by grapheme so a Bangla cluster is never cut in half.
    const maxBytes = 200;
    var chars = cleaned.characters;
    while (utf8.encode(chars.toString()).length > maxBytes && chars.isNotEmpty) {
      chars = chars.take(chars.length - 1);
    }
    final out = chars.toString().trim();
    return out.isEmpty ? 'report' : out;
  }

  @override
  State<InspectionReportScreen> createState() => _InspectionReportScreenState();
}

class _InspectionReportScreenState extends State<InspectionReportScreen> {
  /// Photographs whose file is no longer on disk.
  ///
  /// The share path has always dropped these from what it attaches, while the
  /// text kept counting them — so a report could say three were attached while
  /// two went out, which is exactly the sort of number an office checks against
  /// the envelope. Resolved once when the screen opens; until it comes back the
  /// report reads as it always did, which is right, because on the ordinary
  /// path nothing is missing.
  Set<String> _missing = const {};
  bool _checked = false;

  InspectionRun get run => widget.run;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    _findMissing();
  }

  Future<void> _findMissing() async {
    final evidence = context.evidence;
    final gone = <String>{};
    for (final finding in run.withPhotos) {
      for (final photo in finding.photos) {
        if (await evidence.file(photo.name) == null) gone.add(photo.name);
      }
    }
    if (!mounted || gone.isEmpty) return;
    setState(() => _missing = gone);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bn = context.locale.isBangla;
    final text = run.report(context.locale, missingPhotos: _missing);

    return Scaffold(
      appBar: AppBar(title: Text(bn ? 'রিপোর্ট' : 'Report')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: _stat(
                  theme,
                  bn ? 'দেখা হয়েছে' : 'Checked',
                  '${Bn.number(run.answered.length.toDouble(), decimals: 0, locale: context.locale)}'
                      ' / '
                      '${Bn.number(run.total.toDouble(), decimals: 0, locale: context.locale)}',
                ),
              ),
              Expanded(
                child: _stat(
                  theme,
                  bn ? 'সমস্যা' : 'Problems',
                  Bn.number(run.problems.length.toDouble(),
                      decimals: 0, locale: context.locale),
                  colour: run.problems.isEmpty ? null : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: bn ? 'রিপোর্ট' : 'Report',
            icon: Icons.description_outlined,
            child: SelectableText(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _sharePdf(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(bn ? 'পিডিএফ পাঠান' : 'Send as a PDF'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _share(context, text),
            icon: const Icon(Icons.share_outlined),
            label: Text(bn
                ? 'লেখা ও ছবি আলাদা করে পাঠান'
                : 'Send the text and photographs separately'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => copyToClipboard(context, text),
            icon: const Icon(Icons.copy_all_outlined),
            label: Text(context.t(S.copy)),
          ),
          const SizedBox(height: 12),
          CautionBox(
            icon: Icons.shield_outlined,
            text: bn
                ? 'অভিযোগ দেওয়ার আগে অধিকার অংশটা দেখে নিন — কোথায়, কোন ক্রমে '
                    'পাঠাতে হয় সেটা ওখানে আছে। একা না গিয়ে দল বেঁধে যান।'
                : 'Before you file, read the rights section — it says where to '
                    'send this and in what order. Go as a group, not alone.',
          ),
        ],
      ),
    );
  }

  /// Builds the printed report — photographs sitting beside the findings they
  /// belong to — and sends it as one PDF, so an officer receives a document
  /// rather than a message plus loose attachments to match up by hand.
  Future<void> _sharePdf(BuildContext context) async {
    final evidence = context.evidence;
    final locale = context.locale;
    final messenger = ScaffoldMessenger.of(context);
    final bn = locale.isBangla;

    final progress = SnackBar(
      duration: const Duration(seconds: 30),
      content: Text(bn ? 'পিডিএফ তৈরি হচ্ছে…' : 'Building the PDF…'),
    );
    messenger.showSnackBar(progress);

    try {
      final files = <String, File>{};
      for (final finding in run.withPhotos) {
        for (final photo in finding.photos) {
          final file = await evidence.file(photo.name);
          if (file != null) files[photo.name] = file;
        }
      }

      const document = ReportDocument();
      final png = await document.rasterise(
        ReportSheet(run: run, locale: locale, photoFiles: files),
      );
      final pdf = await document.toPdf(png);
      final out = await document.write(
        pdf,
        await evidence.exportDirectory(),
        // The run id, not just the name. Two inspections of "school building"
        // resolved to one file, so exporting the second overwrote the first
        // and the reader could share last week's report believing it was
        // today's. It also gives removeForRun something to match on.
        '${InspectionReportScreen.safeFileName(run.projectName)}'
            '_${run.id}.pdf',
      );

      messenger.hideCurrentSnackBar();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(out.path)], subject: run.projectName),
      );
    } catch (_) {
      // Not `on Exception`. Rendering a page and encoding a PDF is exactly
      // where an Error turns up — a bad image, memory, an unsupported
      // operation — and one escaping here left the progress snackbar sitting
      // on screen with nothing ever replacing it, so the export looked like it
      // was still running.
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(bn
              ? 'পিডিএফ তৈরি করা গেল না। লেখা আকারে পাঠিয়ে দেখুন।'
              : 'Could not build the PDF. Try sending it as text instead.'),
        ));
    }
  }


  /// Hands the report and its photographs to whatever the user already uses —
  /// WhatsApp, Messenger, email, Drive. Copying text alone left the evidence
  /// stranded on the phone, which is the one place it is no use.
  Future<void> _share(BuildContext context, String text) async {
    final evidence = context.evidence;
    final messenger = ScaffoldMessenger.of(context);
    final bn = context.locale.isBangla;
    final files = <XFile>[];
    for (final finding in run.withPhotos) {
      for (final photo in finding.photos) {
        final file = await evidence.file(photo.name);
        if (file != null) files.add(XFile(file.path));
      }
    }
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: files.isEmpty ? null : files,
          subject: run.projectName,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(
        content: Text(bn ? 'পাঠানো গেল না।' : 'Could not send.'),
      ));
    }
  }

  Widget _stat(ThemeData theme, String label, String value, {Color? colour}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          Text(value,
              style: theme.textTheme.headlineSmall?.copyWith(color: colour)),
        ],
      );
}


/// Photographs attached to one finding.
///
/// A dated photograph is what turns "the slab was dry" into something an
/// inspecting officer can check, so this sits directly under the answer rather
/// than behind another screen.
class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.finding,
    required this.runId,
    required this.onChanged,
  });

  final Finding finding;
  final String runId;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final bn = context.locale.isBangla;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (finding.hasPhotos)
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: finding.photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _Thumbnail(
                photo: finding.photos[i],
                onDelete: () => _confirmRemove(context, i),
              ),
            ),
          ),
        if (finding.hasPhotos) const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _capture(context),
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: Text(
              bn ? 'ছবি তুলুন' : 'Take a photograph',
              style: theme.textTheme.labelLarge,
            ),
          ),
        ),
      ],
    );
  }

  /// One stray tap must not destroy evidence. Deleting an inspection already
  /// asks first; a photograph inside it is worth at least as much.
  Future<void> _confirmRemove(BuildContext context, int index) async {
    final bn = context.locale.isBangla;
    final evidence = context.evidence;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(bn ? 'ছবিটি মুছে ফেলবেন?' : 'Remove this photograph?'),
        content: Text(bn
            ? 'ছবি মুছে গেলে আর ফেরানো যাবে না। সাইট বদলে গেলে একই ছবি আর তোলা '
                'যাবে না।'
            : 'A removed photograph cannot be recovered, and once the site has '
                'moved on it cannot be taken again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.t(S.cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(bn ? 'মুছে ফেলুন' : 'Remove'),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    await evidence.remove(finding.photos[index].name);
    finding.photos.removeAt(index);
    onChanged();
  }

  Future<void> _capture(BuildContext context) async {
    final evidence = context.evidence;
    final messenger = ScaffoldMessenger.of(context);
    final bn = context.locale.isBangla;
    try {
      // Written down before the camera opens, because if Android kills this
      // process while the camera is in front the picture still gets taken and
      // this is the only record of what it was of. Cleared on every way out.
      final lost = LostCapture();
      await lost.awaiting(runId: runId, itemId: finding.item.id);
      final shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        // Enough to read a signboard or a tape measure, small enough that a
        // long inspection does not fill a cheap handset.
        maxWidth: 1600,
        imageQuality: 80,
      );
      await lost.settled();
      if (shot == null) return;
      final photo = await evidence.addWithContext(
        File(shot.path),
        runId: runId,
        itemId: finding.item.id,
        takenAt: DateTime.now(),
      );
      finding.photos.add(photo);
      onChanged();
    } catch (_) {
      messenger.showSnackBar(SnackBar(
        content: Text(bn
            ? 'ছবি তোলা গেল না। ক্যামেরার অনুমতি আছে কি না দেখুন।'
            : 'Could not take the photograph. Check the camera permission.'),
      ));
    }
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.photo, required this.onDelete});

  final PhotoRef photo;
  final Future<void> Function() onDelete;

  void _open(BuildContext context, File file) {
    final caption = photo.describe(context.locale);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          // Dark chrome: a pale app bar over a black backdrop reads as a bug.
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(caption,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
          body: Center(child: InteractiveViewer(child: Image.file(file))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: context.evidence.file(photo.name),
      builder: (context, snap) {
        final file = snap.data;
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 96,
                height: 96,
                child: file == null
                    ? ColoredBox(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined),
                      )
                    : InkWell(
                        onTap: () => _open(context, file),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: IconButton(
                tooltip: context.locale.isBangla ? 'সরান' : 'Remove',
                icon: const Icon(Icons.cancel, size: 20),
                onPressed: onDelete,
              ),
            ),
          ],
        );
      },
    );
  }
}
