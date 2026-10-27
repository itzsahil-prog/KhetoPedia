import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/localization.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'shared/providers/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // ProviderScope is the root of the Riverpod tree.
    const ProviderScope(child: KhetopediaApp()),
  );
}

/// Root application widget.
///
/// Watches [themeProvider] and [localeProvider] so theme/locale changes
/// rebuild only this widget, not the entire subtree.
class KhetopediaApp extends ConsumerWidget {
  const KhetopediaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale    = ref.watch(localeProvider);
    final router    = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // ── Identity ────────────────────────────────────────────────────────
      title:                   'Khetopedia',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────────────────
      theme:                   AppTheme.light,
      darkTheme:               AppTheme.dark,
      themeMode:               themeMode,

      // ── Localization ────────────────────────────────────────────────────
      locale:                  locale,
      supportedLocales:        AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Routing ─────────────────────────────────────────────────────────
      routerConfig:            router,

      // ── Accessibility ───────────────────────────────────────────────────
      // Allow text to scale with OS settings but cap at 1.3× to prevent
      // layout overflow on dense screens.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(
              mq.textScaler.scale(1).clamp(0.8, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
