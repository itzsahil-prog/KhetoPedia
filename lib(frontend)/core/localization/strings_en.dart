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

  // ── Profile ───────────────────────────────────────────────────────────────
  @override String get profile                  => 'Profile';
  @override String get profileName              => 'Name';
  @override String get profileEmail             => 'Email';
  @override String get profilePhone             => 'Phone';
  @override String get profileLocation          => 'Location';
  @override String get profilePreferredLocale   => 'Preferred Language';
  @override String get profileEdit              => 'Edit Profile';
  @override String get profileSaved             => 'Profile updated successfully';
  @override String get profileChangePassword    => 'Change Password';
  @override String get profileCurrentPassword   => 'Current Password';
  @override String get profileNewPassword       => 'New Password';
  @override String get profilePasswordChanged   => 'Password changed successfully';

  // ── Settings ──────────────────────────────────────────────────────────────
  @override String get settingsNotifications       => 'Notifications';
  @override String get settingsNotificationsCrop   => 'Crop Scan Alerts';
  @override String get settingsNotificationsSoil   => 'Soil Test Alerts';
  @override String get settingsNotificationsAlerts => 'Field Alerts';
  @override String get settingsNotificationsAI     => 'AI Recommendations';
  @override String get settingsAppearance          => 'Appearance';
  @override String get settingsFontSize            => 'Font Size';
  @override String get settingsFontSmall           => 'Small';
  @override String get settingsFontMedium          => 'Medium';
  @override String get settingsFontLarge           => 'Large';

  // ── Crop Scanner ──────────────────────────────────────────────────────────
  @override String get scanTitle                => 'Crop Scanner';
  @override String get scanTakePhoto            => 'Take Photo';
  @override String get scanUploadPhoto          => 'Upload from Gallery';
  @override String get scanAnalyzing            => 'Analyzing image...';
  @override String get scanHistory              => 'Scan History';
  @override String get scanHistoryEmpty         => 'No scans yet. Upload a crop image to begin.';
  @override String get scanCropDetected         => 'Crop Detected';
  @override String get scanDiseaseDetected      => 'Disease Detected';
  @override String get scanHealthy              => 'Healthy';
  @override String get scanConfidence           => 'Confidence';
  @override String get scanRecommendations      => 'Recommendations';
  @override String get scanSelectField          => 'Select Field (Optional)';

  // ── Soil Analysis ─────────────────────────────────────────────────────────
  @override String get soilTitle             => 'Soil Analysis';
  @override String get soilNewTest           => 'New Test';
  @override String get soilHistory           => 'Test History';
  @override String get soilHistoryEmpty      => 'No soil tests yet. Submit your first test result.';
  @override String get soilPH                => 'pH Level';
  @override String get soilMoisture          => 'Moisture';
  @override String get soilNitrogen          => 'Nitrogen (N)';
  @override String get soilPhosphorus        => 'Phosphorus (P)';
  @override String get soilPotassium         => 'Potassium (K)';
  @override String get soilEC                => 'EC (Salinity)';
  @override String get soilSummary           => 'Soil Summary';
  @override String get soilTrends            => 'Trends';
  @override String get soilStatusLow         => 'Low';
  @override String get soilStatusAdequate    => 'Adequate';
  @override String get soilStatusHigh        => 'High';

  // ── Fields Management ─────────────────────────────────────────────────────
  @override String get fieldsTitle           => 'My Fields';
  @override String get fieldsEmpty           => 'No fields yet. Add your first field.';
  @override String get fieldsAdd             => 'Add Field';
  @override String get fieldsName            => 'Field Name';
  @override String get fieldsCrop            => 'Crop';
  @override String get fieldsArea            => 'Area (hectares)';
  @override String get fieldsHealthScore     => 'Health Score';
  @override String get fieldsLastScanned     => 'Last Scanned';
  @override String get fieldsDetail          => 'Field Details';
  @override String get fieldsEdit            => 'Edit';
  @override String get fieldsDelete          => 'Delete';
  @override String get fieldsDeleteConfirm   => 'Are you sure you want to delete this field?';
  @override String get fieldsSaved           => 'Field saved successfully';
  @override String get fieldsDeleted         => 'Field deleted successfully';

  // ── Recommendations ───────────────────────────────────────────────────────
  @override String get recsTitle                => 'Recommendations';
  @override String get recsEmpty                => 'No recommendations yet.';
  @override String get recsIrrigation           => 'Irrigation';
  @override String get recsFertilizer           => 'Fertilizer';
  @override String get recsDiseaseManagement    => 'Disease Management';
  @override String get recsGenerate             => 'Generate Recommendations';

  // ── AI Assistant ──────────────────────────────────────────────────────────
  @override String get aiTitle               => 'AI Assistant';
  @override String get aiWelcome             => 'Hello! I\'m your agricultural assistant. How can I help you today?';
  @override String get aiTypeMessage         => 'Type your question...';
  @override String get aiSend                => 'Send';
  @override String get aiThinking            => 'Thinking...';
  @override String get aiNewConversation     => 'New Conversation';
  @override String get aiHistory             => 'Conversation History';
  @override String get aiHistoryEmpty        => 'No conversations yet.';

  // ── Weather ───────────────────────────────────────────────────────────────
  @override String get weatherTitle          => 'Weather';
  @override String get weatherTemperature    => 'Temperature';
  @override String get weatherHumidity       => 'Humidity';
  @override String get weatherWind           => 'Wind';
  @override String get weatherRain           => 'Rain';
  @override String get weatherForecast       => 'Forecast';
}
