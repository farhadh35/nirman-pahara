import '../../../core/i18n/app_locale.dart';

/// A work the app cites, as opposed to a citation string.
///
/// The content packs record where a claim came from at the precision the claim
/// needs: "BNBC 2020, পার্ট ৬ — ল্যাপ ও ডেভেলপমেন্ট লেংথ", "PWD SoR 2022,
/// chapter 15", "বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯), একাদশ অধ্যায়, (১১-৪)".
/// That is right on the claim and wrong on a reference list, where it turns one
/// building code into five entries and one book into twenty — the same work
/// listed over and over, which is no longer a reference list.
///
/// So the list is built from works, matched by prefix. A citation that matches
/// nothing keeps its own text, because inventing a grouping for something
/// unrecognised is worse than showing it as it was written.
class ReferenceWork {
  const ReferenceWork({
    required this.id,
    required this.title,
    required this.kind,
    this.detail,
    this.url,
    this.isGovernment = false,
  });

  final String id;
  final L10nText title;
  final WorkKind kind;

  /// Edition, publisher or where to get it — the line under the title.
  final L10nText? detail;

  /// Where the original is published — only when that address actually opens
  /// for a reader anywhere in the world.
  ///
  /// This started as "government works must carry one", and every URL was
  /// checked with curl from a machine in Dhaka before it was written down.
  /// Play rejected the app anyway, for "Broken or Inaccessible Source Link":
  /// six of the ten publishers serve an incomplete TLS certificate chain, so
  /// hbri.gov.bd, rajuk.gov.bd, dgfood.gov.bd, bsti.gov.bd, lged.gov.bd and
  /// acc.org.bd fail with "unable to verify the first certificate" for every
  /// client that has not already cached the missing intermediate. The Dhaka
  /// machine had cached it. Nobody else has.
  ///
  /// We cannot fix somebody else's certificate, and a link that shows a
  /// security warning is not a citation — it is a claim the reader cannot
  /// check. So those six carry no URL, and [kKnownUnreachableHosts] keeps them
  /// from being written back in. What remains was verified from outside
  /// Bangladesh, not from here.
  final String? url;

  /// Publishers whose own servers make their address unusable as a citation.
  ///
  /// Checked from outside Bangladesh on 9 September 2026; each fails TLS chain
  /// verification. Kept as data rather than a comment so a test can fail when
  /// one reappears — which is how the third rejection happened.
  static const kKnownUnreachableHosts = <String>[
    'hbri.gov.bd',
    'rajuk.gov.bd',
    'dgfood.gov.bd',
    'bsti.gov.bd',
    'lged.gov.bd',
    'acc.org.bd',
    'mohpw.gov.bd',
  ];

  /// Whether this work is published by a government body.
  ///
  /// Drives the "we are not the government" line on the sources page: the app
  /// reproduces these figures, it does not speak for the offices that issued
  /// them.
  final bool isGovernment;

  /// Whether [source] is a citation of this work.
  bool claims(String source) {
    final s = source.trim();
    return _patterns[id]?.any(s.startsWith) ?? false;
  }

  static const _patterns = <String, List<String>>{
    'bnbc': ['BNBC 2020', 'Bangladesh National Building Code 2020'],
    'pwd_sor': ['PWD SoR 2022', 'PWD Schedule of Rates 2022'],
    'book': [
      'বাড়ি নির্মাণ ও সাইট সুপারভিশন',
      'অনুমানের শর্টকাট — বাড়ি নির্মাণ',
      // The same book, cited in English while the extraction was in progress.
      'book, section',
      'book, appendix',
    ],
    'gazette_2025': ['ঢাকা মহানগর ইমারত বিধিমালা'],
    'dg_food': ['খাদ্য অধিদপ্তরের'],
    'bds_steel': ['BDS ISO 6935-2'],
    'lged_roads': ['LGED রোড ডিজাইন'],
    'rti': ['তথ্য অধিকার আইন'],
    'ppa': ['পাবলিক প্রকিউরমেন্ট'],
    'up_act': ['স্থানীয় সরকার (ইউনিয়ন পরিষদ) আইন'],
    'labour_act': ['বাংলাদেশ শ্রম আইন'],
    'bppa': ['BPPA/DIMAPPP', 'DIMAPPP', 'জাতীয় ই-জিপি পোর্টাল',
      'সরকারি ক্রয় বাতায়ন'],
    'grs': ['অভিযোগ প্রতিকার ব্যবস্থা', 'জাতীয় কল সেন্টার'],
    'nlaso': ['জাতীয় আইনগত সহায়তা'],
    'acc': ['দুদক হটলাইন'],
    'wb': ['বিশ্বব্যাংক'],
    'tib': ['টিআইবির'],
    'press': ['সংবাদমাধ্যমে প্রকাশিত', 'এলজিইডির তিন প্রকল্পে',
      'সড়কের ৫১% কাজ'],
    'market': ['সরবরাহকারীদের প্রকাশিত দর', 'সিমেন্ট উৎপাদকদের',
      'নির্মাণ পরামর্শক প্রতিষ্ঠানের'],
    'practice': ['গুদাম নির্মাণের প্রচলিত মান', 'নির্মাণ চুক্তির প্রচলিত চর্চা',
      'মাঠপর্যায়ের প্রচলিত চর্চা', 'সাধারণ প্রকৌশল অঙ্কনের রীতি'],
    'arithmetic': ['একক ও রূপান্তরের সংজ্ঞা', 'একক রূপান্তর',
      'অনুপাত থেকে গণনা'],
  };

  /// The number this work is listed under on the reference page.
  ///
  /// A claim carries the number, not the source line. The same three works
  /// were being reprinted down every screen; a number costs four characters
  /// and sends the reader to one list that states each work once.
  ///
  /// The order is the page's own — grouped by kind, alphabetical by Bangla
  /// title within a kind — so the numbers run 1 upward straight down it.
  static final List<ReferenceWork> numbered = [...all]..sort((a, b) {
      final byKind = WorkKind.values
          .indexOf(a.kind)
          .compareTo(WorkKind.values.indexOf(b.kind));
      return byKind != 0 ? byKind : a.title.bn.compareTo(b.title.bn);
    });

  static final Map<String, int> _numbers = {
    for (var i = 0; i < numbered.length; i++) numbered[i].id: i + 1,
  };

  /// 1-based. Every work in [all] has one.
  int get number => _numbers[id]!;

  /// The number to print beside a claim citing [source], or null when the text
  /// matches no known work — in which case nothing is printed rather than a
  /// number that leads nowhere.
  static int? numberFor(String source) => match(source)?.number;

  static const all = <ReferenceWork>[
    ReferenceWork(
      id: 'bnbc',
      kind: WorkKind.code,
      title: L10nText('বাংলাদেশ ন্যাশনাল বিল্ডিং কোড (BNBC) ২০২০',
          'Bangladesh National Building Code (BNBC) 2020'),
      detail: L10nText('পার্ট ৫ — নির্মাণসামগ্রী · পার্ট ৬ — কাঠামোগত নকশা · '
          'পার্ট ৭ — নির্মাণ পদ্ধতি ও নিরাপত্তা · পার্ট ৮ — বিল্ডিং সার্ভিসেস',
          'Part 5 materials · Part 6 structural design · Part 7 construction '
              'and safety · Part 8 building services'),
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'pwd_sor',
      kind: WorkKind.schedule,
      title: L10nText('PWD Schedule of Rates 2022 (২য় সংশোধিত)',
          'PWD Schedule of Rates 2022 (2nd revised)'),
      detail: L10nText('গণপূর্ত অধিদপ্তর · পূর্ত ও তড়িৎ-যান্ত্রিক, দুই খণ্ড',
          'Public Works Department · civil and electro-mechanical volumes'),
      url: 'https://ss.pwd.gov.bd/sor',
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'gazette_2025',
      kind: WorkKind.law,
      title: L10nText('ঢাকা মহানগর ইমারত বিধিমালা, ২০২৫',
          'Dhaka Mohanagar Imarat Bidhimala, 2025'),
      detail: L10nText(
          'এস.আর.ও. নং ৪৬৯-আইন/২০২৫ · বাংলাদেশ গেজেট, অতিরিক্ত, '
              '১৪ ডিসেম্বর ২০২৫',
          'S.R.O. 469-Ain/2025 · Bangladesh Gazette, Extraordinary, '
              '14 December 2025'),
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'book',
      kind: WorkKind.book,
      title: L10nText('বাড়ি নির্মাণ ও সাইট সুপারভিশন (২০১৯)',
          'Bari Nirman o Site Supervision (2019)'),
      detail: L10nText(
          'তথ্যের জন্য দেখা হয়েছে; কোনো লেখা, ছক বা ছবি ব্যবহার করা হয়নি',
          'Consulted for facts only; no text, table or plate reproduced'),
    ),
    ReferenceWork(
      id: 'dg_food',
      kind: WorkKind.drawing,
      title: L10nText('খাদ্য অধিদপ্তর — ১০০০ মেট্রিক টন গুদামের টাইপ ডিজাইন',
          'Directorate General of Food — 1000 MT godown type design'),
      detail: L10nText('আগস্ট ২০২৪ · এই নকশার মাপ, সর্বজনীন মান নয়',
          'August 2024 · this design\'s figures, not national standards'),
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'bds_steel',
      kind: WorkKind.standard,
      title: L10nText('BDS ISO 6935-2 — রিইনফোর্সিং স্টিল',
          'BDS ISO 6935-2 — reinforcing steel'),
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'lged_roads',
      kind: WorkKind.standard,
      title: L10nText('LGED রোড ডিজাইন স্ট্যান্ডার্ডস',
          'LGED road design standards'),
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'rti',
      kind: WorkKind.law,
      title: L10nText('তথ্য অধিকার আইন, ২০০৯',
          'Right to Information Act, 2009'),
      url: 'https://bdlaws.minlaw.gov.bd/upload/act/2021-11-17-11-22-38-37.-The-Right-to-Information-Act-2009.pdf',
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'ppa',
      kind: WorkKind.law,
      title: L10nText('পাবলিক প্রকিউরমেন্ট আইন ২০০৬ ও বিধিমালা ২০০৮',
          'Public Procurement Act 2006 and Rules 2008'),
      url: 'https://bdlaws.minlaw.gov.bd',
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'up_act',
      kind: WorkKind.law,
      title: L10nText('স্থানীয় সরকার (ইউনিয়ন পরিষদ) আইন, ২০০৯',
          'Local Government (Union Parishad) Act, 2009'),
      url: 'https://bdlaws.minlaw.gov.bd',
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'labour_act',
      kind: WorkKind.law,
      title: L10nText('বাংলাদেশ শ্রম আইন, ২০০৬',
          'Bangladesh Labour Act, 2006'),
      url: 'https://bdlaws.minlaw.gov.bd',
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'bppa',
      kind: WorkKind.portal,
      title: L10nText('সরকারি ক্রয় বাতায়ন ও ই-জিপি পোর্টাল (বিপিপিএ)',
          'Government procurement portal and e-GP (BPPA)'),
      detail: L10nText('DIMAPPP নাগরিক পর্যবেক্ষণ কার্যক্রমসহ',
          'Including the DIMAPPP citizen-monitoring programme'),
      url: 'https://www.eprocure.gov.bd',
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'grs',
      kind: WorkKind.portal,
      title: L10nText('অভিযোগ প্রতিকার ব্যবস্থা (GRS) ও কল সেন্টার ৩৩৩',
          'Grievance Redress System (GRS) and call centre 333'),
      url: 'https://grs.gov.bd',
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'nlaso',
      kind: WorkKind.portal,
      title: L10nText('জাতীয় আইনগত সহায়তা প্রদান সংস্থা (NLASO) — ১৬৪৩০',
          'National Legal Aid Services Organisation (NLASO) — 16430'),
    ),
    ReferenceWork(
      id: 'acc',
      kind: WorkKind.portal,
      title: L10nText('দুর্নীতি দমন কমিশন হটলাইন — ১০৬',
          'Anti-Corruption Commission hotline — 106'),
      isGovernment: true,
    ),
    ReferenceWork(
      id: 'wb',
      kind: WorkKind.study,
      title: L10nText('বিশ্বব্যাংক — বাংলাদেশের সরকারি ক্রয় ব্যবস্থার মূল্যায়ন',
          'World Bank — assessment of Bangladesh public procurement'),
      detail: L10nText('২০২০ · দেশভিত্তিক ব্যয় তুলনাসহ',
          '2020 · with cross-country cost comparisons'),
    ),
    ReferenceWork(
      id: 'tib',
      kind: WorkKind.study,
      title: L10nText('টিআইবি — সড়ক খাতের গবেষণা',
          'TIB — research on the roads sector'),
    ),
    ReferenceWork(
      id: 'press',
      kind: WorkKind.press,
      title: L10nText('সংবাদমাধ্যমে প্রকাশিত অনুসন্ধান ও প্রতিবেদন',
          'Published newspaper investigations and reports'),
    ),
    ReferenceWork(
      id: 'market',
      kind: WorkKind.market,
      title: L10nText('উৎপাদক ও সরবরাহকারীদের প্রকাশিত মূল্যতালিকা',
          'Published price lists from manufacturers and suppliers'),
      detail: L10nText('২০২৬ · বাজারদর বদলায়, তারিখ দেখে নিন',
          '2026 · market rates move; check the date'),
    ),
    ReferenceWork(
      id: 'practice',
      kind: WorkKind.practice,
      title: L10nText('মাঠপর্যায়ের প্রচলিত চর্চা ও চুক্তির রীতি',
          'Established site practice and contracting convention'),
      detail: L10nText('কোনো প্রকাশিত মান নয় — প্রচলিত চর্চা',
          'Not a published standard — what is customarily done'),
    ),
    ReferenceWork(
      id: 'arithmetic',
      kind: WorkKind.practice,
      title: L10nText('একক, রূপান্তর ও পাটিগণিত',
          'Units, conversions and arithmetic'),
      detail: L10nText('সংজ্ঞা থেকে গণনা করা — বাইরের কোনো সূত্র নয়',
          'Computed from definitions — no outside source'),
    ),
  ];

  static ReferenceWork? match(String source) {
    for (final w in all) {
      if (w.claims(source)) return w;
    }
    return null;
  }
}

enum WorkKind {
  code('কোড ও মান', 'Codes and standards'),
  standard('কোড ও মান', 'Codes and standards'),
  law('আইন ও বিধি', 'Law and rules'),
  schedule('সরকারি দর তফসিল', 'Government rate schedules'),
  drawing('নকশা', 'Drawings'),
  book('বই', 'Books'),
  portal('সরকারি সেবা ও পোর্টাল', 'Government services and portals'),
  study('গবেষণা ও মূল্যায়ন', 'Research and assessments'),
  press('সংবাদমাধ্যম', 'Press'),
  market('বাজারদর', 'Market rates'),
  practice('প্রচলিত চর্চা', 'Established practice');

  const WorkKind(this.bn, this.en);

  final String bn;
  final String en;

  L10nText get label => L10nText(bn, en);
}
