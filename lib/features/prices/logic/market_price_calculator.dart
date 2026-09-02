import '../../../core/i18n/app_locale.dart';
import '../../calculators/logic/calc_result.dart';
import 'price_models.dart';

/// Where a quoted price sits against the market band.
enum PricePosition {
  below('বাজারদরের নিচে', 'Below the market band'),
  inside('বাজারদরের মধ্যে', 'Inside the market band'),
  above('বাজারদরের উপরে', 'Above the market band');

  const PricePosition(this._bn, this._en);

  final String _bn;
  final String _en;

  L10nText get label => L10nText(_bn, _en);
}

/// Compares what someone is being charged with the market band for that
/// material.
///
/// Two different users need this. A homeowner wants to know whether the
/// contractor's rate is fair. A citizen monitor wants to know whether the rate
/// in an estimate is plausible. Both get the same answer shape: a position
/// against a dated band, never a verdict.
class MarketPriceCalculator {
  const MarketPriceCalculator();

  CalcResult compare({
    required MaterialPrice market,
    required double quotedBdt,
    double quantity = 1,
  }) {
    if (quotedBdt <= 0) {
      throw CalcException(const L10nText(
        'দর শূন্যের বেশি হতে হবে।',
        'The quoted price must be greater than zero.',
      ));
    }
    if (quantity <= 0) {
      throw CalcException(const L10nText(
        'পরিমাণ শূন্যের বেশি হতে হবে।',
        'The quantity must be greater than zero.',
      ));
    }

    final PricePosition position;
    if (quotedBdt < market.lowBdt) {
      position = PricePosition.below;
    } else if (quotedBdt > market.highBdt) {
      position = PricePosition.above;
    } else {
      position = PricePosition.inside;
    }

    final vsMidPercent =
        (quotedBdt - market.midBdt) / market.midBdt * 100;
    final totalQuoted = quotedBdt * quantity;
    final totalAtLow = market.lowBdt * quantity;
    final totalAtHigh = market.highBdt * quantity;

    return CalcResult(
      lines: [
        CalcLine(
          key: 'quoted',
          label: const L10nText('আপনাকে বলা দর', 'The price you were quoted'),
          value: quotedBdt,
          unit: U.taka,
          decimals: 0,
          emphasis: true,
        ),
        CalcLine(
          key: 'market_low',
          label: const L10nText('বাজারদর — সর্বনিম্ন', 'Market band — low'),
          value: market.lowBdt,
          unit: U.taka,
          decimals: 0,
        ),
        CalcLine(
          key: 'market_high',
          label: const L10nText('বাজারদর — সর্বোচ্চ', 'Market band — high'),
          value: market.highBdt,
          unit: U.taka,
          decimals: 0,
        ),
        CalcLine(
          key: 'vs_mid_percent',
          label: const L10nText(
            'বাজারদরের মাঝামাঝির তুলনায়',
            'Against the middle of the band',
          ),
          value: vsMidPercent,
          unit: U.percent,
          decimals: 1,
          emphasis: true,
        ),
        CalcLine(
          key: 'total_quoted',
          label: const L10nText('আপনার মোট খরচ', 'Your total at the quote'),
          value: totalQuoted,
          unit: U.taka,
          decimals: 0,
        ),
        CalcLine(
          key: 'total_at_low',
          label: const L10nText(
            'সর্বনিম্ন বাজারদরে মোট',
            'Total at the low end of the band',
          ),
          value: totalAtLow,
          unit: U.taka,
          decimals: 0,
        ),
        CalcLine(
          key: 'total_at_high',
          label: const L10nText(
            'সর্বোচ্চ বাজারদরে মোট',
            'Total at the high end of the band',
          ),
          value: totalAtHigh,
          unit: U.taka,
          decimals: 0,
        ),
        CalcLine(
          key: 'gap_vs_high',
          label: const L10nText(
            'সর্বোচ্চ বাজারদরের চেয়ে বাড়তি',
            'Above the top of the band',
          ),
          value: totalQuoted - totalAtHigh,
          unit: U.taka,
          decimals: 0,
        ),
      ],
      formula: const L10nText(
        'পার্থক্য % = (আপনার দর − বাজারদরের মাঝামাঝি) ÷ বাজারদরের মাঝামাঝি × ১০০\n'
            'মোট = দর × পরিমাণ',
        'Difference % = (your price − band midpoint) ÷ band midpoint × 100\n'
            'Total = price × quantity',
      ),
      assumptions: [
        L10nText(
          'বাজারদর সংগ্রহের তারিখ ${market.asOf}',
          'Market band gathered on ${market.asOf}',
        ),
        L10nText(
          'একক: ${market.unit.bn}',
          'Unit: ${market.unit.en ?? market.unit.bn}',
        ),
        if (market.region != null)
          L10nText(
            'এলাকা: ${market.region!.bn}',
            'Area: ${market.region!.en ?? market.region!.bn}',
          ),
        const L10nText(
          'পরিবহন, লেবার ও ঠিকাদারের লাভ এই দরে ধরা নেই',
          'Carrying, labour and the contractor\'s margin are not in this band',
        ),
      ],
      note: _note(position, vsMidPercent, market),
    );
  }

  L10nText _note(
    PricePosition position,
    double vsMidPercent,
    MaterialPrice market,
  ) {
    final abs = vsMidPercent.abs().toStringAsFixed(0);
    return switch (position) {
      PricePosition.inside => L10nText(
          'দরটা বাজারদরের ভেতরেই আছে (মাঝামাঝির চেয়ে $abs% পার্থক্য)। '
              'ব্র্যান্ড, গ্রেড আর দূরত্ব ভেদে এটুকু পার্থক্য স্বাভাবিক।',
          'The quote sits inside the band ($abs% off the midpoint). A gap this '
              'size is normal between brands, grades and distances.',
        ),
      PricePosition.above => L10nText(
          'বাজারদরের উপরে, মাঝামাঝির চেয়ে প্রায় $abs% বেশি। কারণ থাকতে পারে — '
              'ভালো ব্র্যান্ড, দূরে সরবরাহ, বাকিতে কেনা। কারণটা জিজ্ঞেস করুন, '
              'আর দুটো দোকানে আলাদা করে দাম জেনে নিন।',
          'Above the band, about $abs% over the midpoint. There may be reasons: '
              'a better brand, a long haul, buying on credit. Ask what the reason '
              'is, and price it at two other suppliers yourself.',
        ),
      PricePosition.below => L10nText(
          'বাজারদরের নিচে, মাঝামাঝির চেয়ে প্রায় $abs% কম। সস্তা মানেই ভালো নয় — '
              'অস্বাভাবিক কম দরে মালের গ্রেড বা মান কম হওয়ার ঝুঁকি থাকে। '
              'ডেলিভারির সময় ব্র্যান্ড ও গ্রেড মিলিয়ে দেখুন।',
          'Below the band, about $abs% under the midpoint. Cheap is not the same '
              'as good — an unusually low rate often means a lower grade. Check '
              'the brand and grade against the paperwork at delivery.',
        ),
    };
  }
}
