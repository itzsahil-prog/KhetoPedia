/// User settings domain model.
final class UserSettings {
  const UserSettings({
    required this.notificationsCrop,
    required this.notificationsSoil,
    required this.notificationsAlerts,
    required this.notificationsAI,
    this.themeMode,
    this.fontSize,
  });

  final bool    notificationsCrop;
  final bool    notificationsSoil;
  final bool    notificationsAlerts;
  final bool    notificationsAI;
  final String? themeMode;    // light, dark, system
  final String? fontSize;     // small, medium, large

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsCrop:   json['notifications_crop'] as bool? ?? true,
      notificationsSoil:   json['notifications_soil'] as bool? ?? true,
      notificationsAlerts: json['notifications_alerts'] as bool? ?? true,
      notificationsAI:     json['notifications_ai'] as bool? ?? true,
      themeMode:           json['theme_mode'] as String?,
      fontSize:            json['font_size'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'notifications_crop':   notificationsCrop,
    'notifications_soil':   notificationsSoil,
    'notifications_alerts': notificationsAlerts,
    'notifications_ai':     notificationsAI,
    if (themeMode != null) 'theme_mode': themeMode,
    if (fontSize != null)  'font_size':  fontSize,
  };

  UserSettings copyWith({
    bool?   notificationsCrop,
    bool?   notificationsSoil,
    bool?   notificationsAlerts,
    bool?   notificationsAI,
    String? themeMode,
    String? fontSize,
  }) {
    return UserSettings(
      notificationsCrop:   notificationsCrop ?? this.notificationsCrop,
      notificationsSoil:   notificationsSoil ?? this.notificationsSoil,
      notificationsAlerts: notificationsAlerts ?? this.notificationsAlerts,
      notificationsAI:     notificationsAI ?? this.notificationsAI,
      themeMode:           themeMode ?? this.themeMode,
      fontSize:            fontSize ?? this.fontSize,
    );
  }
}
