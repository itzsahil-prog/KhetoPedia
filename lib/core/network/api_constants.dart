/// Central place for API configuration.
///
/// Override [baseUrl] via a compile-time `--dart-define=API_BASE_URL=...`
/// so the same binary can target different environments without rebuilds.
abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.khetopedia.com/v1',
  );

  // ── Timeouts ─────────────────────────────────────────────────────────────
  static const connectTimeoutMs = 10000;
  static const receiveTimeoutMs = 30000;

  // ── Dashboard endpoints ───────────────────────────────────────────────────
  /// GET  /dashboard/summary   — aggregated stats, recent fields, active alerts
  static const dashboardSummary   = '/dashboard/summary';
  /// GET  /dashboard/alerts    — paginated alert list
  static const dashboardAlerts    = '/dashboard/alerts';

  // ── Auth endpoints ────────────────────────────────────────────────────────
  static const authLogin          = '/auth/login';
  static const authSignup         = '/auth/signup';
  static const authLogout         = '/auth/logout';
  static const authRefresh        = '/auth/refresh';
  static const authForgotPassword = '/auth/forgot-password';
  static const authVerifyOtp      = '/auth/verify-otp';
  static const authResetPassword  = '/auth/reset-password';
  static const authMe             = '/auth/me';
}
