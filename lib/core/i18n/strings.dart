import 'app_locale.dart';

/// Every fixed string in the interface.
///
/// Content strings live in the JSON packs; these are the chrome. Kept as one
/// class of `L10nText` constants rather than generated ARB files because the
/// set is small, it stays greppable, and a missing translation is a compile
/// error rather than a silent key.
class S {
  S._();

  // Shell ------------------------------------------------------------------
  static const appName = L10nText('নির্মাণ পাহারা', 'Nirman Pahara');
  static const tagline = L10nText(
    'সরকারি হোক বা নিজের বাড়ি — কাজটা ঠিক হচ্ছে কি না, নিজেই দেখুন',
    'Public work or your own house — see for yourself whether it is being done right',
  );

  // Home -------------------------------------------------------------------
  static const learn = L10nText('শিখুন', 'Learn');
  static const learnSub = L10nText(
    'মালামাল, ঢালাই, রড ও অধিকার — সহজ ভাষায়',
    'Materials, concrete, steel and your rights, in plain language',
  );
  static const calculate = L10nText('হিসাব', 'Calculate');
  static const calculateSub = L10nText(
    'কত মালামাল লাগবে, কত খরচ হওয়ার কথা',
    'How much material a job needs, and what it should cost',
  );
  static const inspect = L10nText('পরিদর্শন', 'Inspect');
  static const inspectSub = L10nText(
    'ধাপে ধাপে দেখে রিপোর্ট তৈরি করুন',
    'Walk a site stage by stage and produce a report',
  );
  static const prices = L10nText('দাম যাচাই', 'Check prices');
  static const pricesSub = L10nText(
    'বাজারদর ও অন্য দেশের সঙ্গে তুলনা',
    'Market rates, and how the cost compares abroad',
  );
  static const scheduleCheck =
      L10nText('শিডিউল যাচাই', 'Check a rate schedule');
  static const scheduleCheckSub = L10nText(
    'দপ্তরের রেট শিডিউল দিন — কোথায় প্রশ্ন করার মতো, দেখে নিন',
    'Import the department\'s rate schedule and see what to ask about',
  );

  static const rights = L10nText('অধিকার', 'Your rights');
  static const rightsSub = L10nText(
    'কী চাইতে পারেন, কোথায় অভিযোগ করবেন',
    'What you may ask for, and where to complain',
  );

  // Common -----------------------------------------------------------------
  static const back = L10nText('ফিরে যান', 'Back');
  static const next = L10nText('পরবর্তী', 'Next');
  static const done = L10nText('শেষ', 'Done');
  static const cancel = L10nText('বাতিল', 'Cancel');
  static const close = L10nText('বন্ধ করুন', 'Close');
  static const copy = L10nText('কপি করুন', 'Copy');
  static const copied = L10nText('কপি হয়েছে', 'Copied');
  static const settings = L10nText('সেটিংস', 'Settings');
  static const source = L10nText('সূত্র', 'Source');
  static const sources = L10nText('সূত্র', 'Sources');
  static const watchFor = L10nText('কী দেখবেন', 'What to look at');
  static const updatedOn = L10nText('হালনাগাদ', 'Updated');
  static const loading = L10nText('অপেক্ষা করুন…', 'Loading…');
  static const somethingWrong =
      L10nText('কিছু একটা সমস্যা হয়েছে।', 'Something went wrong.');
  static const retry = L10nText('আবার চেষ্টা করুন', 'Try again');

  // Review badge -----------------------------------------------------------
  static const reviewPending =
      L10nText('ইঞ্জিনিয়ার যাচাই বাকি', 'Engineer review pending');
  static const reviewPendingWhy = L10nText(
    'এই তথ্যের সংখ্যাগুলো সূত্র ধরে লেখা, কিন্তু একজন সনদপ্রাপ্ত পুরকৌশলী এখনো '
        'যাচাই করেননি। সিদ্ধান্ত নেওয়ার আগে মূল নথি দেখে নিন।',
    'These figures were written from the cited source, but a licensed civil '
        'engineer has not signed them off yet. Check the original document '
        'before acting on them.',
  );

  // Calculators ------------------------------------------------------------
  static const calcRebar = L10nText('রডের ওজন', 'Rod weight');
  static const calcConcrete = L10nText('ঢালাইয়ের মালামাল', 'Concrete materials');
  static const calcBrickwork = L10nText('ইটের গাঁথুনি', 'Brickwork');
  static const calcPlaster = L10nText('প্লাস্টার', 'Plaster');
  static const calcRoad = L10nText('সড়কের স্তর', 'Road layers');
  static const calcUnitCost =
      L10nText('চুক্তি বনাম বাস্তব', 'Contract versus reality');
  static const result = L10nText('ফলাফল', 'Result');
  static const howCalculated =
      L10nText('কীভাবে হিসাব হলো', 'How this was worked out');
  static const assumptions = L10nText('যা ধরে নেওয়া হয়েছে', 'What was assumed');
  static const fillTheFields =
      L10nText('উপরের ঘরগুলো পূরণ করুন', 'Fill in the fields above');

  /// For something typed that is not a number at all.
  ///
  /// The keypad accepts a dot and a comma, so "১.২.৩" is a thing a thumb
  /// produces. It used to be read as zero and answered with whatever the
  /// calculator says about zero — "the area must be greater than zero" — which
  /// sends the reader looking at the wrong thing entirely.
  static const notANumber = L10nText(
    'এটা সংখ্যা হিসেবে পড়া যাচ্ছে না — দশমিক একটাই হবে।',
    'That cannot be read as a number — there can be only one decimal point.',
  );

  // Prices -----------------------------------------------------------------
  static const marketPrice = L10nText('বাজারদর', 'Market rate');
  static const yourQuote = L10nText('আপনাকে বলা দর', 'The price you were quoted');
  static const compare = L10nText('তুলনা করুন', 'Compare');
  static const countryCompare =
      L10nText('অন্য দেশের সঙ্গে', 'Against other countries');
  static const exchangeRate = L10nText('ডলারের হার', 'Exchange rate');
  static const readThisFirst = L10nText('আগে এটা পড়ুন', 'Read this first');
  static const asOf = L10nText('তারিখ', 'As of');
  static const pricesMove = L10nText(
    'দাম প্রতি সপ্তাহে বদলায়। নিচের দর কোন তারিখের, সেটা দেখে নিন — আর আপনার '
        'এলাকার আজকের দর জানা থাকলে সেটাই লিখুন।',
    'Prices move week to week. Check the date on each band below — and if you '
        'know today\'s local rate, type that in instead.',
  );

  // Rights -----------------------------------------------------------------
  static const complaintLadder =
      L10nText('অভিযোগের ধাপ', 'The complaint ladder');
  static const letters = L10nText('আবেদন ও অভিযোগের নমুনা', 'Letter templates');
  static const whoTo = L10nText('কার কাছে', 'Who to');
  static const howTo = L10nText('কীভাবে', 'How');
  static const whatToExpect = L10nText('কী হওয়ার কথা', 'What to expect');
  static const caution = L10nText('সাবধানতা', 'Caution');
  static const preview = L10nText('চিঠির খসড়া', 'Draft letter');

  // Settings ---------------------------------------------------------------
  static const language = L10nText('ভাষা', 'Language');
  static const textSize = L10nText('লেখার আকার', 'Text size');
  static const track =
      L10nText('আপনি কী দেখছেন?', 'What are you looking at?');
  static const about = L10nText('এই অ্যাপ সম্পর্কে', 'About this app');
  static const whoRunsThis = L10nText(
    'কে এই অ্যাপ চালায়, টাকা কোথা থেকে আসে',
    'Who runs this app, and where the money comes from',
  );
  /// What the app is funded by.
  ///
  /// This said "this app runs on advertising" while no advertising SDK had ever
  /// been in the build. Telling a reader their app is ad-funded when it is not
  /// is a small lie about a thing they have every reason to care about, and it
  /// was in the one section headed "where the money comes from".
  static const adDisclosure = L10nText(
    'এই অ্যাপে এখন কোনো বিজ্ঞাপন নেই। কখনো যদি আসে, সিমেন্ট, রড, ইট, টাইলস, '
        'রং, ঠিকাদারি বা আবাসন কোম্পানির বিজ্ঞাপন নেওয়া হবে না — কারণ এই অ্যাপ '
        'ঠিক ওইগুলোর মান নিয়েই কথা বলে। পরিদর্শন, ফলাফল ও অভিযোগের পর্দায় '
        'কোনো বিজ্ঞাপন কখনোই থাকবে না।',
    'There are no ads in this app today. If any ever come, none will be taken '
        'from cement, steel, brick, tile, paint, contracting or real-estate '
        'companies, because those are exactly what the app judges. No ad will '
        'ever appear on an inspection, a verdict or a complaint screen.',
  );

  /// Said plainly, because the app is about government works and a reader could
  /// reasonably assume otherwise.
  static const notGovernment = L10nText(
    'এটি কোনো সরকারি অ্যাপ নয়। কোনো দপ্তর, ঠিকাদার বা কোম্পানির সঙ্গে এর '
        'সম্পর্ক নেই, আর এটি কোনো সরকারি সিদ্ধান্তও নয়। অ্যাপটি দেখায় নিয়মে কী '
        'থাকার কথা আর আপনি কী দেখলেন — যাচাই করবে কর্তৃপক্ষ।',
    'This is not a government app. It is not connected to any department, '
        'contractor or company, and nothing in it is an official decision. It '
        'shows what the rule requires beside what you saw; the authority is who '
        'checks.',
  );
  static const privacyLine = L10nText(
    'আপনার ছবি, অবস্থান ও পরিদর্শনের তথ্য আপনার ফোনেই থাকে। কোথাও পাঠানো হয় না।',
    'Your photos, location and inspection records stay on your phone. Nothing '
        'is uploaded.',
  );
  static const noPaywall = L10nText('কোনো পেওয়াল নেই', 'No paywall');
}
