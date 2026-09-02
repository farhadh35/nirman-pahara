/// The two languages the app ships in.
///
/// Bangla is the default and the authoring language: every string exists in
/// Bangla first, and English is a translation that may lag. When an English
/// string is missing the Bangla is shown rather than a blank or a key — a user
/// who switched to English still gets the information.
enum AppLocale {
  bn('bn'),
  en('en');

  const AppLocale(this.code);

  final String code;

  bool get isBangla => this == AppLocale.bn;

  /// The language's name in itself — বাংলা, English.
  ///
  /// Language pickers use this and never a translated name. Someone who reads
  /// only English, opening the app in its Bangla default, must still be able
  /// to find "English"; showing them "ইংরেজি" strands them.
  String get endonym => switch (this) {
        AppLocale.bn => 'বাংলা',
        AppLocale.en => 'English',
      };

  static AppLocale parse(String? code) =>
      code == 'en' ? AppLocale.en : AppLocale.bn;
}

/// A piece of user-facing text in both languages.
///
/// In content JSON this is written either as an object — `{"bn": "…", "en": "…"}`
/// — or as a bare string, which is taken as Bangla-only. The bare form keeps
/// authoring fast while a module is still being drafted.
class L10nText {
  const L10nText(this.bn, [this.en]);

  final String bn;
  final String? en;

  /// True when the English translation has not been written yet.
  bool get needsTranslation => en == null || en!.trim().isEmpty;

  String of(AppLocale locale) =>
      locale == AppLocale.en && !needsTranslation ? en! : bn;

  String call(AppLocale locale) => of(locale);

  static L10nText fromJson(dynamic j) {
    if (j == null) return const L10nText('');
    if (j is String) return L10nText(j);
    if (j is Map) {
      return L10nText(
        (j['bn'] ?? '') as String,
        j['en'] as String?,
      );
    }
    throw FormatException('Not a localisable string: $j');
  }

  static List<L10nText> listFromJson(dynamic j) =>
      (j as List?)?.map(L10nText.fromJson).toList() ?? const [];

  @override
  String toString() => bn;

  @override
  bool operator ==(Object other) =>
      other is L10nText && other.bn == bn && other.en == en;

  @override
  int get hashCode => Object.hash(bn, en);
}
