import 'i18n/app_locale.dart';

/// Identity, version and attribution, in one place.
///
/// [version] and [buildNumber] are kept here rather than read at runtime so
/// that no dependency is needed to show them; a test asserts they still match
/// `pubspec.yaml`, which is what stops the pair drifting apart the way a
/// hand-maintained version string always eventually does.
class AppInfo {
  AppInfo._();

  static const version = '1.1.1';
  static const buildNumber = 3;
  static const applicationId = 'bd.nirmanpahara.nirman_pahara';

  static String get versionLabel => '$version ($buildNumber)';

  static const copyright = L10nText(
    '© ২০২৬ নির্মাণ পাহারা',
    '© 2026 Nirman Pahara',
  );

  /// What the app is built on, and under what terms.
  static const attributions = <Attribution>[
    Attribution(
      name: 'Noto Sans Bengali',
      detail: L10nText(
        'বাংলা ফন্ট, SIL Open Font License 1.1 — যুক্তাক্ষর সব ফোনে একইভাবে '
            'দেখানোর জন্য অ্যাপের সঙ্গেই দেওয়া আছে।',
        'Bangla typeface, SIL Open Font License 1.1 — bundled so conjuncts '
            'render identically on every handset.',
      ),
      url: 'https://github.com/notofonts/bengali',
    ),
    Attribution(
      name: 'PWD Schedule of Rates 2022 (2nd revised)',
      detail: L10nText(
        'গণপূর্ত অধিদপ্তরের প্রকাশিত সরকারি নথি থেকে রেট নেওয়া হয়েছে।',
        'Rates taken from the schedule published by the Public Works '
            'Department.',
      ),
      url: 'https://ss.pwd.gov.bd/document/sor/Final_SoR_2022%20_2nd_Revised.pdf',
    ),
    Attribution(
      name: 'PWD Schedule of Rates 2022 for E/M Works (2nd revised)',
      detail: L10nText(
        'তড়িৎ ও যান্ত্রিক কাজের রেট — গণপূর্ত অধিদপ্তরের আলাদা তফসিল থেকে।',
        'Electro-mechanical rates, from the separate volume the Public Works '
            'Department publishes for them.',
      ),
      url: 'https://ss.pwd.gov.bd/document/sor/'
          'Pwd_Schedule_Of_Rates_EM_2nd_revised.pdf',
    ),
    Attribution(
      name: 'BNBC 2020',
      detail: L10nText(
        'কারিগরি তথ্যের সূত্র — বাংলাদেশ ন্যাশনাল বিল্ডিং কোড।',
        'Source for the technical content — the Bangladesh National Building '
            'Code.',
      ),
    ),
    Attribution(
      name: 'Flutter',
      detail: L10nText(
        'অ্যাপ তৈরির কাঠামো, BSD-3-Clause লাইসেন্স।',
        'The framework the app is built with, under the BSD-3-Clause licence.',
      ),
      url: 'https://flutter.dev',
    ),
  ];

  /// Shown beside the copyright line.
  static const licence = L10nText(
    'অ্যাপের কোড Apache License 2.0-এর অধীনে, আর ভেতরের লেখা ও ছক '
        'Creative Commons BY-SA 4.0-এর অধীনে — অর্থাৎ যে কেউ ব্যবহার, অনুবাদ ও '
        'বিতরণ করতে পারবে, শর্ত হলো কৃতিত্ব দিতে হবে আর একই শর্তে ছাড়তে হবে।',
    'The code is under the Apache License 2.0 and the written content and '
        'diagrams under Creative Commons BY-SA 4.0 — anyone may use, translate '
        'and redistribute them, provided they credit the source and pass on the '
        'same freedoms.',
  );
}

class Attribution {
  const Attribution({required this.name, required this.detail, this.url});

  final String name;
  final L10nText detail;
  final String? url;
}
