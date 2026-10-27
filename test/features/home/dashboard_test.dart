import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khetopedia/core/localization/localization.dart';
import 'package:khetopedia/features/home/application/dashboard_provider.dart';
import 'package:khetopedia/features/home/home_screen.dart';
import 'package:khetopedia/features/home/domain/dashboard_summary.dart';

void main() {
  group('Dashboard Widget Tests', () {
    testWidgets('displays loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      // Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) {
              return FakeDashboardNotifier(throwError: true);
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message and retry button
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays dashboard sections when loaded', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith((ref) {
              return FakeDashboardNotifier(throwError: false);
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show greeting
      expect(find.textContaining('Good'), findsOneWidget);
      
      // Should show dashboard sections
      expect(find.text('Farm Overview'), findsOneWidget);
      expect(find.text('Active Alerts'), findsOneWidget);
    });
  });
}

// Fake notifier for testing
class FakeDashboardNotifier extends AutoDisposeAsyncNotifier<DashboardSummary> {
  final bool throwError;

  FakeDashboardNotifier({required this.throwError});

  @override
  Future<DashboardSummary> build() async {
    if (throwError) {
      throw Exception('Test error');
    }
    return const DashboardSummary(
      totalFields: 3,
      healthyFields: 2,
      atRiskFields: 1,
      criticalFields: 0,
      activeAlerts: [],
      recentFields: [],
    );
  }
}
