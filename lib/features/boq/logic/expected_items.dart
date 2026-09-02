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

  // The items below were taken from a real district food office estimate for an
  // LSD office building (FY 2025-26) and the Directorate General of Food type
  // design for a 1000 MT godown, rather than assembled from memory. Only items
  // those documents actually carry are here: a profile that asks after work no
  // real schedule contains turns every honest bill into a page of questions.

  static const _earthFilling = ExpectedItem(
    id: 'earth_filling',
    name: L10nText('মাটি ভরাট', 'Earth filling'),
    keywords: ['earth filling', 'filling in foundation', 'side development'],
    why: L10nText(
      'ভিতের চারপাশ ও প্লিন্থ ভরাট না হলে মেঝে বসে যায় আর দেয়ালে ফাটল ধরে।',
      'Unless the foundation and plinth are filled back, the floor settles and '
          'the walls crack.',
    ),
  );

  static const _floorFinish = ExpectedItem(
    id: 'floor_finish',
    name: L10nText('মেঝের ফিনিশিং', 'Floor finish'),
    keywords: ['patent stone', 'floor tiles', 'mosaic', 'neat cement',
        'brick pavement'],
    why: L10nText(
      'ঢালাইয়ের উপরের পাটা — এটা বাদ পড়লে মেঝে ধুলো ছাড়ে আর ধোয়া যায় না।',
      'The wearing layer over the slab. Without it a floor dusts and cannot be '
          'washed down.',
    ),
  );

  static const _doorsWindows = ExpectedItem(
    id: 'doors_windows',
    name: L10nText('দরজা ও জানালা', 'Doors and windows'),
    keywords: ['door', 'window', 'shutter', 'grill', 'frame', 'glass'],
    why: L10nText(
      'ভবনের খরচের বড় ভাগ দরজা-জানালায় যায়, তাই তালিকায় না থাকাটা চোখে পড়ার মতো।',
      'Doors and windows carry a large share of a building cost, so their '
          'absence from a schedule stands out.',
    ),
  );

  static const _apron = ExpectedItem(
    id: 'apron',
    name: L10nText('অ্যাপ্রন', 'Apron'),
    keywords: ['apron', 'plinth protection'],
    why: L10nText(
      'দেয়ালের গোড়ায় বৃষ্টির পানি জমলে ভিত ধুয়ে যায়। অ্যাপ্রন সেটা ঠেকায়।',
      'Rain standing at the wall foot washes the foundation out. The apron is '
          'what keeps it away.',
    ),
  );

  static const _lintel = ExpectedItem(
    id: 'lintel',
    name: L10nText('লিন্টেল ও সানশেড', 'Lintel and sunshade'),
    keywords: ['lintel', 'sunshade', 'sun shade', 'sunshed', 'tie beam'],
    why: L10nText(
      'দরজা-জানালার উপরের ভার লিন্টেল ধরে। এটা ছাড়া উপরের গাঁথুনি ফাটে।',
      'A lintel carries the wall over an opening. Without one the masonry '
          'above it cracks.',
    ),
  );

  static const _loadingDock = ExpectedItem(
    id: 'loading_dock',
    name: L10nText('লোডিং ডক', 'Loading dock'),
    keywords: ['loading dock', 'dock', 'platform'],
    why: L10nText(
      'ট্রাক থেকে বস্তা নামানোর মঞ্চ। না থাকলে শস্য মাটিতে নামে আর ভেজে।',
      'Where sacks come off a truck. Without it the grain is landed on the '
          'ground and takes damp.',
    ),
  );

  // ---- sanitary ----

  static const _soilPipe = ExpectedItem(
    id: 'soil_pipe',
    name: L10nText('সয়েল ও ওয়েস্ট পাইপ', 'Soil and waste pipe'),
    keywords: ['soil pipe', 'waste pipe', 'upvc pipe', 'pvc pipe'],
    why: L10nText(
      'পয়ঃনিষ্কাশনের মূল লাইন। এটা ছাড়া বাকি স্যানিটারি কাজের মানে নেই।',
      'The line everything else drains into. The rest of the sanitary work '
          'means nothing without it.',
    ),
  );

  static const _sanitaryFittings = ExpectedItem(
    id: 'sanitary_fittings',
    name: L10nText('স্যানিটারি সামগ্রী', 'Sanitary fittings'),
    keywords: ['commode', 'long pan', 'wash basin', 'basin', 'bib cock',
        'pillar cock', 'stop cock'],
    why: L10nText(
      'প্যান, বেসিন, কল — টয়লেট চালু করতে যা লাগে।',
      'Pan, basin and taps: what it takes to make a toilet work.',
    ),
  );

  static const _septicTank = ExpectedItem(
    id: 'septic_tank',
    name: L10nText('সেপটিক ট্যাংক ও সোকওয়েল', 'Septic tank and soak well'),
    keywords: ['septic tank', 'soak well', 'soak pit', 'inspection pit'],
    critical: true,
    why: L10nText(
      'পয়ঃবর্জ্য যাবে কোথায় — এটা তালিকায় না থাকলে লাইন খোলা জায়গায় পড়ছে কি না '
          'জিজ্ঞেস করা দরকার।',
      'Where the sewage goes. If a schedule carries none, it is worth asking '
          'where the line discharges.',
    ),
  );

  static const _waterSource = ExpectedItem(
    id: 'water_source',
    name: L10nText('পানির উৎস ও ট্যাংক', 'Water source and tank'),
    keywords: ['tube well', 'tubewell', 'water tank', 'reservoir',
        'submersible', 'hand pump'],
    why: L10nText(
      'পানি কোথা থেকে আসবে আর কোথায় জমবে।',
      'Where the water comes from and where it is held.',
    ),
  );

  // ---- electrical ----

  static const _wiring = ExpectedItem(
    id: 'wiring',
    name: L10nText('ওয়্যারিং ও কনডুইট', 'Wiring and conduit'),
    keywords: ['wiring', 'conduit', 'cable'],
    why: L10nText(
      'তার ও তার ঢাকার পাইপ। কনডুইট ছাড়া দেয়ালের ভেতরে খোলা তার বিপজ্জনক।',
      'The cable and the pipe that carries it. Cable buried without conduit is '
          'a fire waiting to happen.',
    ),
  );

  static const _distributionBoard = ExpectedItem(
    id: 'distribution_board',
    name: L10nText('ডিস্ট্রিবিউশন বোর্ড ও সার্কিট ব্রেকার',
        'Distribution board and breakers'),
    keywords: ['distribution board', 'sdb', 'circuit breaker', 'mccb', 'mcb',
        'cut out', 'control switch'],
    critical: true,
    why: L10nText(
      'শর্ট সার্কিট হলে লাইন কেটে দেয়। ব্রেকার ছাড়া আগুন ঠেকানোর কিছু থাকে না।',
      'What cuts the supply when a circuit faults. Without breakers nothing '
          'stands between a short and a fire.',
    ),
  );

  static const _earthing = ExpectedItem(
    id: 'earthing',
    name: L10nText('আর্থিং', 'Earthing'),
    keywords: ['earthing', 'earth electrode', 'hdbc'],
    critical: true,
    why: L10nText(
      'আর্থিং না থাকলে ধাতব অংশে বিদ্যুৎ এলে সেটা শরীরের ভেতর দিয়েই মাটিতে যায়।',
      'Without earthing, a live metal part sends the current to ground through '
          'whoever is touching it.',
    ),
  );

  static const _fittings = ExpectedItem(
    id: 'electrical_fittings',
    name: L10nText('বাতি, ফ্যান ও সুইচ-সকেট', 'Lights, fans, switches, sockets'),
    keywords: ['light fitting', 'tube light', 'lamp', 'ceiling fan',
        'exhaust fan', 'switch', 'socket'],
    why: L10nText(
      'যা লাগানোর জন্য পুরো ওয়্যারিংটা করা হলো।',
      'What the whole installation was put in to carry.',
    ),
  );

  static final building = WorkProfile(
    id: 'building',
    name: const L10nText('ভবন', 'Building'),
    items: const [
      _excavation, _earthFilling, _sandFilling, _soling, _dpc, _concrete,
      _reinforcement, _shuttering, _brickwork, _lintel, _floorFinish,
      _doorsWindows, _plaster, _paint, _apron,
    ],
  );

  static final godown = WorkProfile(
    id: 'godown',
    name: const L10nText('খাদ্য গুদাম', 'Food godown'),
    items: const [
      _excavation, _earthFilling, _sandFilling, _soling, _dpc, _concrete,
      _reinforcement, _shuttering, _brickwork, _lintel, _floorFinish,
      _doorsWindows, _plaster, _ventilation, _loadingDock, _drain, _apron,
      _paint,
    ],
  );

  /// Water supply and sanitary work, which departments price as its own
  /// section of the same estimate.
  static final sanitary = WorkProfile(
    id: 'sanitary',
    name: const L10nText('পানি ও স্যানিটারি কাজ',
        'Water supply and sanitary works'),
    items: const [
      _soilPipe, _sanitaryFittings, _septicTank, _waterSource,
    ],
  );

  /// Electrical work. The app has carried an electrical checklist since 1.0
  /// with no profile behind it, so an electrical section of a bill went
  /// unexamined for missing items.
  static final electrical = WorkProfile(
    id: 'electrical',
    name: const L10nText('বৈদ্যুতিক কাজ', 'Electrical works'),
    items: const [
      _wiring, _distributionBoard, _earthing, _fittings,
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

  static final all = [building, godown, road, boundaryWall,
      sanitary, electrical];

  static WorkProfile? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
