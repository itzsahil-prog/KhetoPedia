import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/localization.dart';

/// Drives the active [Locale] across the app.
///
/// Supported locales are declared in [AppLocalizations.supportedLocales].
/// Persisting preference to disk is a future phase; state resets on cold start.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en'); // English by default

  void setLocale(Locale locale) {
    assert(
      AppLocalizations.supportedLocales.contains(locale),
      'Locale $locale is not in AppLocalizations.supportedLocales',
    );
    state = locale;
  }

  void setLanguageCode(String code) =>
      setLocale(AppLocalizations.supportedLocales.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => const Locale('en'),
      ));
}

/// Global provider — watch this in [MaterialApp.router] locale.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
