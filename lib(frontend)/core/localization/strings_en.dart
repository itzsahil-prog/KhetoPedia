import 'app_localizations.dart';

class StringsEn extends AppStrings {
  const StringsEn();

  // ── General ───────────────────────────────────────────────────────────────
  @override String get appName      => 'Khetopedia';
  @override String get tabHome      => 'Home';
  @override String get tabScan      => 'Scan';
  @override String get tabFields    => 'Fields';
  @override String get tabSoil      => 'Soil';
  @override String get tabAI        => 'AI';
  @override String get loading      => 'Loading…';
  @override String get retry        => 'Retry';
  @override String get errorGeneric => 'Something went wrong. Please try again.';
  @override String get emptyGeneric => 'Nothing here yet.';
  @override String get cancel       => 'Cancel';
  @override String get confirm      => 'Confirm';
  @override String get save         => 'Save';
  @override String get delete       => 'Delete';
  @override String get search       => 'Search';
  @override String get settings     => 'Settings';
  @override String get theme        => 'Theme';
  @override String get language     => 'Language';
  @override String get themeLight   => 'Light';
  @override String get themeDark    => 'Dark';
  @override String get themeSystem  => 'System';

  // ── Auth ──────────────────────────────────────────────────────────────────
  @override String get authLogin               => 'Sign In';
  @override String get authSignUp              => 'Create Account';
  @override String get authLogout              => 'Sign Out';
  @override String get authEmail               => 'Email address';
  @override String get authEmailHint           => 'you@example.com';
  @override String get authPassword            => 'Password';
  @override String get authPasswordHint        => 'Enter your password';
  @override String get authConfirmPassword     => 'Confirm password';
  @override String get authConfirmPasswordHint => 'Re-enter your password';
  @override String get authFullName            => 'Full name';
  @override String get authFullNameHint        => 'Rajesh Kumar';
  @override String get authPhone               => 'Mobile number (optional)';
  @override String get authPhoneHint           => '+91 98765 43210';
  @override String get authForgotPassword      => 'Forgot password?';
  @override String get authForgotPasswordTitle => 'Reset password';
  @override String get authForgotPasswordBody  =>
      'Enter your registered email and we will send you a verification code.';
  @override String get authSendOtp             => 'Send code';
  @override String get authOtpTitle            => 'Verify your email';
  @override String get authOtpBody             => 'Enter the 6-digit code sent to';
  @override String get authOtpHint             => '• • • • • •';
  @override String get authVerify              => 'Verify';
  @override String get authResendOtp           => 'Resend code';
  @override String get authResendOtpIn         => 'Resend in';
  @override String get authNewPassword         => 'New password';
  @override String get authNewPasswordHint     => 'At least 8 characters';
  @override String get authResetPassword       => 'Set new password';
  @override String get authResetPasswordTitle  => 'Create new password';
  @override String get authNoAccount           => "Don't have an account? ";
  @override String get authHaveAccount         => 'Already have an account? ';
  @override String get authWelcomeBack         => 'Welcome back';
  @override String get authCreateAccount       => 'Join Khetopedia';
  @override String get authAgreeToTerms        => 'By continuing, you agree to our ';
  @override String get authTermsOfService      => 'Terms of Service';
  @override String get authPrivacyPolicy       => ' and Privacy Policy';
  @override String get authPasswordsDoNotMatch => 'Passwords do not match.';
  @override String get authPasswordTooShort    => 'Password must be at least 8 characters.';
  @override String get authInvalidEmail        => 'Enter a valid email address.';
  @override String get authFieldRequired       => 'This field is required.';
  @override String get authOtpSentTo           => 'Code sent to ';
  @override String get authSessionExpired      => 'Your session expired. Please sign in again.';
  @override String get authShowPassword        => 'Show password';
  @override String get authHidePassword        => 'Hide password';
  @override String get authOrContinueWith      => 'or continue with';
  
  // ── Dashboard ─────────────────────────────────────────────────────────────
  @override String get dashboardTitle               => 'Dashboard';
  @override String get dashboardGreetingMorning     => 'Good morning';
  @override String get dashboardGreetingAfternoon   => 'Good afternoon';
  @override String get dashboardGreetingEvening     => 'Good evening';
  @override String get dashboardSectionStats        => 'Farm Overview';
  @override String get dashboardSectionAlerts       => 'Active Alerts';
  @override String get dashboardSectionRecentFields => 'Recent Fields';
  @override String get dashboardAlertsEmpty         => 'No active alerts. Your farm is looking good!';
  @override String get dashboardFieldsEmpty         => 'No fields yet. Add your first field to get started.';
  @override String get dashboardStatsEmpty          => 'Overview data unavailable.';
  @override String get dashboardRefresh             => 'Refresh';
  @override String get dashboardAlertSeverityInfo   => 'Info';
  @override String get dashboardAlertSeverityWarning => 'Warning';
  @override String get dashboardAlertSeverityCritical => 'Critical';
  @override String get dashboardFieldHealthScore    => 'Health';
  @override String get dashboardFieldLastScanned    => 'Scanned';
  @override String get dashboardFieldNeverScanned   => 'Not scanned yet';
  @override String get dashboardFieldAreaHectares   => 'ha';
  @override String get dashboardSeeAllAlerts        => 'See all alerts';
  @override String get dashboardSeeAllFields        => 'See all fields';
  @override String get dashboardStatusHealthy       => 'Healthy';
  @override String get dashboardStatusAtRisk        => 'At Risk';
  @override String get dashboardStatusCritical      => 'Critical';
}
