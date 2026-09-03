import 'package:flutter/material.dart';

/// Reading size, chosen in settings.
///
/// The audience includes people who read slowly and people holding a phone at
/// arm's length in bright sun. The default is deliberately larger than a
/// typical app's.
enum TextScalePreference {
  normal('স্বাভাবিক', 1.0),
  large('বড়', 1.18),
  extraLarge('আরও বড়', 1.38);

  const TextScalePreference(this.labelBn, this.factor);
  final String labelBn;
  final double factor;
}

class AppTheme {
  AppTheme._();

  /// Bangladesh flag green — reads as civic and official, not commercial.
  static const Color primary = Color(0xFF006A4E);
  static const Color primaryDark = Color(0xFF004D39);

  /// "Look at this", "this is fine", "this is wrong" — never decoration.
  ///
  /// Two values each, resolved against the theme, because no single colour
  /// clears the 4.5:1 contrast body text needs on both a near-white page and a
  /// near-black one. The amber that reads well on the dark theme sits at 2.4:1
  /// on the light one — fainter than the page's own hairlines, and the light
  /// theme is the default. Reach for [warningOn] and its pair, not a constant.
  static const Color _warningLight = Color(0xFF8A5200);
  static const Color _warningDark = Color(0xFFE8890C);
  static const Color _dangerLight = Color(0xFFC62828);
  static const Color _dangerDark = Color(0xFFE57373);
  static const Color _okLight = Color(0xFF2E7D32);
  static const Color _okDark = Color(0xFF66BB6A);

  static Color warningOn(BuildContext context) =>
      _pick(context, _warningLight, _warningDark);
  static Color dangerOn(BuildContext context) =>
      _pick(context, _dangerLight, _dangerDark);
  static Color okOn(BuildContext context) => _pick(context, _okLight, _okDark);

  static Color _pick(BuildContext context, Color light, Color dark) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// The same three, for tests and for code that already knows its brightness.
  @visibleForTesting
  static Color statusColour(String name, Brightness brightness) => switch (name) {
        'warning' => brightness == Brightness.dark ? _warningDark : _warningLight,
        'danger' => brightness == Brightness.dark ? _dangerDark : _dangerLight,
        _ => brightness == Brightness.dark ? _okDark : _okLight,
      };

  static const String fontFamily = 'NotoSansBengali';

  /// Minimum tap target. Larger than Material's 48 because of gloved, wet and
  /// older hands on a construction site.
  static const double minTapTarget = 56.0;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      error: brightness == Brightness.dark ? _dangerDark : _dangerLight,
    );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: fontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF7F7F4)
          : const Color(0xFF121412),
      textTheme: _textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        color: scheme.surface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Height only. Size.fromHeight would force infinite width, which
          // blows up the moment a button sits in a Row.
          minimumSize: const Size(64, minTapTarget),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          // Height only. Size.fromHeight would force infinite width, which
          // blows up the moment a button sits in a Row.
          minimumSize: const Size(64, minTapTarget),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }

  /// Bangla needs more line height than Latin — conjuncts and the matra line
  /// collide at Material's default 1.2–1.4.
  static TextTheme _textTheme(TextTheme base) {
    TextStyle? s(TextStyle? t, double size, FontWeight w, double height) =>
        t?.copyWith(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: w,
          height: height,
        );

    return base.copyWith(
      displaySmall: s(base.displaySmall, 30, FontWeight.w700, 1.45),
      headlineMedium: s(base.headlineMedium, 26, FontWeight.w700, 1.45),
      headlineSmall: s(base.headlineSmall, 22, FontWeight.w600, 1.5),
      titleLarge: s(base.titleLarge, 20, FontWeight.w600, 1.5),
      titleMedium: s(base.titleMedium, 18, FontWeight.w600, 1.5),
      titleSmall: s(base.titleSmall, 16, FontWeight.w600, 1.5),
      bodyLarge: s(base.bodyLarge, 17, FontWeight.w400, 1.75),
      bodyMedium: s(base.bodyMedium, 16, FontWeight.w400, 1.7),
      bodySmall: s(base.bodySmall, 14, FontWeight.w400, 1.6),
      labelLarge: s(base.labelLarge, 16, FontWeight.w600, 1.4),
      labelMedium: s(base.labelMedium, 14, FontWeight.w500, 1.4),
      labelSmall: s(base.labelSmall, 12, FontWeight.w500, 1.4),
    );
  }
}
