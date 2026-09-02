import '../../../core/i18n/app_locale.dart';
import 'calc_result.dart';

/// Tiles for a floor or a wall, including the ones that break.
///
/// Tile is bought by the box and laid by the piece, and the gap between the two
/// is where a job runs short on the last afternoon. Cut tiles at the edges of a
/// room are rarely reusable, so the allowance is not really wastage — it is the
/// part of every tile left on the wrong side of the cut.
class TileCalculator {
  const TileCalculator();

  CalcResult compute({
    required double areaSft,
    required double tileLengthIn,
    required double tileWidthIn,
    double wastagePercent = 10.0,
    int? tilesPerBox,
  }) {
    if (!areaSft.isFinite || areaSft <= 0) {
      throw CalcException(const L10nText(
        'ক্ষেত্রফল শূন্যের বড় একটি সংখ্যা হতে হবে।',
        'The area has to be a real number greater than zero.',
      ));
    }
    for (final d in [tileLengthIn, tileWidthIn]) {
      if (!d.isFinite || d <= 0) {
        throw CalcException(const L10nText(
          'টাইলসের মাপ শূন্যের বড় একটি সংখ্যা হতে হবে।',
          'The tile size has to be a real number greater than zero.',
        ));
      }
    }
    if (!wastagePercent.isFinite || wastagePercent < 0) {
      throw CalcException(const L10nText(
        'অপচয় ঋণাত্মক হতে পারে না।',
        'Wastage cannot be negative.',
      ));
    }
    if (tilesPerBox != null && tilesPerBox < 1) {
      throw CalcException(const L10nText(
        'প্রতি বাক্সে টাইলসের সংখ্যা অন্তত ১ হতে হবে।',
        'A box has to hold at least one tile.',
      ));
    }

    final tileSft = tileLengthIn * tileWidthIn / 144.0;
    final net = areaSft / tileSft;
    final gross = net * (1 + wastagePercent / 100.0);

    final lines = <CalcLine>[
      CalcLine(
        key: 'tiles',
        label: const L10nText('টাইলস লাগবে', 'Tiles needed'),
        value: gross.ceilToDouble(),
        unit: const L10nText('টি', 'nos'),
        decimals: 0,
        emphasis: true,
      ),
      CalcLine(
        key: 'tiles_net',
        label: const L10nText('অপচয় বাদে', 'Before the cutting allowance'),
        value: net,
        unit: const L10nText('টি', 'nos'),
        decimals: 0,
      ),
      CalcLine(
        key: 'tile_sft',
        label: const L10nText('এক টাইলসের ক্ষেত্রফল', 'Area of one tile'),
        value: tileSft,
        unit: U.sft,
        decimals: 3,
      ),
    ];
    if (tilesPerBox != null) {
      lines.add(CalcLine(
        key: 'boxes',
        label: const L10nText('কত বাক্স', 'Boxes'),
        value: (gross / tilesPerBox).ceilToDouble(),
        unit: const L10nText('বাক্স', 'boxes'),
        decimals: 0,
        emphasis: true,
      ));
    }

    return CalcResult(
      lines: lines,
      formula: L10nText(
        'টাইলস = ক্ষেত্রফল ÷ এক টাইলসের ক্ষেত্রফল = ${_fmt(areaSft)} ÷ '
            '${tileSft.toStringAsFixed(3)} = ${net.toStringAsFixed(0)} টি, তার '
            'সঙ্গে ${_fmt(wastagePercent)}% কাটার হিসাব।',
        'Tiles = area ÷ area of one tile = ${_fmt(areaSft)} ÷ '
            '${tileSft.toStringAsFixed(3)} = ${net.toStringAsFixed(0)}, plus '
            '${_fmt(wastagePercent)}% for cutting.',
      ),
      assumptions: [
        L10nText(
          'টাইলসের মাপ ${_fmt(tileLengthIn)}″ × ${_fmt(tileWidthIn)}″ ধরা '
              'হয়েছে, ফাঁক বাদে।',
          'Tile taken as ${_fmt(tileLengthIn)}″ × ${_fmt(tileWidthIn)}″, '
              'ignoring the joint.',
        ),
        L10nText(
          'কাটার জন্য ${_fmt(wastagePercent)}% ধরা হয়েছে — এটি আপনার বেছে নেওয়া '
              'হার, কোনো মান নয়।',
          'A ${_fmt(wastagePercent)}% allowance for cutting: your figure, not a '
              'standard.',
        ),
        const L10nText(
          'ঘর যত ছোট আর কোনা যত বেশি, কাটা তত বেশি পড়ে। তির্যকভাবে বসালে আরও '
              'বেশি।',
          'The smaller the room and the more corners it has, the more gets '
              'cut. Laying on the diagonal wastes more still.',
        ),
      ],
      note: const L10nText(
        'একই লটের বাড়তি কয়েকটা রেখে দিন। পরে ভাঙলে হুবহু রঙের টাইলস আর মেলে না।',
        'Keep a few spares from the same lot. A tile that breaks later will '
            'not be matched exactly.',
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
