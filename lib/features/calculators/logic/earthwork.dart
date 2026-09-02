import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// Excavation: the hole, the heap it makes, and the trips to carry it away.
///
/// The hole and the heap are not the same size. Earth that has been dug loosens
/// and takes up more room than it did in the ground — "bulking" — so a hole of
/// 100 cubic feet becomes a heap of 120 or 130, and the lorry count follows the
/// heap, not the hole. Bills are written against one measure and trucks are
/// counted against the other, which is where the argument starts.
///
/// The bulking percentage is asked for rather than assumed. No source this app
/// holds gives one: the PWD schedule prices excavation by volume in the ground
/// and never mentions swell, and the reference book does not carry a table.
/// The figures in [typicalBulking] are quoted ranges to start from, not
/// standards, and the answer moves a lot with how wet the ground is.
class EarthworkCalculator {
  const EarthworkCalculator();

  /// Swell ranges people commonly quote, by ground type. Rules of thumb.
  static const List<BulkingGuess> typicalBulking = [
    BulkingGuess(L10nText('বালু মাটি', 'Sandy soil'), 10, 15),
    BulkingGuess(L10nText('সাধারণ মাটি', 'Common earth'), 20, 30),
    BulkingGuess(L10nText('এঁটেল মাটি', 'Clay'), 30, 40),
  ];

  CalcResult compute({
    required double lengthFt,
    required double widthFt,
    required double depthFt,
    required double bulkingPercent,
    double? truckCapacityCft,
  }) {
    for (final d in [lengthFt, widthFt, depthFt]) {
      if (!d.isFinite || d <= 0) {
        throw CalcException(const L10nText(
          'গর্তের প্রতিটি মাপ শূন্যের বড় একটি সংখ্যা হতে হবে।',
          'Every dimension of the pit has to be a real number greater than '
              'zero.',
        ));
      }
    }
    if (!bulkingPercent.isFinite || bulkingPercent < 0) {
      throw CalcException(const L10nText(
        'মাটি ফোলার হার ঋণাত্মক হতে পারে না।',
        'The bulking percentage cannot be negative.',
      ));
    }
    if (truckCapacityCft != null &&
        (!truckCapacityCft.isFinite || truckCapacityCft <= 0)) {
      throw CalcException(const L10nText(
        'গাড়ির ধারণক্ষমতা শূন্যের বড় একটি সংখ্যা হতে হবে।',
        'The truck capacity has to be a real number greater than zero.',
      ));
    }

    final inGround = lengthFt * widthFt * depthFt;
    final loose = inGround * (1 + bulkingPercent / 100.0);

    final lines = <CalcLine>[
      CalcLine(
        key: 'in_ground_cft',
        label: const L10nText('মাটিতে গর্তের আয়তন', 'Volume of the pit in the ground'),
        value: inGround,
        unit: U.cft,
        emphasis: true,
      ),
      CalcLine(
        key: 'loose_cft',
        label: const L10nText('তুলে ফেলার পর স্তূপের আয়তন',
            'Volume of the heap once it is dug out'),
        value: loose,
        unit: U.cft,
      ),
    ];
    if (truckCapacityCft != null) {
      lines.add(CalcLine(
        key: 'trips',
        label: const L10nText('কত ট্রিপ লাগবে', 'Trips needed'),
        value: (loose / truckCapacityCft).ceilToDouble(),
        unit: const L10nText('ট্রিপ', 'trips'),
        decimals: 0,
        emphasis: true,
      ));
    }

    return CalcResult(
      lines: lines,
      formula: L10nText(
        'গর্ত = ${_fmt(lengthFt)} × ${_fmt(widthFt)} × ${_fmt(depthFt)} = '
            '${_fmt(inGround)} ঘনফুট। স্তূপ = ${_fmt(inGround)} × '
            '(১ + ${_fmt(bulkingPercent)}%) = ${_fmt(loose)} ঘনফুট।'
            '${truckCapacityCft == null ? '' : ' ট্রিপ = ${_fmt(loose)} ÷ '
                '${_fmt(truckCapacityCft)}, উপরের পূর্ণসংখ্যায়।'}',
        'Pit = ${_fmt(lengthFt)} × ${_fmt(widthFt)} × ${_fmt(depthFt)} = '
            '${_fmt(inGround)} cft. Heap = ${_fmt(inGround)} × '
            '(1 + ${_fmt(bulkingPercent)}%) = ${_fmt(loose)} cft.'
            '${truckCapacityCft == null ? '' : ' Trips = ${_fmt(loose)} ÷ '
                '${_fmt(truckCapacityCft)}, rounded up.'}',
      ),
      assumptions: [
        L10nText(
          'মাটি ফুলে ${_fmt(bulkingPercent)}% বাড়ে ধরা হয়েছে — আপনি যা '
              'দিয়েছেন। এটি অ্যাপের কোনো মান নয়; ভেজা মাটিতে এটি অনেক বদলায়।',
          'Bulking taken as ${_fmt(bulkingPercent)}%, as you entered it. This '
              'is not a standard the app holds, and wet ground moves it a lot.',
        ),
        const L10nText(
          'বিল সাধারণত গর্তের মাপে হয়, আর ট্রাক গোনা হয় স্তূপের মাপে। দুটো এক '
              'নয় — দাবি করার সময় কোনটা বলছেন তা স্পষ্ট রাখুন।',
          'Bills are usually written against the pit and trucks are counted '
              'against the heap. They are not the same measure: be clear which '
              'one a claim is using.',
        ),
        const L10nText(
          'গর্ত সোজা দেয়ালের ধরা হয়েছে। ঢালু করে কাটলে আয়তন বাড়বে।',
          'The pit is taken as straight-sided. Battered sides make it bigger.',
        ),
      ],
      note: const L10nText(
        'গর্ত ভরাট করার আগে মেপে নিন। ঢালাই পড়ে গেলে গভীরতা আর মাপা যায় না।',
        'Measure the pit before it is filled. Once concrete is in, the depth '
            'cannot be checked again.',
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

/// A quoted swell range for a ground type. Rule of thumb, not a standard.
class BulkingGuess {
  const BulkingGuess(this.label, this.lowPercent, this.highPercent);

  final L10nText label;
  final double lowPercent;
  final double highPercent;

  double get midPercent => (lowPercent + highPercent) / 2;
}
