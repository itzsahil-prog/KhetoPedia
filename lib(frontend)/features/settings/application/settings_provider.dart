import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network.dart';
import '../data/settings_repository.dart';
import '../domain/user_settings.dart';

/// Provides [SettingsRepository] instance.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  return SettingsRepository(dio);
});

/// Settings state notifier.
class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    return _repo.getSettings();
  }

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  /// Update settings.
  Future<void> updateSettings({
    bool?   notificationsCrop,
    bool?   notificationsSoil,
    bool?   notificationsAlerts,
    bool?   notificationsAI,
    String? themeMode,
    String? fontSize,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final request = SettingsUpdateRequest(
        notificationsCrop:   notificationsCrop,
        notificationsSoil:   notificationsSoil,
        notificationsAlerts: notificationsAlerts,
        notificationsAI:     notificationsAI,
        themeMode:           themeMode,
        fontSize:            fontSize,
      );
      return _repo.updateSettings(request);
    });
  }

  /// Toggle a notification setting.
  Future<void> toggleNotification(String type, bool value) async {
    final current = state.value;
    if (current == null) return;

    switch (type) {
      case 'crop':
        await updateSettings(notificationsCrop: value);
      case 'soil':
        await updateSettings(notificationsSoil: value);
      case 'alerts':
        await updateSettings(notificationsAlerts: value);
      case 'ai':
        await updateSettings(notificationsAI: value);
    }
  }
}

/// Global settings provider.
final settingsProvider = AsyncNotifierProvider<SettingsNotifier, UserSettings>(
  SettingsNotifier.new,
);
