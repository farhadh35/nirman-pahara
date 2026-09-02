import '../../../core/i18n/app_locale.dart';
import 'boq_models.dart';
import 'expected_items.dart';

/// How much attention a finding deserves.
enum BoqSeverity { note, question, flag }

/// Something worth asking about in a bill of quantities.
///
/// Every finding is a question with the arithmetic attached, never a verdict.
/// A quantity that ran over may be a genuine site change; a rate that differs
/// between two lines may be two genuinely different jobs. What the app can do
/// is make the gap visible and name the document that would explain it.
class BoqFinding {
  const BoqFinding({
    required this.severity,
    required this.title,
    required this.detail,
    required this.ask,
    this.serial,
    this.amount,
  });

  final BoqSeverity severity;
  final L10nText title;
  final L10nText detail;

  /// What to ask for, in the words a request should use.
  final L10nText ask;

  final String? serial;

  /// Money involved, where the finding has a number attached to it.
  final double? amount;
}

/// Runs the checks a citizen could do by hand on a bill of quantities, if they
/// had the patience and knew what to look for.
class BoqAnalyzer {
  const BoqAnalyzer({
    this.overrunThresholdPercent = 25,
    this.arithmeticTolerance = 1.0,
  });

  /// Beyond this, a measured quantity exceeding the scheduled one is worth a
  /// question rather than a shrug.
  final double overrunThresholdPercent;

  /// Rounding slack, in taka, before an arithmetic mismatch is reported.
  final double arithmeticTolerance;

  /// Runs the checks. Pass [profile] to also look for the items a work of that
  /// kind would normally carry.
  List<BoqFinding> analyse(BoqDocument doc, {WorkProfile? profile}) => [
        ..._missingItems(doc, profile),
        ..._unscheduledItems(doc),
        ..._quantityOverruns(doc),
        ..._notExecuted(doc),
        ..._arithmetic(doc),
        ..._duplicateSerials(doc),
        ..._inconsistentRates(doc),
        ..._totalMismatch(doc),
      ]..sort((a, b) => b.severity.index.compareTo(a.severity.index));

  /// Items the work would normally carry that no line seems to cover.
  ///
  /// A missing item is a question and nothing more: the work may sit in
  /// another package, or the structure may genuinely not need it. But a store
  /// with no damp proof course, or a road with no sub-base, is worth asking
  /// about while the money can still be held.
  List<BoqFinding> _missingItems(BoqDocument doc, WorkProfile? profile) {
    if (profile == null || doc.lines.isEmpty) return const [];
    final descriptions = doc.lines.map((l) => l.description).toList();
    return [
      for (final item in profile.missingFrom(descriptions))
        BoqFinding(
          severity: item.critical ? BoqSeverity.question : BoqSeverity.note,
          title: L10nText(
            'তালিকায় নেই: ${item.name.bn}',
            'Not in the schedule: ${item.name.en ?? item.name.bn}',
          ),
          detail: L10nText(
            '${profile.name.bn} কাজে সাধারণত এই আইটেম থাকে, কিন্তু এই তালিকায় '
                'পাওয়া গেল না। ${item.why.bn}',
            'A ${(profile.name.en ?? profile.name.bn).toLowerCase()} normally '
                'carries this item, and no line here appears to cover it. '
                '${item.why.en}',
          ),
          ask: const L10nText(
            'কাজটা কি আলাদা প্যাকেজে আছে, নাকি নকশাতেই রাখা হয়নি — জানতে চান। '
                'নকশা ও সম্পূর্ণ তালিকার কপি চান।',
            'Ask whether the work sits in a separate package or was left out of '
                'the design, and request the drawings and the complete schedule.',
          ),
        ),
    ];
  }

  /// Work billed that the schedule never carried.
  List<BoqFinding> _unscheduledItems(BoqDocument doc) => [
        for (final l in doc.lines)
          if (!l.hasSchedule && l.hasMeasured)
            BoqFinding(
              severity: BoqSeverity.flag,
              serial: l.serial,
              amount: l.measuredAmount,
              title: const L10nText(
                'তফসিলে ছিল না, তবু বিল হয়েছে',
                'Billed although the schedule carried none',
              ),
              detail: L10nText(
                '${l.description} — তফসিলে পরিমাণ শূন্য, অথচ মাপা হয়েছে '
                    '${_n(l.measuredQuantity)} ${l.unit ?? ''}।',
                '${l.description} — the schedule carries no quantity, yet '
                    '${_n(l.measuredQuantity)} ${l.unit ?? ''} was measured.',
              ),
              ask: const L10nText(
                'এই আইটেমটা কোন অনুমোদনে যোগ হলো — ভেরিয়েশন অর্ডার বা সংশোধিত '
                    'অনুমিত হিসাবের কপি চান।',
                'Ask under what approval this item was added — request the '
                    'variation order or the revised estimate.',
              ),
            ),
      ];

  /// Measured far beyond what was scheduled.
  List<BoqFinding> _quantityOverruns(BoqDocument doc) => [
        for (final l in doc.lines)
          if ((l.overrunPercent ?? 0) > overrunThresholdPercent)
            BoqFinding(
              severity: (l.overrunPercent ?? 0) > 100
                  ? BoqSeverity.flag
                  : BoqSeverity.question,
              serial: l.serial,
              amount: (l.measuredAmount ?? 0) - (l.scheduleAmount ?? 0),
              title: const L10nText(
                'পরিমাণ তফসিলের চেয়ে অনেক বেশি',
                'Quantity far beyond the schedule',
              ),
              detail: L10nText(
                '${l.description} — তফসিলে ${_n(l.scheduleQuantity)}, '
                    'মাপা হয়েছে ${_n(l.measuredQuantity)} ${l.unit ?? ''} '
                    '(${_n(l.overrunPercent)}% বেশি)।',
                '${l.description} — scheduled ${_n(l.scheduleQuantity)}, '
                    'measured ${_n(l.measuredQuantity)} ${l.unit ?? ''} '
                    '(${_n(l.overrunPercent)}% more).',
              ),
              ask: const L10nText(
                'পরিমাপ বইয়ের প্রাসঙ্গিক পাতা ও ভেরিয়েশন অনুমোদনের কপি চান।',
                'Ask for the relevant measurement book pages and the approval '
                    'for the variation.',
              ),
            ),
      ];

  /// Scheduled and paid for in the contract, but nothing done on the ground.
  List<BoqFinding> _notExecuted(BoqDocument doc) => [
        for (final l in doc.lines)
          if (l.hasSchedule && !l.hasMeasured && (l.scheduleAmount ?? 0) > 0)
            BoqFinding(
              severity: BoqSeverity.question,
              serial: l.serial,
              amount: l.scheduleAmount,
              title: const L10nText(
                'তফসিলে আছে, কিন্তু কিছুই হয়নি',
                'Scheduled, but nothing done',
              ),
              detail: L10nText(
                '${l.description} — তফসিলে ${_n(l.scheduleQuantity)} '
                    '${l.unit ?? ''} ধরা, মাঠে শূন্য।',
                '${l.description} — the schedule carries '
                    '${_n(l.scheduleQuantity)} ${l.unit ?? ''}, and nothing '
                    'was measured.',
              ),
              ask: const L10nText(
                'কাজটি বাদ দেওয়া হয়েছে না বাকি আছে, আর চুক্তিমূল্য সেই অনুযায়ী '
                    'কমানো হয়েছে কি না জানতে চান।',
                'Ask whether the item was dropped or is still outstanding, and '
                    'whether the contract value was reduced accordingly.',
              ),
            ),
      ];

  /// Quantity times rate should equal the amount. Where it does not, either
  /// the rate, the quantity or the amount has been changed on its own.
  List<BoqFinding> _arithmetic(BoqDocument doc) {
    final out = <BoqFinding>[];
    for (final l in doc.lines) {
      if (!l.columnsTrusted) continue;
      for (final (implied, stated, which) in [
        (l.impliedScheduleAmount, l.scheduleAmount,
            const L10nText('তফসিল', 'schedule')),
        (l.impliedMeasuredAmount, l.measuredAmount,
            const L10nText('মাপা', 'measured')),
      ]) {
        if (implied == null || stated == null || stated == 0) continue;
        final gap = (implied - stated).abs();
        if (gap <= arithmeticTolerance || gap / stated < 0.005) continue;
        out.add(BoqFinding(
          severity: BoqSeverity.flag,
          serial: l.serial,
          amount: gap,
          title: const L10nText(
            'পরিমাণ × রেট ≠ টাকার অঙ্ক',
            'Quantity times rate does not equal the amount',
          ),
          detail: L10nText(
            '${l.description} — ${which.bn}: ${_n(l.rate)} × পরিমাণ থেকে আসে '
                '${_n(implied)}, কিন্তু লেখা আছে ${_n(stated)}।',
            '${l.description} — ${which.en}: rate ${_n(l.rate)} times the '
                'quantity gives ${_n(implied)}, but the sheet says '
                '${_n(stated)}.',
          ),
          ask: const L10nText(
            'এই লাইনের রেট অ্যানালাইসিস ও হিসাবের ব্যাখ্যা চান।',
            'Ask for the rate analysis and the working behind this line.',
          ),
        ));
      }
    }
    return out;
  }

  /// A serial repeated on the *same* work.
  ///
  /// Sub-items legitimately share their parent's serial — a footing, a column
  /// and a grade beam all sit under 1.05 — and two sections of one statement
  /// both number from 1.01. Only a serial carrying the same description twice
  /// is worth raising.
  List<BoqFinding> _duplicateSerials(BoqDocument doc) {
    final seen = <String, int>{};
    for (final l in doc.lines) {
      if (l.serial.trim().isEmpty) continue;
      final key = '${l.serial}|'
          '${l.description.toLowerCase().replaceAll(RegExp(r"\s+"), " ").trim()}';
      seen[key] = (seen[key] ?? 0) + 1;
    }
    return [
      for (final e in seen.entries.map(
          (e) => MapEntry(e.key.split('|').first, e.value)))
        if (e.value > 1)
          BoqFinding(
            severity: BoqSeverity.note,
            serial: e.key,
            title: const L10nText(
              'একই ক্রমিক নম্বর একাধিকবার',
              'The same serial number appears more than once',
            ),
            detail: L10nText(
              'ক্রমিক ${e.key} ${_n(e.value.toDouble())} বার এসেছে। ভুল টাইপ হতে '
                  'পারে, আবার দুটো আলাদা কাজ এক নম্বরে বসানোও হতে পারে।',
              'Serial ${e.key} appears ${e.value} times. It may be a typing '
                  'slip, or two different works sharing one number.',
            ),
            ask: const L10nText(
              'কোন লাইনটা কোন কাজের, স্পষ্ট করে জানতে চান।',
              'Ask which line covers which work.',
            ),
          ),
    ];
  }

  /// The same described work priced differently in one document.
  List<BoqFinding> _inconsistentRates(BoqDocument doc) {
    final byDesc = <String, List<BoqLine>>{};
    for (final l in doc.lines) {
      final key = l.description.toLowerCase().replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (key.isEmpty || l.rate == null) continue;
      byDesc.putIfAbsent(key, () => []).add(l);
    }
    final out = <BoqFinding>[];
    for (final e in byDesc.entries) {
      final rates = e.value.map((l) => l.rate!).toSet();
      if (rates.length < 2) continue;
      final low = rates.reduce((a, b) => a < b ? a : b);
      final high = rates.reduce((a, b) => a > b ? a : b);
      if (low <= 0 || (high - low) / low < 0.05) continue;
      out.add(BoqFinding(
        severity: BoqSeverity.question,
        serial: e.value.first.serial,
        title: const L10nText(
          'একই কাজের দুই রেট',
          'The same work at two different rates',
        ),
        detail: L10nText(
          '${e.value.first.description} — একই বর্ণনায় রেট ${_n(low)} থেকে '
              '${_n(high)} পর্যন্ত।',
          '${e.value.first.description} — the same description is priced from '
              '${_n(low)} to ${_n(high)}.',
        ),
        ask: const L10nText(
          'দুটো লাইনের পার্থক্য কোথায়, আর দুটোর রেট অ্যানালাইসিস চান।',
          'Ask what differs between the two lines, and for both rate analyses.',
        ),
      ));
    }
    return out;
  }

  /// The printed total against the sum of the document's own rows.
  List<BoqFinding> _totalMismatch(BoqDocument doc) {
    final out = <BoqFinding>[];
    // Only meaningful when the document printed a single total. With a total
    // per section plus a grand total, the sum of every line is not what any
    // one of them is claiming to be.
    if (doc.totalRowCount != 1) return out;
    for (final (stated, summed, which) in [
      (doc.statedScheduleTotal, doc.summedScheduleAmount,
          const L10nText('তফসিল', 'schedule')),
      (doc.statedMeasuredTotal, doc.summedMeasuredAmount,
          const L10nText('মাপা', 'measured')),
    ]) {
      if (stated == null || stated <= 0 || summed <= 0) continue;
      final gap = (stated - summed).abs();
      if (gap / stated < 0.01) continue;
      out.add(BoqFinding(
        severity: BoqSeverity.flag,
        amount: gap,
        title: const L10nText(
          'লাইনের যোগফল আর লেখা মোট মেলে না',
          'The printed total does not match the sum of the lines',
        ),
        detail: L10nText(
          '${which.bn} — লাইনগুলো যোগ করলে হয় ${_n(summed)}, কিন্তু লেখা মোট '
              '${_n(stated)}।',
          '${which.en} — the lines add up to ${_n(summed)}, but the printed '
              'total is ${_n(stated)}.',
        ),
        ask: const L10nText(
          'পূর্ণ বিল অব কোয়ান্টিটি ও সব পাতা চান — কিছু লাইন বাদ পড়ে থাকতে পারে।',
          'Ask for the complete bill of quantities and every page — some lines '
              'may be missing.',
        ),
      ));
    }
    return out;
  }

  static String _n(double? v) {
    if (v == null) return '—';
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
  }
}
