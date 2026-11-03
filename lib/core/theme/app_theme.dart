import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Centralised [ThemeData] factory for light, dark, and system themes.
///
/// Usage:
/// ```dart
/// MaterialApp.router(
///   theme:      AppTheme.light,
///   darkTheme:  AppTheme.dark,
///   themeMode:  themeMode, // driven by [ThemeNotifier]
/// )
/// ```
abstract final class AppTheme {
  // ── Public theme instances ─────────────────────────────────────────────
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  // ── Private factory ────────────────────────────────────────────────────
  static ThemeData _build(Brightness brightness) {
    final isDark  = brightness == Brightness.dark;
    final bg      = isDark ? AppColors.backgroundDark          : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark             : AppColors.surfaceLight;
    final surfV   = isDark ? AppColors.surfaceVariantDark      : AppColors.surfaceVariantLight;
    final outline = isDark ? AppColors.outlineDark             : AppColors.outlineLight;
    final onBg    = isDark ? AppColors.onBackgroundDark        : AppColors.onBackgroundLight;
    final onSurf  = isDark ? AppColors.onSurfaceDark           : AppColors.onSurfaceLight;
    final onSurfV = isDark ? AppColors.onSurfaceVariantDark    : AppColors.onSurfaceVariantLight;
    final priCont = isDark ? AppColors.primaryContainerDark    : AppColors.primaryContainerLight;
    final onPriC  = isDark ? AppColors.onPrimaryContainerDark  : AppColors.onPrimaryContainerLight;
    final primary = isDark ? AppColors.primaryLight            : AppColors.primary;
    final onPri   = isDark ? AppColors.onTertiary              : AppColors.onPrimary;

    final colorScheme = ColorScheme(
      brightness:              brightness,
      primary:                 primary,
      onPrimary:               onPri,
      primaryContainer:        priCont,
      onPrimaryContainer:      onPriC,
      secondary:               isDark ? AppColors.secondaryLight : AppColors.secondary,
      onSecondary:             AppColors.onSecondary,
      secondaryContainer:      isDark ? AppColors.secondaryDark  : AppColors.surfaceVariantLight,
      onSecondaryContainer:    onSurf,
      tertiary:                AppColors.tertiary,
      onTertiary:              AppColors.onTertiary,
      tertiaryContainer:       AppColors.tertiary.withAlpha(51),
      onTertiaryContainer:     onBg,
      error:                   AppColors.error,
      onError:                 AppColors.onError,
      errorContainer:          AppColors.error.withAlpha(26),
      onErrorContainer:        AppColors.error,
      surface:                 surface,
      onSurface:               onSurf,
      surfaceContainerHighest: surfV,
      onSurfaceVariant:        onSurfV,
      outline:                 outline,
      outlineVariant:          outline.withAlpha(128),
      shadow:                  Colors.black,
      scrim:                   Colors.black,
      inverseSurface:          onSurf,
      onInverseSurface:        surface,
      inversePrimary:          priCont,
    );

    final textTheme = TextTheme(
      displayLarge:   AppTextStyles.displayLarge(onBg),
      displayMedium:  AppTextStyles.displayMedium(onBg),
      displaySmall:   AppTextStyles.displaySmall(onBg),
      headlineLarge:  AppTextStyles.headlineLarge(onBg),
      headlineMedium: AppTextStyles.headlineMedium(onBg),
      headlineSmall:  AppTextStyles.headlineSmall(onBg),
      titleLarge:     AppTextStyles.titleLarge(onBg),
      titleMedium:    AppTextStyles.titleMedium(onBg),
      titleSmall:     AppTextStyles.titleSmall(onBg),
      bodyLarge:      AppTextStyles.bodyLarge(onBg),
      bodyMedium:     AppTextStyles.bodyMedium(onBg),
      bodySmall:      AppTextStyles.bodySmall(onBg),
      labelLarge:     AppTextStyles.labelLarge(onBg),
      labelMedium:    AppTextStyles.labelMedium(onBg),
      labelSmall:     AppTextStyles.labelSmall(onBg),
    );

    return ThemeData(
      useMaterial3:            true,
      brightness:              brightness,
      colorScheme:             colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme:               textTheme,
      // ── App Bar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:   surface,
        foregroundColor:   onSurf,
        surfaceTintColor:  Colors.transparent,
        shadowColor:       Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle:    AppTextStyles.titleLarge(onSurf),
        centerTitle:       false,
        elevation:         0,
      ),
      // ── Cards ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:          surface,
        surfaceTintColor: Colors.transparent,
        elevation:      0,
        shape:          RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:         BorderSide(color: outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 0),
      // ── Input decoration ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        surface,
        contentPadding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border:           OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder:    OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder:    OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder:      OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle:        AppTextStyles.bodyMedium(onSurfV),
        labelStyle:       AppTextStyles.bodyMedium(onSurfV),
        errorStyle:       AppTextStyles.bodySmall(AppColors.error),
      ),
      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:  surfV,
        labelStyle:       AppTextStyles.labelMedium(onSurf),
        side:             BorderSide(color: outline),
        shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding:          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      // ── Bottom Nav ────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:         surface,
        selectedItemColor:        primary,
        unselectedItemColor:      onSurfV,
        selectedLabelStyle:       AppTextStyles.labelSmall(primary),
        unselectedLabelStyle:     AppTextStyles.labelSmall(onSurfV),
        showSelectedLabels:       true,
        showUnselectedLabels:     true,
        type:                     BottomNavigationBarType.fixed,
        elevation:                0,
      ),
      // ── Navigation Bar (Material 3) ────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:         surface,
        indicatorColor:          priCont,
        iconTheme:               WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(color: onSurfV, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall(primary);
          }
          return AppTextStyles.labelSmall(onSurfV);
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      // ── Navigation Rail ────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor:       surface,
        selectedIconTheme:     IconThemeData(color: primary, size: 24),
        unselectedIconTheme:   IconThemeData(color: onSurfV, size: 24),
        selectedLabelTextStyle: AppTextStyles.labelSmall(primary),
        unselectedLabelTextStyle: AppTextStyles.labelSmall(onSurfV),
        indicatorColor:        priCont,
        elevation:             0,
      ),
      // ── FloatingActionButton ───────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPri,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation:       2,
      ),
      // ── ElevatedButton ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:       primary,
          foregroundColor:       onPri,
          disabledBackgroundColor: outline,
          textStyle:             AppTextStyles.labelLarge(onPri),
          shape:                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize:           const Size(0, 48),
          padding:               const EdgeInsets.symmetric(horizontal: 24),
          elevation:             0,
        ),
      ),
      // ── OutlinedButton ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side:            BorderSide(color: primary),
          textStyle:       AppTextStyles.labelLarge(primary),
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize:     const Size(0, 48),
          padding:         const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
      // ── TextButton ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle:       AppTextStyles.labelLarge(primary),
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize:     const Size(0, 40),
          padding:         const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      // ── Snackbar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:    isDark ? surfV : const Color(0xFF1B1C1A),
        contentTextStyle:   AppTextStyles.bodyMedium(isDark ? onSurf : Colors.white),
        shape:              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior:           SnackBarBehavior.floating,
      ),
      // ── ProgressIndicator ──────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      // ── Switch / Checkbox / Radio ──────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? onPri : onSurfV,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(onPri),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: outline, width: 1.5),
      ),
    );
  }
}
