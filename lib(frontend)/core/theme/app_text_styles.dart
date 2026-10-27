import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Accessibility-friendly typographic scale.
///
/// - Display / Headline / Title → Outfit (geometric, readable at large sizes).
/// - Body / Label               → Inter (optimised for small-size legibility).
/// All sizes meet WCAG AA contrast when paired with [AppColors] surface tokens.
abstract final class AppTextStyles {
  // ── Display ────────────────────────────────────────────────────────────
  static TextStyle displayLarge(Color color) =>
      GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.w400, height: 1.12, letterSpacing: -0.25, color: color);
  static TextStyle displayMedium(Color color) =>
      GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.w400, height: 1.16, color: color);
  static TextStyle displaySmall(Color color) =>
      GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w400, height: 1.22, color: color);

  // ── Headline ───────────────────────────────────────────────────────────
  static TextStyle headlineLarge(Color color) =>
      GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w600, height: 1.25, color: color);
  static TextStyle headlineMedium(Color color) =>
      GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, height: 1.29, color: color);
  static TextStyle headlineSmall(Color color) =>
      GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, color: color);

  // ── Title ──────────────────────────────────────────────────────────────
  static TextStyle titleLarge(Color color) =>
      GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, height: 1.27, color: color);
  static TextStyle titleMedium(Color color) =>
      GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, letterSpacing: 0.15, color: color);
  static TextStyle titleSmall(Color color) =>
      GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, letterSpacing: 0.1, color: color);

  // ── Body ───────────────────────────────────────────────────────────────
  static TextStyle bodyLarge(Color color) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.5, color: color);
  static TextStyle bodyMedium(Color color) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0.25, color: color);
  static TextStyle bodySmall(Color color) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0.4, color: color);

  // ── Label ──────────────────────────────────────────────────────────────
  static TextStyle labelLarge(Color color) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1, color: color);
  static TextStyle labelMedium(Color color) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5, color: color);
  static TextStyle labelSmall(Color color) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5, color: color);
}
