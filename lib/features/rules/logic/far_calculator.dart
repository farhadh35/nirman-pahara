import '../../../core/i18n/app_locale.dart';
import '../../calculators/logic/calc_result.dart';
import 'far_rules.dart';

/// Turns a plot and the road in front of it into a floor area ceiling.
///
/// This is the question every landowner asks first and is most often answered
/// wrongly, usually by whoever wants to sell them a design. The gazette answers
/// it in one table, and the table is short enough to check.
///
/// What this deliberately does not do is tell anyone what they may build. FAR
/// is one ceiling among several — setbacks, maximum ground coverage, height
/// limits and the detailed area plan all cut into the same envelope, and the
/// approved figure is whichever of them bites first. A number from here is the
/// start of a conversation with RAJUK, never the end of one.
class FarCalculator {
  const FarCalculator({required this.pack});

  final FarPack pack;

  CalcResult compute({
    required double plotAreaSft,
    required double roadWidthM,
    required String useCode,
    String? zone,
    int? storeys,
  }) {
    if (!plotAreaSft.isFinite || plotAreaSft <= 0) {
      throw CalcException(const L10nText(
        'জমির ক্ষেত্রফল শূন্যের বড় একটি সংখ্যা হতে হবে।',
        'The plot area has to be a real number greater than zero.',
      ));
    }
    if (!roadWidthM.isFinite || roadWidthM <= 0) {
      throw CalcException(const L10nText(
        'রাস্তার প্রশস্ততা শূন্যের বড় একটি সংখ্যা হতে হবে।',
        'The road width has to be a real number greater than zero.',
      ));
    }
    if (storeys != null && storeys < 1) {
      throw CalcException(const L10nText(
        'তলার সংখ্যা অন্তত ১ হতে হবে।',
        'The number of storeys has to be at least 1.',
      ));
    }

    final use = pack.use(useCode, zone: zone);
    if (use == null) {
      throw CalcException(L10nText(
        'এই ব্যবহারের জন্য সারণিতে কোনো সারি নেই: $useCode।',
        'The table carries no row for this use: $useCode.',
      ));
    }

    final band = pack.bandIndex(roadWidthM);
    if (band == null) {
      throw CalcException(const L10nText(
        'সারণি-৫ ১.৮ মিটারের সরু রাস্তার জন্য কোনো FAR দেয় না। এত সরু রাস্তায় '
            'কী করা যায় তা রাজউকের কাছেই জানতে হবে।',
        'Table 5 gives no FAR for a road narrower than 1.8 m. What is possible '
            'on a road that narrow is a question only RAJUK can answer.',
      ));
    }

    final far = use.far[band];
    if (far == null) {
      // Say what road would carry it. A refusal on its own tells the reader
      // their road will not do and leaves them with nowhere to go next; the
      // table already knows the answer, so it may as well be read out.
      final narrowest = use.narrowestPermittedBand;
      final needs = narrowest == null
          ? const L10nText(
              'সারণি-৫ কোনো প্রশস্ততার রাস্তাতেই এই ব্যবহারের জন্য FAR দেয় না।',
              'Table 5 gives this use no figure at any road width.',
            )
          : L10nText(
              'সারণি-৫ অনুযায়ী এই ব্যবহার সবচেয়ে সরু যে রাস্তায় চলে, তা '
                  '${pack.roadBands[narrowest].label.bn}।',
              'The narrowest road Table 5 allows this use on is '
                  '${pack.roadBands[narrowest].label.en}.',
            );
      throw CalcException(L10nText(
        '${use.labelBn} — এই ব্যবহার ${RoadBand.fmtMetres(roadWidthM)} মিটার চওড়া '
            'রাস্তায় সারণি-৫ অনুযায়ী অনুমোদনযোগ্য নয়। এটা শূন্য FAR নয়, '
            'এই রাস্তায় এই ব্যবহারই নয়। ${needs.bn}',
        '${use.label(AppLocale.en)}: Table 5 does not permit this use on a '
            'road ${RoadBand.fmtMetres(roadWidthM)} m wide. That is not a FAR '
            'of zero, it is a use the road does not carry. ${needs.en}',
      ));
    }

    final maxFloorArea = plotAreaSft * far;
    final lines = <CalcLine>[
      CalcLine(
        key: 'far',
        label: const L10nText('FAR সূচক', 'FAR index'),
        value: far,
        unit: const L10nText('', ''),
        emphasis: true,
      ),
      CalcLine(
        key: 'max_floor_area_sft',
        label: const L10nText(
            'সব তলা মিলিয়ে সর্বোচ্চ মেঝে', 'Maximum floor area, all storeys'),
        value: maxFloorArea,
        unit: U.sft,
        decimals: 0,
        emphasis: true,
      ),
    ];
    if (storeys != null) {
      lines.add(CalcLine(
        key: 'per_floor_sft',
        label: L10nText('$storeys তলা হলে প্রতি তলায় গড়ে',
            'Average per floor across $storeys storeys'),
        value: maxFloorArea / storeys,
        unit: U.sft,
        decimals: 0,
      ));
    }

    final bandLabel = pack.roadBands[band].label;
    return CalcResult(
      lines: lines,
      formula: L10nText(
        'সর্বোচ্চ মেঝে = জমির ক্ষেত্রফল × FAR = ${_fmt(plotAreaSft)} বর্গফুট × '
            '${_fmt(far)} = ${_fmt(maxFloorArea)} বর্গফুট। '
            'FAR ${_fmt(far)} এসেছে সারণি-৫ থেকে: ${use.labelBn}, রাস্তা '
            '${bandLabel.bn}।',
        'Maximum floor area = plot area × FAR = ${_fmt(plotAreaSft)} sft × '
            '${_fmt(far)} = ${_fmt(maxFloorArea)} sft. The FAR of ${_fmt(far)} '
            'comes from Table 5: ${use.label(AppLocale.en)}, road '
            '${bandLabel.en}.',
      ),
      assumptions: [
        L10nText(
          'সূত্র: ${pack.sourceBn}।',
          'Source: ${pack.sourceEn}.',
        ),
        L10nText(
          'রাস্তার প্রশস্ততা ধরা হয়েছে ${RoadBand.fmtMetres(roadWidthM)} মিটার, যা '
              'সারণির "${bandLabel.bn}" ঘরে পড়ে।',
          'Road width taken as ${RoadBand.fmtMetres(roadWidthM)} m, which falls in the '
              '"${bandLabel.en}" column.',
        ),
        const L10nText(
          'সারণির শেষ ছয়টি ঘরে গেজেটে একটিমাত্র প্রশস্ততা ছাপা আছে, কোনো '
              'পরিসর নয়। এই অ্যাপ ধরে নিয়েছে প্রতিটি ঘর ওই মাপ থেকে পরের মাপের '
              'ঠিক আগ পর্যন্ত চলে — এটি পাঠ, গেজেটের বয়ান নয়।',
          'The gazette prints a single width, not a range, in the last six '
              'columns. This app reads each column as running from that width '
              'up to just below the next one. That is an interpretation, not '
              'the gazette\'s own wording.',
        ),
        const L10nText(
          'জমির ক্ষেত্রফল আপনি যা দিয়েছেন তা-ই ধরা হয়েছে — দলিলের মাপ আর '
              'দখলের মাপ এক না হলে ফল বদলে যাবে।',
          'The plot area is taken exactly as entered. If the deed and what is '
              'actually held differ, so does this answer.',
        ),
        if (use.notRecommended)
          const L10nText(
            'গেজেট এই সারির সবচেয়ে চওড়া রাস্তার ঘরে "*NR" লিখেছে — অর্থাৎ '
                'সেখানে সংখ্যাটি থাকলেও সুপারিশ করা হয়নি।',
            'The gazette marks the widest-road cell of this row "*NR": the '
                'figure is printed, but it is not recommended.',
          ),
      ],
      // Said once, here, rather than repeated in a card underneath it: this
      // note travels with the result when it is copied, which is where it
      // needs to be.
      note: const L10nText(
        'রাস্তাভিত্তিক FAR-এর ছাদ, অনুমোদন নয়। সেটব্যাক, ভূমি আচ্ছাদন, '
            'উচ্চতার সীমা ও ড্যাপ একই খাম ছোট করে — যেটি আগে বাধে সেটিই '
            'চূড়ান্ত। নকশার আগে রাজউকে যাচাই করে নিন।',
        'The road-based FAR ceiling, not an approval. Setbacks, ground '
            'coverage, height limits and the DAP cut the same envelope — '
            'whichever binds first governs. Check with RAJUK before you '
            'design to it.',
      ),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
}
