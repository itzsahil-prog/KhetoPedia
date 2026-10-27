import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/settings_provider.dart';

/// Settings screen for app preferences and notifications.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settings),
      ),
      body: settingsAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: l.errorGeneric,
          onRetry: () => ref.invalidate(settingsProvider),
        ),
        data: (settings) => ListView(
          children: [
            // Appearance Section
            _SectionHeader(title: l.settingsAppearance),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l.theme),
              subtitle: Text(_getThemeLabel(themeMode, l)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context, ref, l),
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l.language),
              subtitle: Text(locale.languageCode == 'hi' ? 'हिन्दी' : 'English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, ref, l),
            ),
            const Divider(),

            // Notifications Section
            _SectionHeader(title: l.settingsNotifications),
            SwitchListTile(
              secondary: const Icon(Icons.center_focus_strong_outlined),
              title: Text(l.settingsNotificationsCrop),
              value: settings.notificationsCrop,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotification('crop', value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.science_outlined),
              title: Text(l.settingsNotificationsSoil),
              value: settings.notificationsSoil,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotification('soil', value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.warning_outlined),
              title: Text(l.settingsNotificationsAlerts),
              value: settings.notificationsAlerts,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotification('alerts', value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.psychology_outlined),
              title: Text(l.settingsNotificationsAI),
              value: settings.notificationsAI,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotification('ai', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode, AppLocalizations l) {
    return switch (mode) {
      ThemeMode.light  => l.themeLight,
      ThemeMode.dark   => l.themeDark,
      ThemeMode.system => l.themeSystem,
    };
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l.themeLight),
              value: ThemeMode.light,
              groupValue: ref.read(themeProvider),
              onChanged: (_) {
                ref.read(themeProvider.notifier).setLight();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l.themeDark),
              value: ThemeMode.dark,
              groupValue: ref.read(themeProvider),
              onChanged: (_) {
                ref.read(themeProvider.notifier).setDark();
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l.themeSystem),
              value: ThemeMode.system,
              groupValue: ref.read(themeProvider),
              onChanged: (_) {
                ref.read(themeProvider.notifier).setSystem();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: ref.read(localeProvider).languageCode,
              onChanged: (_) {
                ref.read(localeProvider.notifier).setLanguageCode('en');
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी'),
              value: 'hi',
              groupValue: ref.read(localeProvider).languageCode,
              onChanged: (_) {
                ref.read(localeProvider.notifier).setLanguageCode('hi');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
