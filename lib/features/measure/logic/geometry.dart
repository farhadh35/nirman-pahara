import 'dart:math' as math;

import '../../../core/i18n/app_locale.dart';
import '../../calculators/logic/calc_result.dart';

/// Areas and volumes for shapes a plot or a member actually comes in.
///
/// Nothing here is specific to construction — that is the point. A person
/// working out how much earth a sloped pit holds, or the area of a plot that is
/// not a rectangle, is stuck long before any construction knowledge matters.
/// Each shape returns the formula alongside the number, so the arithmetic can
/// be repeated on paper.
enum Shape {
  rectangle('আয়তক্ষেত্র', 'Rectangle', ['দৈর্ঘ্য', 'প্রস্থ'], ['Length', 'Width']),
  triangle('ত্রিভুজ', 'Triangle', ['ভূমি', 'উচ্চতা'], ['Base', 'Height']),
  trapezium('ট্রাপিজিয়াম', 'Trapezium',
      ['সমান্তরাল বাহু ১', 'সমান্তরাল বাহু ২', 'দূরত্ব'],
      ['Parallel side 1', 'Parallel side 2', 'Distance between them']),
  circle('বৃত্ত', 'Circle', ['ব্যাস'], ['Diameter']),
  cylinder('সিলিন্ডার', 'Cylinder', ['ব্যাস', 'উচ্চতা'], ['Diameter', 'Height']),
  cone('কোণক', 'Cone', ['ব্যাস', 'উচ্চতা'], ['Diameter', 'Height']),
  sphere('গোলক', 'Sphere', ['ব্যাস'], ['Diameter']),
  box('আয়তাকার ঘনবস্তু', 'Rectangular solid', ['দৈর্ঘ্য', 'প্রস্থ', 'উচ্চতা'],
      ['Length', 'Width', 'Height']);

  const Shape(this._bn, this._en, this._inputsBn, this._inputsEn);

  final String _bn;
  final String _en;
  final List<String> _inputsBn;
  final List<String> _inputsEn;

  L10nText get label => L10nText(_bn, _en);

  List<L10nText> get inputs => [
        for (var i = 0; i < _inputsBn.length; i++)
          L10nText(_inputsBn[i], _inputsEn[i]),
      ];

  bool get isSolid => this == Shape.cylinder ||
      this == Shape.cone ||
      this == Shape.sphere ||
      this == Shape.box;
}

class Geometry {
  const Geometry();

  /// [dimensions] are in one consistent unit; the answer comes back in that
  /// unit squared for a flat shape and cubed for a solid.
  CalcResult compute(Shape shape, List<double> dimensions) {
    final need = shape.inputs.length;
    if (dimensions.length != need) {
      throw CalcException(L10nText(
        '${shape.label.bn}-এর জন্য $need টি মাপ দিতে হবে।',
        '${shape.label.en} needs $need measurements.',
      ));
    }
    for (final d in dimensions) {
      if (d <= 0) {
        throw CalcException(const L10nText(
          'প্রতিটি মাপ শূন্যের বড় হতে হবে।',
          'Every measurement has to be greater than zero.',
        ));
      }
    }

    final (value, formulaBn, formulaEn) = switch (shape) {
      Shape.rectangle => (
          dimensions[0] * dimensions[1],
          'দৈর্ঘ্য × প্রস্থ',
          'length × width',
        ),
      Shape.triangle => (
          0.5 * dimensions[0] * dimensions[1],
          '½ × ভূমি × উচ্চতা',
          '½ × base × height',
        ),
      Shape.trapezium => (
          0.5 * (dimensions[0] + dimensions[1]) * dimensions[2],
          '½ × (সমান্তরাল বাহু দুটির যোগফল) × দূরত্ব',
          '½ × (sum of the parallel sides) × distance',
        ),
      Shape.circle => (
          math.pi * math.pow(dimensions[0] / 2, 2).toDouble(),
          'π × (ব্যাস ÷ ২)²',
          'π × (diameter ÷ 2)²',
        ),
      Shape.cylinder => (
          math.pi * math.pow(dimensions[0] / 2, 2).toDouble() * dimensions[1],
          'π × (ব্যাস ÷ ২)² × উচ্চতা',
          'π × (diameter ÷ 2)² × height',
        ),
      Shape.cone => (
          math.pi * math.pow(dimensions[0] / 2, 2).toDouble() * dimensions[1] / 3,
          '⅓ × π × (ব্যাস ÷ ২)² × উচ্চতা',
          '⅓ × π × (diameter ÷ 2)² × height',
        ),
      Shape.sphere => (
          4 / 3 * math.pi * math.pow(dimensions[0] / 2, 3).toDouble(),
          '⁴⁄₃ × π × (ব্যাস ÷ ২)³',
          '⁴⁄₃ × π × (diameter ÷ 2)³',
        ),
      Shape.box => (
          dimensions[0] * dimensions[1] * dimensions[2],
          'দৈর্ঘ্য × প্রস্থ × উচ্চতা',
          'length × width × height',
        ),
    };

    return CalcResult(
      lines: [
        CalcLine(
          key: shape.isSolid ? 'volume' : 'area',
          label: shape.isSolid
              ? const L10nText('আয়তন', 'Volume')
              : const L10nText('ক্ষেত্রফল', 'Area'),
          value: value,
          unit: shape.isSolid
              ? const L10nText('একক³', 'unit³')
              : const L10nText('একক²', 'unit²'),
          emphasis: true,
        ),
      ],
      formula: L10nText(formulaBn, formulaEn),
      assumptions: [
        const L10nText(
          'যে এককে মাপ দিয়েছেন, উত্তরও সেই এককেই — ফুটে দিলে বর্গফুট বা ঘনফুট।',
          'The answer comes back in the unit you measured in: feet in, square '
              'or cubic feet out.',
        ),
        if (shape == Shape.circle ||
            shape == Shape.cylinder ||
            shape == Shape.cone ||
            shape == Shape.sphere)
          const L10nText(
            'ব্যাস চাওয়া হয়েছে, ব্যাসার্ধ নয়। গোল জিনিস মাপার সময় সবচেয়ে চওড়া '
                'জায়গাটা মাপুন।',
            'The diameter is asked for, not the radius: measure across the '
                'widest part.',
          ),
      ],
    );
  }
}
