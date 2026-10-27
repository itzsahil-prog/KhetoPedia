import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khetopedia/core/localization/localization.dart';
import 'package:khetopedia/features/settings/presentation/settings_screen.dart';
import 'package:khetopedia/features/settings/application/settings_provider.dart';
import 'package:khetopedia/features/settings/domain/settings.dart';
import 'package:khetopedia/shared/providers/theme_provider.dart';
import 'package:khetopedia/shared/providers/locale_provider.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('displays theme option', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return FakeSettingsNotifier();
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('displays language option', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return FakeSettingsNotifier();
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('displays notification toggles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return FakeSettingsNotifier();
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Crop Scan Alerts'), findsOneWidget);
      expect(find.text('Soil Test Alerts'), findsOneWidget);
      expect(find.text('Field Alerts'), findsOneWidget);
      expect(find.text('AI Recommendations'), findsOneWidget);
      
      // Should have 4 switch widgets for notifications
      expect(find.byType(SwitchListTile), findsNWidgets(4));
    });

    testWidgets('theme dialog opens on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return FakeSettingsNotifier();
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on theme option
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Dialog should appear with theme options
      expect(find.text('Light'), findsAtLeast(1));
      expect(find.text('Dark'), findsAtLeast(1));
      expect(find.text('System'), findsAtLeast(1));
    });

    testWidgets('language dialog opens on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) {
              return FakeSettingsNotifier();
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on language option
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Dialog should appear with language options
      expect(find.text('English'), findsAtLeast(1));
      expect(find.textContaining('हिन्दी'), findsAtLeast(1));
    });
  });
}

// Fake notifier for testing
class FakeSettingsNotifier extends AutoDisposeAsyncNotifier<Settings> {
  @override
  Future<Settings> build() async {
    return const Settings(
      notificationsCrop: true,
      notificationsSoil: true,
      notificationsAlerts: true,
      notificationsAI: false,
    );
  }
}
