import 'package:dio/dio.dart';

import '../../../core/network/network.dart';
import '../domain/user_settings.dart';

/// Settings update request DTO.
final class SettingsUpdateRequest {
  const SettingsUpdateRequest({
    this.notificationsCrop,
    this.notificationsSoil,
    this.notificationsAlerts,
    this.notificationsAI,
    this.themeMode,
    this.fontSize,
  });

  final bool?   notificationsCrop;
  final bool?   notificationsSoil;
  final bool?   notificationsAlerts;
  final bool?   notificationsAI;
  final String? themeMode;
  final String? fontSize;

  Map<String, dynamic> toJson() => {
    if (notificationsCrop != null)   'notifications_crop':   notificationsCrop,
    if (notificationsSoil != null)   'notifications_soil':   notificationsSoil,
    if (notificationsAlerts != null) 'notifications_alerts': notificationsAlerts,
    if (notificationsAI != null)     'notifications_ai':     notificationsAI,
    if (themeMode != null)           'theme_mode':           themeMode,
    if (fontSize != null)            'font_size':            fontSize,
  };
}

/// Settings repository for user preferences.
class SettingsRepository {
  const SettingsRepository(this._dio);

  final Dio _dio;

  /// Fetch user settings.
  Future<UserSettings> getSettings() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('/users/settings');
      return UserSettings.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }

  /// Update user settings.
  Future<UserSettings> updateSettings(SettingsUpdateRequest request) async {
    try {
      final resp = await _dio.put<Map<String, dynamic>>(
        '/users/settings',
        data: request.toJson(),
      );
      return UserSettings.fromJson(resp.data!);
    } on DioException catch (e) {
      throw DioClient.mapException(e);
    }
  }
}
