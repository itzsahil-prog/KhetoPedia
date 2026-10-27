import 'app_localizations.dart';

class StringsHi extends AppStrings {
  const StringsHi();

  // ── General ───────────────────────────────────────────────────────────────
  @override String get appName      => 'खेतोपीडिया';
  @override String get tabHome      => 'होम';
  @override String get tabScan      => 'स्कैन';
  @override String get tabFields    => 'खेत';
  @override String get tabSoil      => 'मिट्टी';
  @override String get tabAI        => 'AI';
  @override String get loading      => 'लोड हो रहा है…';
  @override String get retry        => 'पुनः प्रयास करें';
  @override String get errorGeneric => 'कुछ गलत हुआ। कृपया पुनः प्रयास करें।';
  @override String get emptyGeneric => 'यहाँ अभी कुछ नहीं है।';
  @override String get cancel       => 'रद्द करें';
  @override String get confirm      => 'पुष्टि करें';
  @override String get save         => 'सहेजें';
  @override String get delete       => 'हटाएं';
  @override String get search       => 'खोजें';
  @override String get settings     => 'सेटिंग्स';
  @override String get theme        => 'थीम';
  @override String get language     => 'भाषा';
  @override String get themeLight   => 'लाइट';
  @override String get themeDark    => 'डार्क';
  @override String get themeSystem  => 'सिस्टम';

  // ── Auth ──────────────────────────────────────────────────────────────────
  @override String get authLogin               => 'साइन इन';
  @override String get authSignUp              => 'खाता बनाएं';
  @override String get authLogout              => 'साइन आउट';
  @override String get authEmail               => 'ईमेल पता';
  @override String get authEmailHint           => 'aap@example.com';
  @override String get authPassword            => 'पासवर्ड';
  @override String get authPasswordHint        => 'अपना पासवर्ड दर्ज करें';
  @override String get authConfirmPassword     => 'पासवर्ड की पुष्टि करें';
  @override String get authConfirmPasswordHint => 'पासवर्ड दोबारा दर्ज करें';
  @override String get authFullName            => 'पूरा नाम';
  @override String get authFullNameHint        => 'राजेश कुमार';
  @override String get authPhone               => 'मोबाइल नंबर (वैकल्पिक)';
  @override String get authPhoneHint           => '+91 98765 43210';
  @override String get authForgotPassword      => 'पासवर्ड भूल गए?';
  @override String get authForgotPasswordTitle => 'पासवर्ड रीसेट करें';
  @override String get authForgotPasswordBody  =>
      'अपना पंजीकृत ईमेल दर्ज करें, हम आपको एक सत्यापन कोड भेजेंगे।';
  @override String get authSendOtp             => 'कोड भेजें';
  @override String get authOtpTitle            => 'ईमेल सत्यापित करें';
  @override String get authOtpBody             => 'इस पर भेजा गया 6 अंकों का कोड दर्ज करें';
  @override String get authOtpHint             => '• • • • • •';
  @override String get authVerify              => 'सत्यापित करें';
  @override String get authResendOtp           => 'कोड फिर भेजें';
  @override String get authResendOtpIn         => 'में पुनः भेजें';
  @override String get authNewPassword         => 'नया पासवर्ड';
  @override String get authNewPasswordHint     => 'कम से कम 8 अक्षर';
  @override String get authResetPassword       => 'नया पासवर्ड सेट करें';
  @override String get authResetPasswordTitle  => 'नया पासवर्ड बनाएं';
  @override String get authNoAccount           => 'खाता नहीं है? ';
  @override String get authHaveAccount         => 'पहले से खाता है? ';
  @override String get authWelcomeBack         => 'वापस आने पर स्वागत है';
  @override String get authCreateAccount       => 'खेतोपीडिया से जुड़ें';
  @override String get authAgreeToTerms        => 'जारी रखने पर आप हमारी ';
  @override String get authTermsOfService      => 'सेवा की शर्तें';
  @override String get authPrivacyPolicy       => ' और गोपनीयता नीति से सहमत हैं';
  @override String get authPasswordsDoNotMatch => 'पासवर्ड मेल नहीं खाते।';
  @override String get authPasswordTooShort    => 'पासवर्ड कम से कम 8 अक्षरों का होना चाहिए।';
  @override String get authInvalidEmail        => 'मान्य ईमेल पता दर्ज करें।';
  @override String get authFieldRequired       => 'यह फ़ील्ड आवश्यक है।';
  @override String get authOtpSentTo           => 'कोड भेजा गया ';
  @override String get authSessionExpired      => 'सत्र समाप्त हो गया। कृपया पुनः साइन इन करें।';
  @override String get authShowPassword        => 'पासवर्ड दिखाएं';
  @override String get authHidePassword        => 'पासवर्ड छुपाएं';
  @override String get authOrContinueWith      => 'या इससे जारी रखें';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  @override String get dashboardTitle               => 'डैशबोर्ड';
  @override String get dashboardGreetingMorning     => 'सुप्रभात';
  @override String get dashboardGreetingAfternoon   => 'नमस्ते';
  @override String get dashboardGreetingEvening     => 'शुभ संध्या';
  @override String get dashboardSectionStats        => 'खेत सारांश';
  @override String get dashboardSectionAlerts       => 'सक्रिय सतर्कताएं';
  @override String get dashboardSectionRecentFields => 'हाल के खेत';
  @override String get dashboardAlertsEmpty         => 'कोई सक्रिय सतर्कता नहीं। आपके खेत ठीक हैं!';
  @override String get dashboardFieldsEmpty         => 'अभी तक कोई खेत नहीं है। शुरू करने के लिए पहला खेत जोड़ें।';
  @override String get dashboardStatsEmpty          => 'सारांश डेटा उपलब्ध नहीं है।';
  @override String get dashboardRefresh             => 'रीफ्रेश करें';
  @override String get dashboardAlertSeverityInfo   => 'जानकारी';
  @override String get dashboardAlertSeverityWarning => 'चेतावनी';
  @override String get dashboardAlertSeverityCritical => 'गंभीर';
  @override String get dashboardFieldHealthScore    => 'स्वास्थ्य';
  @override String get dashboardFieldLastScanned    => 'स्कैन किया';
  @override String get dashboardFieldNeverScanned   => 'अभी स्कैन नहीं हुआ';
  @override String get dashboardFieldAreaHectares   => 'हे.';
  @override String get dashboardSeeAllAlerts        => 'सभी सतर्कताएं देखें';
  @override String get dashboardSeeAllFields        => 'सभी खेत देखें';
  @override String get dashboardStatusHealthy       => 'स्वस्थ';
  @override String get dashboardStatusAtRisk        => 'खतरे में';
  @override String get dashboardStatusCritical      => 'गंभीर';
}
