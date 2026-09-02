import '../../../core/i18n/app_locale.dart';

/// Unit conversions.
///
/// Bangladeshi sites work in feet, inches, cft and sft. Drawings and codes are
/// metric. Everything below converts to a single internal base and back, so the
/// calculators never carry a hidden unit assumption.
class Units {
  Units._();

  static const double inchPerFoot = 12.0;
  static const double mmPerInch = 25.4;
  static const double mPerFoot = 0.3048;

  /// 1 cubic foot in cubic metres.
  static const double m3PerCft = 0.028316846592;

  /// A 50 kg cement bag is taken as 1.25 cft (0.0354 m³) of loose cement.
  /// This is the figure used in Bangladeshi site practice and in PWD rate
  /// analysis; cement density varies, so it is an accepted convention, not a
  /// measured constant.
  static const double cftPerCementBag = 1.25;
  static const double kgPerCementBag = 50.0;

  static double footToInch(double ft) => ft * inchPerFoot;
  static double inchToFoot(double inch) => inch / inchPerFoot;
  static double inchToMm(double inch) => inch * mmPerInch;
  static double mmToInch(double mm) => mm / mmPerInch;
  static double cftToM3(double cft) => cft * m3PerCft;
  static double m3ToCft(double m3) => m3 / m3PerCft;
  static double footToM(double ft) => ft * mPerFoot;
  static double mToFoot(double m) => m / mPerFoot;
}

/// Length unit accepted by the calculator inputs.
enum LengthUnit {
  foot('ফুট', 'ft'),
  inch('ইঞ্চি', 'inch'),
  metre('মিটার', 'm'),
  mm('মিলিমিটার', 'mm');

  const LengthUnit(this._bn, this._en);

  final String _bn;
  final String _en;

  L10nText get label => L10nText(_bn, _en);

  double toFeet(double v) => switch (this) {
        LengthUnit.foot => v,
        LengthUnit.inch => Units.inchToFoot(v),
        LengthUnit.metre => Units.mToFoot(v),
        LengthUnit.mm => Units.mToFoot(v / 1000.0),
      };

  double toMetres(double v) => Units.footToM(toFeet(v));
}

/// Volume unit accepted by the calculator inputs.
enum VolumeUnit {
  cft('ঘনফুট', 'cft'),
  m3('ঘনমিটার', 'm³');

  const VolumeUnit(this._bn, this._en);

  final String _bn;
  final String _en;

  L10nText get label => L10nText(_bn, _en);

  double toCft(double v) => switch (this) {
        VolumeUnit.cft => v,
        VolumeUnit.m3 => Units.m3ToCft(v),
      };
}

/// Area unit accepted by the calculator inputs.
enum AreaUnit {
  sft('বর্গফুট', 'sft'),
  m2('বর্গমিটার', 'm²');

  const AreaUnit(this._bn, this._en);

  final String _bn;
  final String _en;

  L10nText get label => L10nText(_bn, _en);

  double toSft(double v) => switch (this) {
        AreaUnit.sft => v,
        AreaUnit.m2 => v / (Units.mPerFoot * Units.mPerFoot),
      };
}
