import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_tokens.dart';

// ── Storage keys ──────────────────────────────────────────────────────────────
const _kAccessToken           = 'auth.access_token';
const _kRefreshToken          = 'auth.refresh_token';
const _kAccessTokenExpiresAt  = 'auth.access_token_expires_at';
const _kRefreshTokenExpiresAt = 'auth.refresh_token_expires_at';

// ── Abstract interface ────────────────────────────────────────────────────────

/// Contract for persisting and retrieving auth tokens.
///
/// Abstracted so tests can inject an in-memory implementation and so
/// the storage backend can be swapped (e.g. SharedPreferences for web).
abstract interface class TokenStorage {
  /// Persist [tokens] to durable storage.
  Future<void> save(AuthTokens tokens);

  /// Load previously saved tokens, or `null` if none are stored.
  Future<AuthTokens?> load();

  /// Delete all stored tokens.
  Future<void> clear();
}

// ── Secure (device keychain / keystore) implementation ───────────────────────

/// Stores tokens in the platform keychain (iOS) / keystore (Android)
/// via [flutter_secure_storage].
///
/// Each token field is stored as a separate key so partial updates
/// (e.g. after a token refresh) are possible without a full read-modify-write.
final class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  // ── Android options: use EncryptedSharedPreferences ──────────────────────
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  // ── iOS options: accessible only when device is unlocked ─────────────────
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  @override
  Future<void> save(AuthTokens tokens) async {
    await Future.wait([
      _write(_kAccessToken,  tokens.accessToken),
      _write(_kRefreshToken, tokens.refreshToken),
      if (tokens.accessTokenExpiresAt != null)
        _write(_kAccessTokenExpiresAt,  tokens.accessTokenExpiresAt!.toIso8601String()),
      if (tokens.refreshTokenExpiresAt != null)
        _write(_kRefreshTokenExpiresAt, tokens.refreshTokenExpiresAt!.toIso8601String()),
    ]);
  }

  @override
  Future<AuthTokens?> load() async {
    final results = await Future.wait([
      _read(_kAccessToken),
      _read(_kRefreshToken),
      _read(_kAccessTokenExpiresAt),
      _read(_kRefreshTokenExpiresAt),
    ]);

    final access  = results[0];
    final refresh = results[1];

    // If either principal token is missing, treat as "no session".
    if (access == null || refresh == null) return null;

    return AuthTokens(
      accessToken:           access,
      refreshToken:          refresh,
      accessTokenExpiresAt:  _parseDate(results[2]),
      refreshTokenExpiresAt: _parseDate(results[3]),
    );
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _delete(_kAccessToken),
      _delete(_kRefreshToken),
      _delete(_kAccessTokenExpiresAt),
      _delete(_kRefreshTokenExpiresAt),
    ]);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _write(String key, String value) => _storage.write(
        key:            key,
        value:          value,
        aOptions:       _androidOptions,
        iOptions:       _iosOptions,
      );

  Future<String?> _read(String key) => _storage.read(
        key:      key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

  Future<void> _delete(String key) => _storage.delete(
        key:      key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

  static DateTime? _parseDate(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value)?.toUtc();
  }
}

// ── In-memory implementation (for tests) ─────────────────────────────────────

/// Non-persistent implementation backed by a plain map.
/// Use this in widget tests and unit tests to avoid platform channel calls.
final class InMemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  @override
  Future<void> save(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<AuthTokens?> load() async => _tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
