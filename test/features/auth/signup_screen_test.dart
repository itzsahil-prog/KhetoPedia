import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khetopedia/core/localization/localization.dart';
import 'package:khetopedia/features/auth/presentation/signup_screen.dart';

void main() {
  group('SignupScreen Widget Tests', () {
    testWidgets('displays all required fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SignupScreen(),
          ),
        ),
      );

      // Should have name, email, password, confirm password fields
      expect(find.byType(TextFormField), findsAtLeast(4));
    });

    testWidgets('validates all empty fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SignupScreen(),
          ),
        ),
      );

      // Find and tap create account button
      final createButton = find.text('Create Account');
      expect(createButton, findsOneWidget);
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should show multiple validation errors
      expect(find.text('This field is required.'), findsAtLeast(3));
    });

    testWidgets('validates password mismatch', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SignupScreen(),
          ),
        ),
      );

      // Fill in fields with mismatched passwords
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'different456');

      // Tap create account button
      final createButton = find.text('Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should show password mismatch error
      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('validates password minimum length', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SignupScreen(),
          ),
        ),
      );

      // Enter short password
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), '123');
      await tester.enterText(fields.at(3), '123');

      // Tap create account button
      final createButton = find.text('Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should show password length error
      expect(find.text('Password must be at least 8 characters.'), findsOneWidget);
    });

    testWidgets('displays terms of service text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SignupScreen(),
          ),
        ),
      );

      expect(find.textContaining('Terms of Service'), findsOneWidget);
    });
  });
}
