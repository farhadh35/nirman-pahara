import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// Paint: how many litres a surface takes.
///
/// Coverage is deliberately not built in. Every tin sold in Bangladesh prints
/// its own spreading rate, brands differ by a third or more, and a porous new
/// plaster drinks far more than a repaint over old paint. No source this app
/// holds — not the PWD schedule, which prices paint by the kilogram and the
/// square metre, and not the reference book — states litres per square foot.
/// So the figure comes off the tin in the buyer's hand, and the calculator
/// says so rather than inventing an average.
class PaintCalculator {
  const PaintCalculator();

  /// Spreading rates people commonly quote, for a first guess before the tin
  /// is bought. Rules of thumb, not standards: check the tin and re-run.
  static const List<PaintGuess> typicalCoverage = [
    PaintGuess(L10nText('প্লাস্টিক / ইমালশন', 'Plastic / emulsion'), 100, 120),
    PaintGuess(L10nText('এনামেল', 'Enamel'), 130, 160),
    PaintGuess(L10nText('নতুন প্লাস্টারে প্রথম কোট', 'First coat on new plaster'),
        70, 90),
  ];

  CalcResult compute({
    required double surfaceSft,
    required double coverageSftPerLitre,
    int coats = 2,
    double openingsSft = 0,
    double wastagePercent = 5.0,
  }) {
    if (!surfaceSft.isFinite || surfaceSft <= 0) {
      throw CalcException(const L10nText(
        'রং করার ক্ষেত্রফল শূন্যের বড় একটি সংখ্যা হতে হবে।',
        'The area to be painted has to be a real number greater than zero.',
      ));
    }
    if (!coverageSftPerLitre.isFinite || coverageSftPerLitre <= 0) {
      throw CalcException(const L10nText(
        'কৌটার গায়ে লেখা কভারেজ (প্রতি লিটারে কত বর্গফুট) দিতে হবে।',
        'The coverage printed on the tin — square feet per litre — is needed.',
      ));
    }
    if (coats < 1) {
      throw CalcException(const L10nText(
        'কোটের সংখ্যা অন্তত ১ হতে হবে।',
        'There has to be at least one coat.',
      ));
    }
    if (!openingsSft.isFinite || openingsSft < 0 || openingsSft >= surfaceSft) {
      throw CalcException(const L10nText(
        'দরজা-জানালার ক্ষেত্রফল ঋণাত্মক হতে পারে না, আর মোট ক্ষেত্রফলের চেয়ে '
            'বড়ও হতে পারে না।',
        'The openings cannot be negative, nor as large as the whole surface.',
      ));
    }
    if (!wastagePercent.isFinite || wastagePercent < 0) {
      throw CalcException(const L10nText(
        'অপচয় ঋণাত্মক হতে পারে না।',
        'Wastage cannot be negative.',
      ));
    }

    final net = surfaceSft - openingsSft;
    final litresNet = net * coats / coverageSftPerLitre;
    final litres = litresNet * (1 + wastagePercent / 100.0);

    return CalcResult(
      lines: [
        CalcLine(
          key: 'litres',
          label: const L10nText('রং লাগবে', 'Paint needed'),
          value: litres,
          unit: U.litre,
          decimals: 1,
          emphasis: true,
        ),
        CalcLine(
          key: 'litres_net',
          label: const L10nText('অপচয় বাদে', 'Before wastage'),
          value: litresNet,
          unit: U.litre,
          decimals: 1,
        ),
        CalcLine(
          key: 'net_area_sft',
          label: const L10nText('বাদ দেওয়ার পর ক্ষেত্রফল', 'Area after deductions'),
          value: net,
          unit: U.sft,
          decimals: 0,
        ),
      ],
      formula: L10nText(
        'রং = (ক্ষেত্রফল − ফাঁকা) × কোট ÷ কভারেজ = (${_fmt(surfaceSft)} − '
            '${_fmt(openingsSft)}) × $coats ÷ ${_fmt(coverageSftPerLitre)} = '
            '${litresNet.toStringAsFixed(1)} লিটার, তার সঙ্গে '
            '${_fmt(wastagePercent)}% অপচয়।',
        'Paint = (area − openings) × coats ÷ coverage = (${_fmt(surfaceSft)} − '
            '${_fmt(openingsSft)}) × $coats ÷ ${_fmt(coverageSftPerLitre)} = '
            '${litresNet.toStringAsFixed(1)} litres, plus '
            '${_fmt(wastagePercent)}% for wastage.',
      ),
      assumptions: [
        L10nText(
          'কভারেজ ${_fmt(coverageSftPerLitre)} বর্গফুট প্রতি লিটার — আপনি যা '
              'দিয়েছেন। এটি অ্যাপের ধরে নেওয়া কোনো গড় নয়; কৌটার গায়ে লেখা '
              'সংখ্যাটাই দিন।',
          'Coverage of ${_fmt(coverageSftPerLitre)} sft per litre, as you '
              'entered it. This is not an average the app assumed: use the '
              'number printed on the tin.',
        ),
        L10nText(
          '$coats কোট ধরা হয়েছে।',
          'Worked for $coats coat${coats == 1 ? '' : 's'}.',
        ),
        const L10nText(
          'নতুন প্লাস্টার প্রথম কোটে অনেক বেশি রং টানে। প্রথম কোটের জন্য আলাদা '
              'করে হিসাব করুন।',
          'New plaster drinks far more on the first coat. Work the first coat '
              'out separately.',
        ),
      ],
      note: const L10nText(
        'ব্র্যান্ডভেদে কভারেজ এক-তৃতীয়াংশ পর্যন্ত আলাদা হয়। এক কৌটা কিনে '
            'বাস্তবে কতটা গেল দেখে বাকিটা কিনুন।',
        'Coverage differs between brands by as much as a third. Buy one tin, '
            'see how far it actually goes, then buy the rest.',
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

/// A quoted spreading-rate range, for the picker. Rule of thumb, not standard.
class PaintGuess {
  const PaintGuess(this.label, this.lowSftPerLitre, this.highSftPerLitre);

  final L10nText label;
  final double lowSftPerLitre;
  final double highSftPerLitre;

  double get midSftPerLitre => (lowSftPerLitre + highSftPerLitre) / 2;
}
