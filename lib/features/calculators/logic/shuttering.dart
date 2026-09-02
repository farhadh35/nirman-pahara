import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// Formwork — the timber or ply box the concrete is poured into.
///
/// Centering is billed by the area of the face that touches concrete, which is
/// not the same as the area of the member. A beam is measured on two sides and
/// a bottom; a column on all four; a slab on its underside. Getting the wrong
/// face into the bill is a common and quiet overcharge, so the formula is
/// spelled out for each.
enum ShutterElement {
  beam('বিম', 'Beam'),
  column('কলাম', 'Column'),
  slab('স্ল্যাব', 'Slab'),
  wall('দেয়াল', 'Wall');

  const ShutterElement(this.bn, this.en);

  final String bn;
  final String en;

  L10nText get label => L10nText(bn, en);
}

class ShutteringCalculator {
  const ShutteringCalculator();

  /// [a] and [b] are the cross-section in inches for a beam or column, or the
  /// plan sizes in feet for a slab. [runFt] is the span, height or width.
  CalcResult compute({
    required ShutterElement element,
    required double a,
    required double b,
    required double runFt,
    int count = 1,
  }) {
    for (final d in [a, b, runFt]) {
      if (!d.isFinite || d <= 0) {
        throw CalcException(const L10nText(
          'প্রতিটি মাপ শূন্যের বড় একটি সংখ্যা হতে হবে।',
          'Every measurement has to be a real number greater than zero.',
        ));
      }
    }
    if (count < 1) {
      throw CalcException(const L10nText(
        'সংখ্যা অন্তত ১ হতে হবে।',
        'The count has to be at least 1.',
      ));
    }

    final double perOne;
    final L10nText formula;
    switch (element) {
      case ShutterElement.beam:
        // Two sides plus the soffit. The top is open: the slab closes it.
        final widthFt = a / 12.0;
        final depthFt = b / 12.0;
        perOne = (2 * depthFt + widthFt) * runFt;
        formula = L10nText(
          'বিম = (২ × গভীরতা + চওড়া) × দৈর্ঘ্য = (২ × ${_fmt(depthFt)} + '
              '${_fmt(widthFt)}) × ${_fmt(runFt)} = ${_fmt(perOne)} বর্গফুট। '
              'উপরের মুখ খোলা — ওখানে স্ল্যাব বসে।',
          'Beam = (2 × depth + width) × span = (2 × ${_fmt(depthFt)} + '
              '${_fmt(widthFt)}) × ${_fmt(runFt)} = ${_fmt(perOne)} sft. The '
              'top is open: the slab closes it.',
        );
      case ShutterElement.column:
        final xFt = a / 12.0;
        final yFt = b / 12.0;
        perOne = 2 * (xFt + yFt) * runFt;
        formula = L10nText(
          'কলাম = ২ × (দুই বাহুর যোগ) × উচ্চতা = ২ × (${_fmt(xFt)} + '
              '${_fmt(yFt)}) × ${_fmt(runFt)} = ${_fmt(perOne)} বর্গফুট।',
          'Column = 2 × (sum of the two sides) × height = 2 × (${_fmt(xFt)} + '
              '${_fmt(yFt)}) × ${_fmt(runFt)} = ${_fmt(perOne)} sft.',
        );
      case ShutterElement.slab:
        // The soffit, plus the thin edge all the way round.
        final thickFt = runFt / 12.0;
        perOne = a * b + 2 * (a + b) * thickFt;
        formula = L10nText(
          'স্ল্যাব = নিচের মুখ + চারপাশের কিনারা = (${_fmt(a)} × ${_fmt(b)}) + '
              '২ × (${_fmt(a)} + ${_fmt(b)}) × ${_fmt(thickFt)} = '
              '${_fmt(perOne)} বর্গফুট।',
          'Slab = soffit + the edge all round = (${_fmt(a)} × ${_fmt(b)}) + '
              '2 × (${_fmt(a)} + ${_fmt(b)}) × ${_fmt(thickFt)} = '
              '${_fmt(perOne)} sft.',
        );
      case ShutterElement.wall:
        perOne = 2 * a * runFt;
        formula = L10nText(
          'দেয়াল = ২ × দৈর্ঘ্য × উচ্চতা = ২ × ${_fmt(a)} × ${_fmt(runFt)} = '
              '${_fmt(perOne)} বর্গফুট। দুই পাশেই শাটার লাগে।',
          'Wall = 2 × length × height = 2 × ${_fmt(a)} × ${_fmt(runFt)} = '
              '${_fmt(perOne)} sft. Both faces need formwork.',
        );
    }

    final total = perOne * count;
    return CalcResult(
      lines: [
        CalcLine(
          key: 'area_sft',
          label: const L10nText('শাটারিংয়ের ক্ষেত্রফল', 'Formwork area'),
          value: total,
          unit: U.sft,
          emphasis: true,
        ),
        if (count > 1)
          CalcLine(
            key: 'per_one_sft',
            label: L10nText('প্রতি ${element.bn}-এ', 'Per ${element.en.toLowerCase()}'),
            value: perOne,
            unit: U.sft,
          ),
      ],
      formula: count > 1
          ? L10nText('${formula.bn} × $count টি = ${_fmt(total)} বর্গফুট।',
              '${formula.en} × $count = ${_fmt(total)} sft.')
          : formula,
      assumptions: [
        const L10nText(
          'শুধু যে মুখ কংক্রিট ছোঁয় সেটুকুই ধরা হয়েছে — বিল এভাবেই হয়।',
          'Only the faces the concrete touches are counted, which is how the '
              'bill is written.',
        ),
        if (element == ShutterElement.beam)
          const L10nText(
            'বিমের উপরের মুখ ধরা হয়নি; স্ল্যাব ঢালাইয়ের সঙ্গে ওটা বন্ধ হয়।',
            'The top of the beam is not counted: the slab pour closes it.',
          ),
        if (element == ShutterElement.slab)
          const L10nText(
            'স্ল্যাবের মাপ ফুটে, পুরুত্ব ইঞ্চিতে ধরা হয়েছে।',
            'Slab sizes are in feet and the thickness in inches.',
          ),
        if (element == ShutterElement.beam || element == ShutterElement.column)
          const L10nText(
            'প্রস্থচ্ছেদ ইঞ্চিতে, দৈর্ঘ্য বা উচ্চতা ফুটে ধরা হয়েছে।',
            'The cross-section is in inches and the span or height in feet.',
          ),
        const L10nText(
          'ওভারল্যাপ, প্রপ আর সাপোর্ট আলাদা — এই হিসাবে নেই।',
          'Overlaps, props and supports are separate and are not in this '
              'figure.',
        ),
      ],
      note: const L10nText(
        'শাটার খোলার সময়টাই আসল ঝুঁকি — তাড়াতাড়ি খুললে বিম ঝুলে যায়। সময়ের '
            'তালিকা দেখে নিন।',
        'When the formwork comes off is the real risk: strike it early and the '
            'beam sags. Check the striking table.',
      ),
    );
  }

  static String _fmt(double v) => v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(2);
}
