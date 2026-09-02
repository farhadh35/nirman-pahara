import '../../../core/i18n/app_locale.dart';

/// An item a schedule for a given kind of work would normally carry.
///
/// Matched on the words the departmental schedules actually print, which are
/// in English even when everything around them is not.
class ExpectedItem {
  const ExpectedItem({
    required this.id,
    required this.name,
    required this.keywords,
    required this.why,
    this.critical = false,
  });

  final String id;
  final L10nText name;

  /// Any one of these appearing in an item description counts as present.
  final List<String> keywords;

  /// Why the item matters, so a missing one can be asked about sensibly.
  final L10nText why;

  /// Work that fails early or dangerously when it is left out.
  final bool critical;

  bool matches(String description) {
    final d = description.toLowerCase();
    return keywords.any((k) => d.contains(k));
  }
}

/// The items a kind of work is normally built from.
class WorkProfile {
  const WorkProfile({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final L10nText name;
  final List<ExpectedItem> items;

  /// Expected items that no line in [descriptions] appears to cover.
  List<ExpectedItem> missingFrom(Iterable<String> descriptions) => [
        for (final item in items)
          if (!descriptions.any(item.matches)) item,
      ];
}

/// Profiles for the kinds of work this app already carries checklists for.
///
/// A missing item is a question, not a verdict: the work may sit in a separate
/// package, or the structure may genuinely not need it. But a godown schedule
/// with no damp proof course, or a road with no sub-base, is worth asking
/// about before the money moves.
class ExpectedItems {
  ExpectedItems._();

  static const _excavation = ExpectedItem(
    id: 'excavation',
    name: L10nText('মাটি খনন', 'Excavation'),
    keywords: ['excavat', 'earth work', 'earthwork'],
    why: L10nText(
      'ভিত বসানোর জন্য মাটি কাটতেই হয় — তালিকায় না থাকা অস্বাভাবিক।',
      'Ground has to be opened for any foundation, so its absence is odd.',
    ),
  );

  static const _sandFilling = ExpectedItem(
    id: 'sand_filling',
    name: L10nText('বালি ভরাট', 'Sand filling'),
    keywords: ['sand filling', 'filling with sand', 'filling'],
    why: L10nText(
      'ভিতের নিচে ও মেঝের নিচে ভরাট না থাকলে পরে বসে যায়।',
      'Without fill under the base and the floor, the work settles later.',
    ),
  );

  static const _soling = ExpectedItem(
    id: 'soling',
    name: L10nText('ইটের সোলিং', 'Brick soling'),
    keywords: ['soling', 'flat soling'],
    why: L10nText(
      'ঢালাইয়ের নিচে সমান শক্ত তল তৈরি করে।',
      'It gives the concrete a firm, level bed to sit on.',
    ),
  );

  static const _dpc = ExpectedItem(
    id: 'dpc',
    name: L10nText('আর্দ্রতা রোধক স্তর (ডিপিসি)', 'Damp proof course'),
    keywords: ['damp proof', 'dpc', 'd.p.c'],
    critical: true,
    why: L10nText(
      'ডিপিসি ছাড়া মাটি থেকে আর্দ্রতা উঠে দেয়াল ও ভেতরের জিনিস নষ্ট করে। '
          'গুদামে এটা না থাকলে নিচের বস্তার শস্য পচে।',
      'Without it, damp rises out of the ground and destroys the wall and what '
          'is inside. In a store it rots the grain at the bottom of the stack.',
    ),
  );

  static const _concrete = ExpectedItem(
    id: 'concrete',
    name: L10nText('আরসিসি ঢালাই', 'RCC / concrete work'),
    keywords: ['concrete', 'rcc', 'r.c.c'],
    critical: true,
    why: L10nText(
      'কাঠামোর ভার বহনকারী অংশ।',
      'The load-carrying part of the structure.',
    ),
  );

  static const _reinforcement = ExpectedItem(
    id: 'reinforcement',
    name: L10nText('রড', 'Reinforcement'),
    keywords: ['deformed bar', 'reinforce', 'm.s. rod', 'ms rod', 'steel'],
    critical: true,
    why: L10nText(
      'ঢালাই আছে অথচ রড নেই — দুটোর একটা আলাদা প্যাকেজে না থাকলে এটা গুরুতর।',
      'Concrete without steel: unless one of them sits in another package, '
          'that is serious.',
    ),
  );

  static const _shuttering = ExpectedItem(
    id: 'shuttering',
    name: L10nText('শাটারিং', 'Shuttering'),
    keywords: ['shuttering', 'centering', 'formwork'],
    why: L10nText(
      'ঢালাই ধরে রাখার ছাঁচ — ঢালাই থাকলে এটাও থাকার কথা।',
      'The mould that holds a pour; where there is concrete there is usually '
          'shuttering.',
    ),
  );

  static const _brickwork = ExpectedItem(
    id: 'brickwork',
    name: L10nText('ইটের গাঁথুনি', 'Brick work'),
    keywords: ['brick work', 'brickwork', 'brick masonry'],
    why: L10nText(
      'দেয়াল তোলার কাজ।',
      'The walling itself.',
    ),
  );

  static const _plaster = ExpectedItem(
    id: 'plaster',
    name: L10nText('প্লাস্টার', 'Plaster'),
    keywords: ['plaster'],
    why: L10nText(
      'গাঁথুনিকে পানি ও আবহাওয়া থেকে বাঁচায়।',
      'It protects the masonry from water and weather.',
    ),
  );

  static const _paint = ExpectedItem(
    id: 'paint',
    name: L10nText('রং', 'Painting'),
    keywords: ['paint', 'weathercoat', 'distemper', 'enamel'],
    why: L10nText(
      'বাইরের পৃষ্ঠকে আবহাওয়া থেকে রক্ষা করে।',
      'It protects the outer surface from the weather.',
    ),
  );

  static const _drain = ExpectedItem(
    id: 'drain',
    name: L10nText('ড্রেন / পানি নিষ্কাশন', 'Drain'),
    keywords: ['drain', 'culvert'],
    why: L10nText(
      'পানি জমলে ভিত ও দেয়াল দুটোই নষ্ট হয়।',
      'Standing water destroys both the foundation and the wall.',
    ),
  );

  static const _subBase = ExpectedItem(
    id: 'sub_base',
    name: L10nText('সাব-বেজ', 'Sub-base'),
    keywords: ['sub base', 'sub-base', 'subbase', 'improved sub'],
    critical: true,
    why: L10nText(
      'রাস্তার ভার ছড়িয়ে দেওয়ার স্তর — না থাকলে কয়েক বর্ষাতেই বসে যায়।',
      'The layer that spreads a road\'s load; without it the road sinks within '
          'a couple of monsoons.',
    ),
  );

  static const _baseCourse = ExpectedItem(
    id: 'base_course',
    name: L10nText('বেজ কোর্স', 'Base course'),
    keywords: ['base course', 'wbm', 'macadam', 'aggregate base'],
    critical: true,
    why: L10nText(
      'পেভমেন্টের প্রধান ভার বহনকারী স্তর।',
      'The main load-carrying layer of the pavement.',
    ),
  );

  static const _surfacing = ExpectedItem(
    id: 'surfacing',
    name: L10nText('কার্পেটিং / পৃষ্ঠ', 'Surfacing'),
    keywords: ['carpet', 'bitumen', 'bituminous', 'seal coat', 'wearing'],
    why: L10nText(
      'উপরের স্তর, যা পানি ঢুকতে দেয় না।',
      'The top layer, which keeps water out of everything below it.',
    ),
  );

  static const _ventilation = ExpectedItem(
    id: 'ventilation',
    name: L10nText('ভেন্টিলেটর', 'Ventilator'),
    keywords: ['ventilat', 'louver', 'louvre'],
    critical: true,
    why: L10nText(
      'বাতাস না চললে গুদামে ভাপ জমে শস্যে ছত্রাক ধরে।',
      'Without air movement a store sweats and the grain moulds.',
    ),
  );

  static final building = WorkProfile(
    id: 'building',
    name: const L10nText('ভবন', 'Building'),
    items: const [
      _excavation, _sandFilling, _soling, _dpc, _concrete, _reinforcement,
      _shuttering, _brickwork, _plaster, _paint,
    ],
  );

  static final godown = WorkProfile(
    id: 'godown',
    name: const L10nText('খাদ্য গুদাম', 'Food godown'),
    items: const [
      _excavation, _sandFilling, _soling, _dpc, _concrete, _reinforcement,
      _shuttering, _brickwork, _plaster, _ventilation, _drain, _paint,
    ],
  );

  static final road = WorkProfile(
    id: 'road',
    name: const L10nText('সড়ক', 'Road'),
    items: const [
      _excavation, _subBase, _baseCourse, _surfacing, _drain,
    ],
  );

  static final boundaryWall = WorkProfile(
    id: 'boundary_wall',
    name: const L10nText('সীমানা প্রাচীর', 'Boundary wall'),
    items: const [
      _excavation, _sandFilling, _concrete, _reinforcement, _shuttering,
      _brickwork, _plaster, _paint,
    ],
  );

  static final all = [building, godown, road, boundaryWall];

  static WorkProfile? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
