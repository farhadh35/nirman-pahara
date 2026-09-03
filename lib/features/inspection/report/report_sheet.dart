import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/i18n/app_locale.dart';
import '../../../core/util/bn.dart';
import '../logic/inspection_run.dart';

/// The printable report: the same findings as the text version, with each
/// photograph sitting beside the item it belongs to rather than arriving as a
/// loose attachment somebody has to match up by hand.
///
/// Laid out in Flutter so that Bangla shapes correctly — see [ReportDocument].
class ReportSheet extends StatelessWidget {
  const ReportSheet({
    super.key,
    required this.run,
    required this.locale,
    required this.photoFiles,
  });

  final InspectionRun run;
  final AppLocale locale;

  /// Resolved photograph files, keyed by the name stored on the finding.
  final Map<String, File> photoFiles;

  bool get _bn => locale.isBangla;

  static const _ink = Color(0xFF1A1C19);
  static const _muted = Color(0xFF5A5F58);
  static const _rule = Color(0xFFCBD2C6);
  static const _accent = Color(0xFF006A4E);
  static const _alert = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(56, 48, 56, 48),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'NotoSansBengali',
          color: _ink,
          fontSize: 15,
          height: 1.6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(height: 24),
            _summary(),
            const SizedBox(height: 28),
            if (run.problems.isNotEmpty) ...[
              _sectionTitle(
                _bn ? 'যেসব বিষয়ে সমস্যা দেখা গেছে' : 'Where a problem was seen',
                colour: _alert,
              ),
              for (final f in run.problems) _finding(f, number: true),
              const SizedBox(height: 12),
            ],
            if (run.unsure.isNotEmpty) ...[
              _sectionTitle(_bn ? 'যা বোঝা যায়নি' : 'Could not tell'),
              for (final f in run.unsure) _finding(f),
              const SizedBox(height: 12),
            ],
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    String line(String label, String value) => '$label: $value';
    final u = run.date;
    String two(int v) => v.toString().padLeft(2, '0');
    final date = Bn.localiseDigits(
      '${u.year}-${two(u.month)}-${two(u.day)}',
      locale,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _bn ? 'পরিদর্শন রিপোর্ট' : 'Inspection report',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _accent,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _bn ? 'নির্মাণ পাহারা' : 'Nirman Pahara',
          style: const TextStyle(fontSize: 13, color: _muted),
        ),
        const SizedBox(height: 16),
        Container(height: 2, color: _accent),
        const SizedBox(height: 16),
        Text(line(_bn ? 'কাজ' : 'Work', run.projectName),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        if (run.location.isNotEmpty)
          Text(line(_bn ? 'অবস্থান' : 'Location', run.location)),
        if (run.tenderId.isNotEmpty)
          Text(line(_bn ? 'টেন্ডার আইডি' : 'Tender ID',
              Bn.localiseDigits(run.tenderId, locale))),
        Text(line(_bn ? 'ধরন' : 'Type', run.pack.title.of(locale))),
        Text(line(_bn ? 'তারিখ' : 'Date', date)),
      ],
    );
  }

  Widget _summary() {
    Widget cell(String label, String value, {Color? colour}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 13, color: _muted)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: colour ?? _ink,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );

    String n(int v) =>
        Bn.number(v.toDouble(), decimals: 0, locale: locale);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: _rule),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          cell(_bn ? 'দেখা হয়েছে' : 'Checked',
              '${n(run.answered.length)} / ${n(run.total)}'),
          cell(_bn ? 'সমস্যা' : 'Problems', n(run.problems.length),
              colour: run.problems.isEmpty ? null : _alert),
          cell(_bn ? 'ছবি' : 'Photographs', n(run.photoCount)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, {Color? colour}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: colour ?? _accent,
            height: 1.4,
          ),
        ),
      );

  Widget _finding(Finding f, {bool number = false}) {
    final item = f.item;
    final files = [
      for (final p in f.photos)
        if (photoFiles[p.name] != null) (p, photoFiles[p.name]!),
    ];
    // A photograph whose file has gone — storage cleared, or removed outside
    // the app — was dropped from the report without a word. The reader takes
    // this document to an authority believing it carries the evidence they
    // gathered, so a report missing a picture has to say it is missing one.
    final missing = f.photos.length - files.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: _rule),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question.of(locale),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (item.standard != null)
            _labelled(
              _bn ? 'নিয়মে যা থাকার কথা' : 'What the rule requires',
              item.standard!.of(locale),
            ),
          _labelled(_bn ? 'কেন জরুরি' : 'Why it matters', item.why.of(locale)),
          if (f.note.trim().isNotEmpty)
            _labelled(
              _bn ? 'যা দেখা গেছে' : 'What was seen',
              f.note.trim(),
              emphasise: true,
            ),
          if (missing > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _bn
                    ? '$missing টি ছবি এই রিপোর্টে যুক্ত করা যায়নি — '
                        'ফাইলটি ফোনে আর পাওয়া যাচ্ছে না।'
                    : '$missing photograph${missing == 1 ? '' : 's'} could not '
                        'be included: the file is no longer on the phone.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: _accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (files.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (photo, file) in files)
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 300,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          photo.describe(locale),
                          style:
                              const TextStyle(fontSize: 12, color: _muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _labelled(String label, String value, {bool emphasise = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'NotoSansBengali',
              fontSize: 15,
              color: _ink,
              height: 1.6,
            ),
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(color: _muted),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontWeight: emphasise ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _footer() => Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _rule)),
        ),
        child: Text(
          _bn
              ? 'এই রিপোর্ট একজন সাধারণ নাগরিকের চোখে দেখা বিবরণ। এটি কোনো '
                  'প্রকৌশল পরীক্ষা বা আইনি সিদ্ধান্ত নয়। প্রতিটি বিষয়ে নিয়ম কী বলে '
                  'আর কী দেখা গেছে — দুটোই আলাদা করে লেখা হয়েছে, যাতে কর্তৃপক্ষ '
                  'নিজে যাচাই করতে পারে।'
              : 'This report records what an ordinary citizen observed. It is '
                  'not an engineering test or a legal finding. For each point, '
                  'what the rule requires and what was seen are stated '
                  'separately, so that the authority can verify it themselves.',
          style: const TextStyle(fontSize: 13, color: _muted, height: 1.6),
        ),
      );
}
