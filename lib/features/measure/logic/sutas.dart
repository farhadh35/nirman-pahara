import '../../../core/i18n/app_locale.dart';

/// Rod sizes in the unit masons actually speak: সুতা.
///
/// A সুতা is one eighth of an inch, so "৩-সুতা রড" is a 3/8 inch bar, which the
/// shop will label 10 mm. Every drawing, schedule and calculator in this app
/// works in millimetres. Every rod binder on every site in Bangladesh works in
/// সুতা. Someone standing at the steel asking whether the right bar went in
/// needs to cross that gap, and the app asking them for millimetres is the app
/// asking the wrong question.
///
/// The millimetre column is the nominal bar the trade sells against each সুতা,
/// not an exact conversion: 3/8 inch is 9.525 mm and the bar sold for it is
/// 10 mm. Both numbers are given so the difference is visible rather than
/// quietly rounded away.
enum SutaSize {
  two(2, 6),
  three(3, 10),
  four(4, 12),
  five(5, 16),
  six(6, 20),
  seven(7, 22),
  eight(8, 25);

  const SutaSize(this.suta, this.nominalMm);

  /// How many eighths of an inch.
  final int suta;

  /// The bar the trade sells for this সুতা, in millimetres.
  final int nominalMm;

  /// Exact diameter in inches: সুতা are eighths.
  double get inches => suta / 8.0;

  /// Exact diameter in millimetres, before the trade rounds it to a stock size.
  double get exactMm => inches * 25.4;

  /// How far the stock bar is from the exact fraction, in millimetres.
  double get roundingMm => nominalMm - exactMm;

  L10nText get label => L10nText('$suta সুতা', '$suta suta');

  /// The fraction as it is written and spoken, reduced: 4 suta is a half inch,
  /// not two quarters.
  String get inchLabel {
    var num = suta, den = 8;
    final g = _gcd(num, den);
    num ~/= g;
    den ~/= g;
    return den == 1 ? '$num"' : '$num/$den"';
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  static SutaSize? forSuta(int suta) {
    for (final s in SutaSize.values) {
      if (s.suta == suta) return s;
    }
    return null;
  }

  /// The সুতা a millimetre bar is sold as, or null when nothing matches.
  static SutaSize? forMm(int mm) {
    for (final s in SutaSize.values) {
      if (s.nominalMm == mm) return s;
    }
    return null;
  }

  /// The nearest সুতা to a millimetre size, for a bar the table does not carry.
  static SutaSize nearestToMm(double mm) {
    var best = SutaSize.values.first;
    for (final s in SutaSize.values) {
      if ((s.nominalMm - mm).abs() < (best.nominalMm - mm).abs()) best = s;
    }
    return best;
  }
}
