import 'package:flutter/foundation.dart';

/// Authenticated user profile returned from `/auth/me`.
@immutable
final class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.preferredLocale = 'en',
    this.createdAt,
  });

  final String  id;
  final String  email;
  final String  name;
  final String? phone;
  final String? avatarUrl;
  final bool    isEmailVerified;
  final String  preferredLocale;
  final DateTime? createdAt;

  // ── JSON ─────────────────────────────────────────────────────────────────

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id:               json['id']                as String,
      email:            json['email']             as String,
      name:             json['name']              as String,
      phone:            json['phone']             as String?,
      avatarUrl:        json['avatar_url']        as String?,
      isEmailVerified:  (json['is_email_verified'] as bool?) ?? false,
      preferredLocale:  (json['preferred_locale'] as String?) ?? 'en',
      createdAt:        _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                id,
    'email':             email,
    'name':              name,
    if (phone      != null) 'phone':       phone,
    if (avatarUrl  != null) 'avatar_url':  avatarUrl,
    'is_email_verified': isEmailVerified,
    'preferred_locale':  preferredLocale,
    if (createdAt  != null) 'created_at':  createdAt!.toIso8601String(),
  };

  AuthUser copyWith({
    String?   id,
    String?   email,
    String?   name,
    String?   phone,
    String?   avatarUrl,
    bool?     isEmailVerified,
    String?   preferredLocale,
    DateTime? createdAt,
  }) {
    return AuthUser(
      id:              id              ?? this.id,
      email:           email           ?? this.email,
      name:            name            ?? this.name,
      phone:           phone           ?? this.phone,
      avatarUrl:       avatarUrl       ?? this.avatarUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferredLocale: preferredLocale ?? this.preferredLocale,
      createdAt:       createdAt       ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          other.id              == id &&
          other.email           == email &&
          other.name            == name &&
          other.phone           == phone &&
          other.avatarUrl       == avatarUrl &&
          other.isEmailVerified == isEmailVerified &&
          other.preferredLocale == preferredLocale &&
          other.createdAt       == createdAt;

  @override
  int get hashCode => Object.hash(
        id, email, name, phone,
        avatarUrl, isEmailVerified, preferredLocale, createdAt,
      );

  @override
  String toString() => 'AuthUser(id: $id, email: $email, name: $name)';

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }
}
