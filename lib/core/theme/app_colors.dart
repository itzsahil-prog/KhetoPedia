import 'package:flutter/material.dart';

/// All design-token colors for Khetopedia.
/// Screens access these via [AppTheme.of(context)] or directly.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF2E7D32);
  static const Color primaryLight   = Color(0xFF60AD5E);
  static const Color primaryDark    = Color(0xFF005005);
  static const Color onPrimary      = Color(0xFFFFFFFF);

  static const Color secondary      = Color(0xFF558B2F);
  static const Color secondaryLight = Color(0xFF85BB5C);
  static const Color secondaryDark  = Color(0xFF255D00);
  static const Color onSecondary    = Color(0xFFFFFFFF);

  static const Color tertiary       = Color(0xFFF9A825);
  static const Color onTertiary     = Color(0xFF000000);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF388E3C);
  static const Color onSuccess      = Color(0xFFFFFFFF);
  static const Color warning        = Color(0xFFF57F17);
  static const Color onWarning      = Color(0xFFFFFFFF);
  static const Color error          = Color(0xFFD32F2F);
  static const Color onError        = Color(0xFFFFFFFF);
  static const Color info           = Color(0xFF0288D1);
  static const Color onInfo         = Color(0xFFFFFFFF);

  // ── Surface (light) ────────────────────────────────────────────────────
  static const Color backgroundLight         = Color(0xFFF9FBF7);
  static const Color surfaceLight            = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight     = Color(0xFFEEF2EA);
  static const Color outlineLight            = Color(0xFFE0E0E0);
  static const Color onBackgroundLight       = Color(0xFF1B1C1A);
  static const Color onSurfaceLight          = Color(0xFF1B1C1A);
  static const Color onSurfaceVariantLight   = Color(0xFF6B6E6A);

  // ── Surface (dark) ─────────────────────────────────────────────────────
  static const Color backgroundDark          = Color(0xFF121212);
  static const Color surfaceDark             = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark      = Color(0xFF2A2A2A);
  static const Color outlineDark             = Color(0xFF333333);
  static const Color onBackgroundDark        = Color(0xFFE8E8E8);
  static const Color onSurfaceDark           = Color(0xFFE8E8E8);
  static const Color onSurfaceVariantDark    = Color(0xFF9E9E9E);

  // ── Primary container ──────────────────────────────────────────────────
  static const Color primaryContainerLight   = Color(0xFFE8F5E9);
  static const Color primaryContainerDark    = Color(0xFF1B3320);
  static const Color onPrimaryContainerLight = Color(0xFF005005);
  static const Color onPrimaryContainerDark  = Color(0xFF85BB5C);

  // ── Transparent helpers ────────────────────────────────────────────────
  static const Color transparent = Colors.transparent;
}
