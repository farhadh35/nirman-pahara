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

  /// Used for "look at this", never for decoration.
  static const Color warning = Color(0xFFE8890C);
  static const Color danger = Color(0xFFC62828);
  static const Color ok = Color(0xFF2E7D32);

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
      error: danger,
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
