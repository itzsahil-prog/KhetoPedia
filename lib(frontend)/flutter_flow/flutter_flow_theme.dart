import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Khetopedia color tokens ───────────────────────────────────────────────
// Primary green palette
const Color _kPrimary = Color(0xFF2E7D32);
const Color _kOnPrimary = Color(0xFFFFFFFF);
const Color _kSecondary = Color(0xFF558B2F);
const Color _kOnSecondary = Color(0xFFFFFFFF);
const Color _kTertiary = Color(0xFFF9A825);
const Color _kError = Color(0xFFD32F2F);
const Color _kOnError = Color(0xFFFFFFFF);
const Color _kSuccess = Color(0xFF388E3C);
const Color _kWarning = Color(0xFFF57F17);
const Color _kInfo = Color(0xFF0288D1);

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _DarkTheme() : _LightTheme();
  }

  // ── Colors ────────────────────────────────────────────────────────────────
  Color get primary;
  Color get onPrimary;
  Color get secondary;
  Color get onSecondary;
  Color get tertiary;
  Color get error;
  Color get onError;
  Color get success;
  Color get warning;
  Color get info;

  Color get primaryBackground;
  Color get secondaryBackground;
  Color get alternate;
  Color get surface80;
  Color get surface20;

  Color get primaryText;
  Color get secondaryText;
  Color get onBackground;
  Color get onSurface;
  Color get onWarning;
  Color get primaryContainer;
  Color get accent3;

  // Semi-transparent variants
  Color get primary8 => primary.withAlpha(20);
  Color get primary20 => primary.withAlpha(51);
  Color get onPrimary10 => onPrimary.withAlpha(26);
  Color get onPrimary20 => onPrimary.withAlpha(51);
  Color get onPrimary30 => onPrimary.withAlpha(77);
  Color get onWarning0 => onWarning.withAlpha(0);
  Color get onWarning27 => onWarning.withAlpha(69);
  Color get onWarning40 => onWarning.withAlpha(102);
  Color get onWarning53 => onWarning.withAlpha(135);
  Color get onWarning60 => onWarning.withAlpha(153);
  Color get onWarning67 => onWarning.withAlpha(171);
  Color get onWarning80 => onWarning.withAlpha(204);
  Color get secondary20 => secondary.withAlpha(51);

  // ── Text Styles ───────────────────────────────────────────────────────────
  TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 57, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 45, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 36, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 32, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 28, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 24, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w500, color: primaryText);
  TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w500, color: primaryText);
  TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w500, color: primaryText);
  TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: primaryText);
  TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: primaryText);
  TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, color: primaryText);
  TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, color: primaryText);

  // ── Theme Data ────────────────────────────────────────────────────────────
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          error: error,
          surface: secondaryBackground,
        ),
        scaffoldBackgroundColor: primaryBackground,
        textTheme: TextTheme(
          displayLarge: displayLarge,
          displayMedium: displayMedium,
          displaySmall: displaySmall,
          headlineLarge: headlineLarge,
          headlineMedium: headlineMedium,
          headlineSmall: headlineSmall,
          titleLarge: titleLarge,
          titleMedium: titleMedium,
          titleSmall: titleSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: labelLarge,
          labelMedium: labelMedium,
          labelSmall: labelSmall,
        ),
      );
}

class _LightTheme extends FlutterFlowTheme {
  @override Color get primary => _kPrimary;
  @override Color get onPrimary => _kOnPrimary;
  @override Color get secondary => _kSecondary;
  @override Color get onSecondary => _kOnSecondary;
  @override Color get tertiary => _kTertiary;
  @override Color get error => _kError;
  @override Color get onError => _kOnError;
  @override Color get success => _kSuccess;
  @override Color get warning => _kWarning;
  @override Color get info => _kInfo;
  @override Color get primaryBackground => const Color(0xFFF9FBF7);
  @override Color get secondaryBackground => const Color(0xFFFFFFFF);
  @override Color get alternate => const Color(0xFFE0E0E0);
  @override Color get surface80 => const Color(0xCCFFFFFF);
  @override Color get surface20 => const Color(0x33FFFFFF);
  @override Color get primaryText => const Color(0xFF1B1C1A);
  @override Color get secondaryText => const Color(0xFF6B6E6A);
  @override Color get onBackground => const Color(0xFFFFFFFF);
  @override Color get onSurface => const Color(0xFF1B1C1A);
  @override Color get onWarning => const Color(0xFF000000);
  @override Color get primaryContainer => const Color(0xFFE8F5E9);
  @override Color get accent3 => const Color(0xFF9E9E9E);
}

class _DarkTheme extends FlutterFlowTheme {
  @override Color get primary => const Color(0xFF66BB6A);
  @override Color get onPrimary => const Color(0xFF000000);
  @override Color get secondary => const Color(0xFF8BC34A);
  @override Color get onSecondary => const Color(0xFF000000);
  @override Color get tertiary => _kTertiary;
  @override Color get error => const Color(0xFFEF5350);
  @override Color get onError => const Color(0xFF000000);
  @override Color get success => const Color(0xFF66BB6A);
  @override Color get warning => const Color(0xFFFFCA28);
  @override Color get info => const Color(0xFF29B6F6);
  @override Color get primaryBackground => const Color(0xFF121212);
  @override Color get secondaryBackground => const Color(0xFF1E1E1E);
  @override Color get alternate => const Color(0xFF333333);
  @override Color get surface80 => const Color(0xCC1E1E1E);
  @override Color get surface20 => const Color(0x331E1E1E);
  @override Color get primaryText => const Color(0xFFE8E8E8);
  @override Color get secondaryText => const Color(0xFF9E9E9E);
  @override Color get onBackground => const Color(0xFFE8E8E8);
  @override Color get onSurface => const Color(0xFFE8E8E8);
  @override Color get onWarning => const Color(0xFFFFFFFF);
  @override Color get primaryContainer => const Color(0xFF1B3320);
  @override Color get accent3 => const Color(0xFF757575);
}

// Extension so TextStyle.override(...) works as in FlutterFlow-generated code
extension TextStyleOverride on TextStyle {
  TextStyle override({
    TextStyle? font,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? lineHeight,
    TextDecoration? decoration,
  }) {
    return copyWith(
      fontFamily: font?.fontFamily,
      package: font?.package,
      color: color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      height: lineHeight ?? height,
      decoration: decoration ?? this.decoration,
    );
  }
}
