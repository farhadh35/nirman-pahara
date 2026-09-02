import '../../../core/i18n/app_locale.dart';

/// Bangladeshi land measure.
///
/// Land here is bought, sold, inherited and taxed in কাঠা, বিঘা, শতাংশ and
/// ছটাক. A drawing is in square feet and a mutation paper may be in decimals,
/// so a homeowner checking whether the plot they paid for is the plot they got
/// has to move between them. Every unit below is defined against the square
/// foot, which is the one both sides of that conversation already trust.
///
/// The chain checks out end to end: 1 acre = 43,560 sft = 100 decimals
/// = 60.5 katha = 3.025 bigha, and 16 chatak make one katha. Those identities
/// are asserted in the tests rather than assumed.
enum LandUnit {
  squareFoot('বর্গফুট', 'square foot', 1.0),
  squareInch('বর্গইঞ্চি', 'square inch', 1.0 / 144.0),
  squareYard('বর্গগজ', 'square yard', 9.0),
  squareMetre('বর্গমিটার', 'square metre', 10.7639104167097),
  chatak('ছটাক', 'chatak', 45.0),
  decimal('শতাংশ', 'decimal', 435.6),
  katha('কাঠা', 'katha', 720.0),
  bigha('বিঘা', 'bigha', 14400.0),
  acre('একর', 'acre', 43560.0),
  hectare('হেক্টর', 'hectare', 107639.104167097);

  const LandUnit(this._bn, this._en, this.squareFeet);

  final String _bn;
  final String _en;

  /// How many square feet one of this unit is.
  final double squareFeet;

  L10nText get label => L10nText(_bn, _en);

  double toSquareFeet(double value) => value * squareFeet;

  double fromSquareFeet(double sft) => sft / squareFeet;

  /// This many of [other] in one of this unit.
  double per(LandUnit other) => squareFeet / other.squareFeet;
}

/// One measured area, convertible into every unit at once.
class LandArea {
  const LandArea._(this.squareFeet);

  factory LandArea.of(double value, LandUnit unit) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'area cannot be negative');
    }
    return LandArea._(unit.toSquareFeet(value));
  }

  final double squareFeet;

  double asUnit(LandUnit unit) => unit.fromSquareFeet(squareFeet);

  /// The area written the way a deed writes it: whole bigha, then katha, then
  /// the square feet left over.
  ///
  /// A single decimal figure — "2.7 bigha" — is not how anyone reads a
  /// mutation paper, and rounding it hides exactly the remainder people argue
  /// about.
  LandBreakdown get breakdown {
    var rest = squareFeet;
    final bigha = (rest / LandUnit.bigha.squareFeet).floor();
    rest -= bigha * LandUnit.bigha.squareFeet;
    final katha = (rest / LandUnit.katha.squareFeet).floor();
    rest -= katha * LandUnit.katha.squareFeet;
    return LandBreakdown(bigha: bigha, katha: katha, squareFeet: rest);
  }
}

class LandBreakdown {
  const LandBreakdown({
    required this.bigha,
    required this.katha,
    required this.squareFeet,
  });

  final int bigha;
  final int katha;
  final double squareFeet;
}
