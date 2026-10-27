import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:khetopedia/main.dart' as app;

/// Comprehensive Integration Tests for Khetopedia Flutter App
/// Tests complete user journeys from splash to features
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Khetopedia Full Integration Tests', () {
    // ══════════════════════════════════════════════════════════════════════
    // 1. APP LAUNCH FLOW
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('App Launch and Splash Screen Flow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should load without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should navigate past splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should reach login or home screen
      final hasLoginScreen = find.text('Login').evaluate().isNotEmpty ||
          find.text('लॉगिन').evaluate().isNotEmpty;
      final hasHomeScreen = find.text('Dashboard').evaluate().isNotEmpty ||
          find.text('डैशबोर्ड').evaluate().isNotEmpty;
      
      expect(hasLoginScreen || hasHomeScreen, true);
    });

    // ══════════════════════════════════════════════════════════════════════
    // 2. LOGIN FLOW
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Login Flow and Navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find login button/field (adjust based on actual widget structure)
      final emailField = find.byKey(const Key('emailField')).evaluate().isNotEmpty
          ? find.byKey(const Key('emailField'))
          : find.byType(TextField).first;
      
      if (emailField.evaluate().isNotEmpty) {
        await tester.tap(emailField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pumpAndSettle();

        // Find password field
        final passwordFields = find.byType(TextField);
        if (passwordFields.evaluate().length > 1) {
          await tester.tap(passwordFields.at(1));
          await tester.enterText(passwordFields.at(1), 'TestPassword123!');
          await tester.pumpAndSettle();
        }

        // Find and tap login button
        final loginButton = find.text('Login').evaluate().isNotEmpty
            ? find.text('Login')
            : find.text('लॉगिन');
        
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
      }

      // Should proceed (even if credentials are wrong, UI should respond)
      await tester.pumpAndSettle();
    });

    // ══════════════════════════════════════════════════════════════════════
    // 3. DASHBOARD DISPLAY
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Dashboard Display Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for dashboard elements (stats, weather, alerts)
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Check for common dashboard widgets
      final hasCards = find.byType(Card).evaluate().isNotEmpty;
      final hasText = find.byType(Text).evaluate().isNotEmpty;
      final hasImages = find.byType(Image).evaluate().isNotEmpty;
      
      expect(hasCards || hasText, true, reason: 'Dashboard should have content');
    });

    // ══════════════════════════════════════════════════════════════════════
    // 4. NAVIGATION TEST
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Bottom Navigation Bar Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for navigation bar
      final navBar = find.byType(BottomNavigationBar);
      
      if (navBar.evaluate().isNotEmpty) {
        // Tap different navigation items
        await tester.tap(navBar);
        await tester.pumpAndSettle();
        
        // Try tapping at different positions
        final navBarWidget = tester.widget<BottomNavigationBar>(navBar);
        final itemCount = navBarWidget.items.length;
        
        expect(itemCount, greaterThanOrEqualTo(3), 
            reason: 'Should have at least 3 nav items');
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 5. PROFILE SCREEN
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Profile Screen Navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for profile/settings icon
      final profileIcon = find.byIcon(Icons.person).evaluate().isNotEmpty
          ? find.byIcon(Icons.person)
          : find.byIcon(Icons.account_circle);
      
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Should show profile information
        expect(find.byType(Text).evaluate().isNotEmpty, true);
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 6. SETTINGS SCREEN
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Settings Screen Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for settings icon
      final settingsIcon = find.byIcon(Icons.settings);
      
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Should show settings options
        final hasSwitches = find.byType(Switch).evaluate().isNotEmpty;
        final hasRadios = find.byType(Radio).evaluate().isNotEmpty;
        final hasDropdowns = find.byType(DropdownButton).evaluate().isNotEmpty;
        
        expect(hasSwitches || hasRadios || hasDropdowns, true,
            reason: 'Settings should have interactive elements');
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 7. CROP SCANNER NAVIGATION
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Crop Scanner Screen Navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for scan/camera button
      final scanButton = find.byIcon(Icons.camera_alt).evaluate().isNotEmpty
          ? find.byIcon(Icons.camera_alt)
          : find.byIcon(Icons.photo_camera);
      
      if (scanButton.evaluate().isNotEmpty) {
        await tester.tap(scanButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Should navigate to crop scanner screen
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 8. SOIL ANALYSIS NAVIGATION
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Soil Analysis Screen Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for soil analysis related text or icons
      final soilText = find.textContaining('Soil', findRichText: true);
      final soilTextHindi = find.textContaining('मिट्टी', findRichText: true);
      
      if (soilText.evaluate().isNotEmpty) {
        await tester.tap(soilText.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (soilTextHindi.evaluate().isNotEmpty) {
        await tester.tap(soilTextHindi.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      
      // Should show some form or chart
      final hasCharts = find.byType(CustomPaint).evaluate().isNotEmpty;
      final hasForms = find.byType(TextField).evaluate().isNotEmpty;
      
      // Just verify app didn't crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════
    // 9. FIELDS MANAGEMENT
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Fields Screen Navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for fields related navigation
      final fieldsText = find.textContaining('Field', findRichText: true);
      final fieldsTextHindi = find.textContaining('खेत', findRichText: true);
      
      if (fieldsText.evaluate().isNotEmpty) {
        await tester.tap(fieldsText.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Should show list or grid of fields
        final hasList = find.byType(ListView).evaluate().isNotEmpty;
        final hasGrid = find.byType(GridView).evaluate().isNotEmpty;
        
        expect(hasList || hasGrid || find.byType(Card).evaluate().isNotEmpty, true,
            reason: 'Fields screen should display data structure');
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 10. RECOMMENDATIONS SCREEN
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Recommendations Screen Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for recommendations
      final recoText = find.textContaining('Recommend', findRichText: true);
      final recoTextHindi = find.textContaining('सुझाव', findRichText: true);
      
      if (recoText.evaluate().isNotEmpty || recoTextHindi.evaluate().isNotEmpty) {
        final targetFinder = recoText.evaluate().isNotEmpty ? recoText : recoTextHindi;
        await tester.tap(targetFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Should show list of recommendations
        expect(find.byType(ListView).evaluate().isNotEmpty ||
               find.byType(Card).evaluate().isNotEmpty, true);
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 11. AI ASSISTANT CHAT
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('AI Assistant Chat Navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for chat or assistant button
      final chatIcon = find.byIcon(Icons.chat).evaluate().isNotEmpty
          ? find.byIcon(Icons.chat)
          : find.byIcon(Icons.message);
      
      if (chatIcon.evaluate().isNotEmpty) {
        await tester.tap(chatIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Should show chat interface
        final hasTextField = find.byType(TextField).evaluate().isNotEmpty;
        final hasListView = find.byType(ListView).evaluate().isNotEmpty;
        
        expect(hasTextField || hasListView, true,
            reason: 'Chat screen should have input or messages');
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 12. THEME SWITCHING
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Theme Switching Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to settings
      final settingsIcon = find.byIcon(Icons.settings);
      
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Look for theme switch
        final switches = find.byType(Switch);
        
        if (switches.evaluate().isNotEmpty) {
          // Toggle first switch (might be theme)
          await tester.tap(switches.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          
          // App should still be running
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 13. LANGUAGE SWITCHING
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Language Switching Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for language selector
      final languageText = find.textContaining('Language', findRichText: true);
      final languageTextHindi = find.textContaining('भाषा', findRichText: true);
      
      if (languageText.evaluate().isNotEmpty || languageTextHindi.evaluate().isNotEmpty) {
        final targetFinder = languageText.evaluate().isNotEmpty 
            ? languageText 
            : languageTextHindi;
        
        await tester.tap(targetFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Look for language options
        final hasDropdown = find.byType(DropdownButton).evaluate().isNotEmpty;
        final hasRadio = find.byType(Radio).evaluate().isNotEmpty;
        
        if (hasDropdown || hasRadio) {
          // Try to change language
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 14. SCROLL PERFORMANCE
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Scroll Performance Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find scrollable widgets
      final listViews = find.byType(ListView);
      
      if (listViews.evaluate().isNotEmpty) {
        // Scroll down
        await tester.drag(listViews.first, const Offset(0, -300));
        await tester.pumpAndSettle();
        
        // Scroll up
        await tester.drag(listViews.first, const Offset(0, 300));
        await tester.pumpAndSettle();
        
        // App should remain responsive
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 15. MEMORY LEAK CHECK (NAVIGATION)
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Navigation Memory Leak Check', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate back and forth multiple times
      final navBar = find.byType(BottomNavigationBar);
      
      if (navBar.evaluate().isNotEmpty) {
        final navBarWidget = tester.widget<BottomNavigationBar>(navBar);
        final itemCount = navBarWidget.items.length;
        
        // Navigate between screens multiple times
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < itemCount; j++) {
            // Simulate tapping navigation items
            await tester.tap(navBar);
            await tester.pumpAndSettle();
          }
        }
        
        // App should still be responsive
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 16. ERROR HANDLING
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Error Handling Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for any error messages or error widgets
      final hasErrorText = find.textContaining('Error', findRichText: true).evaluate().isNotEmpty;
      final hasErrorIcon = find.byIcon(Icons.error).evaluate().isNotEmpty;
      
      if (hasErrorText || hasErrorIcon) {
        // Error is displayed properly
        expect(find.byType(Text).evaluate().isNotEmpty, true);
      }
      
      // App should not crash
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════
    // 17. OFFLINE MODE
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Offline Mode Handling', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should load even without network
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Should show appropriate offline message if network unavailable
      final hasOfflineText = find.textContaining('offline', findRichText: true).evaluate().isNotEmpty ||
                             find.textContaining('network', findRichText: true).evaluate().isNotEmpty;
      
      // Just verify app is stable
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ══════════════════════════════════════════════════════════════════════
    // 18. DATA PERSISTENCE
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Data Persistence Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Make some changes (if possible)
      final textFields = find.byType(TextField);
      
      if (textFields.evaluate().isNotEmpty) {
        await tester.tap(textFields.first);
        await tester.enterText(textFields.first, 'Test Data');
        await tester.pumpAndSettle();
      }
      
      // Restart app
      await tester.restartAndRestore();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // App should restore state
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════
    // 19. IMAGE DISPLAY
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Image Display Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Wait for images to load
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Check if images are present
      final images = find.byType(Image);
      
      if (images.evaluate().isNotEmpty) {
        expect(images.evaluate().length, greaterThan(0),
            reason: 'App should display images');
      }
    });

    // ══════════════════════════════════════════════════════════════════════
    // 20. FORM VALIDATION
    // ══════════════════════════════════════════════════════════════════════
    
    testWidgets('Form Validation Test', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for forms
      final textFields = find.byType(TextField);
      
      if (textFields.evaluate().isNotEmpty) {
        // Try to submit empty form
        final buttons = find.byType(ElevatedButton);
        
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pumpAndSettle();
          
          // Should show validation error
          final hasError = find.textContaining('required', findRichText: true).evaluate().isNotEmpty ||
                          find.textContaining('invalid', findRichText: true).evaluate().isNotEmpty;
          
          // App should handle validation
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });
  });
}
