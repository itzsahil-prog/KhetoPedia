import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khetopedia/core/localization/localization.dart';
import 'package:khetopedia/features/fields/fields_screen.dart';
import 'package:khetopedia/features/fields/application/fields_provider.dart';
import 'package:khetopedia/features/fields/domain/field.dart';

void main() {
  group('FieldsScreen Widget Tests', () {
    testWidgets('displays loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FieldsScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fieldsProvider.overrideWith((ref) {
              return FakeFieldsNotifier(fields: []);
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FieldsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No fields yet. Add your first field.'), findsOneWidget);
      expect(find.text('Add Field'), findsOneWidget);
    });

    testWidgets('displays list of fields', (tester) async {
      final testFields = [
        const Field(
          id: 1,
          name: 'North Field',
          crop: 'Wheat',
          areaHectares: 2.5,
          healthScore: 85.0,
        ),
        const Field(
          id: 2,
          name: 'South Field',
          crop: 'Rice',
          areaHectares: 3.0,
          healthScore: 92.0,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fieldsProvider.overrideWith((ref) {
              return FakeFieldsNotifier(fields: testFields);
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FieldsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('North Field'), findsOneWidget);
      expect(find.text('South Field'), findsOneWidget);
      expect(find.text('Wheat'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
    });

    testWidgets('displays add field button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fieldsProvider.overrideWith((ref) {
              return FakeFieldsNotifier(fields: []);
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FieldsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Field'), findsAtLeastNWidgets(1));
    });
  });
}

// Fake notifier for testing
class FakeFieldsNotifier extends AutoDisposeAsyncNotifier<List<Field>> {
  final List<Field> fields;

  FakeFieldsNotifier({required this.fields});

  @override
  Future<List<Field>> build() async {
    return fields;
  }
}
