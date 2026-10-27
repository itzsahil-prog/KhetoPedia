import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives [ThemeMode] across the app.
///
/// Persisting preference to disk is a future phase; state resets on cold start.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system; // sane default: follow OS

  void setLight()  => state = ThemeMode.light;
  void setDark()   => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;

  void cycle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light  => ThemeMode.dark,
      ThemeMode.dark   => ThemeMode.system,
    };
  }

  String labelFor(ThemeMode mode) => switch (mode) {
    ThemeMode.light  => 'Light',
    ThemeMode.dark   => 'Dark',
    ThemeMode.system => 'System',
  };
}

/// Global provider — watch this in [MaterialApp.router] themeMode.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
