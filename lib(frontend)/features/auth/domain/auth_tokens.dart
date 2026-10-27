import 'package:flutter/foundation.dart';

/// Holds the access + refresh token pair returned by the server.
///
/// Designed as an immutable value type — no codegen required.
@immutable
final class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  final String   accessToken;
  final String   refreshToken;
  /// UTC timestamp when the access token expires, if provided by the server.
  final DateTime? accessTokenExpiresAt;
  /// UTC timestamp when the refresh token expires, if provided by the server.
  final DateTime? refreshTokenExpiresAt;

  // ── JSON ────────────────────────────────────────────────────────────────

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken:  json['access_token']  as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiresAt: _parseDate(json['access_token_expires_at']),
      refreshTokenExpiresAt: _parseDate(json['refresh_token_expires_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token':              accessToken,
    'refresh_token':             refreshToken,
    if (accessTokenExpiresAt  != null)
      'access_token_expires_at':  accessTokenExpiresAt!.toIso8601String(),
    if (refreshTokenExpiresAt != null)
      'refresh_token_expires_at': refreshTokenExpiresAt!.toIso8601String(),
  };

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns true if the access token has a known expiry and it has passed.
  bool get isAccessTokenExpired {
    final exp = accessTokenExpiresAt;
    return exp != null && DateTime.now().toUtc().isAfter(exp);
  }

  AuthTokens copyWith({
    String?   accessToken,
    String?   refreshToken,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) {
    return AuthTokens(
      accessToken:           accessToken           ?? this.accessToken,
      refreshToken:          refreshToken          ?? this.refreshToken,
      accessTokenExpiresAt:  accessTokenExpiresAt  ?? this.accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokens &&
          other.accessToken            == accessToken &&
          other.refreshToken           == refreshToken &&
          other.accessTokenExpiresAt   == accessTokenExpiresAt &&
          other.refreshTokenExpiresAt  == refreshTokenExpiresAt;

  @override
  int get hashCode => Object.hash(
        accessToken, refreshToken,
        accessTokenExpiresAt, refreshTokenExpiresAt,
      );

  @override
  String toString() =>
      'AuthTokens(accessToken: [redacted], refreshToken: [redacted])';

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }
}
