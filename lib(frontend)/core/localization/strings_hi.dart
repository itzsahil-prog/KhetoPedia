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
  @override String get languageEnglish => 'English';
  @override String get languageHindi   => 'हिन्दी';

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

  // ── Profile ───────────────────────────────────────────────────────────────
  @override String get profile                  => 'प्रोफ़ाइल';
  @override String get profileName              => 'नाम';
  @override String get profileEmail             => 'ईमेल';
  @override String get profilePhone             => 'फ़ोन';
  @override String get profileLocation          => 'स्थान';
  @override String get profilePreferredLocale   => 'पसंदीदा भाषा';
  @override String get profileEdit              => 'प्रोफ़ाइल संपादित करें';
  @override String get profileSaved             => 'प्रोफ़ाइल सफलतापूर्वक अपडेट हुआ';
  @override String get profileChangePassword    => 'पासवर्ड बदलें';
  @override String get profileCurrentPassword   => 'वर्तमान पासवर्ड';
  @override String get profileNewPassword       => 'नया पासवर्ड';
  @override String get profilePasswordChanged   => 'पासवर्ड सफलतापूर्वक बदला गया';

  // ── Settings ──────────────────────────────────────────────────────────────
  @override String get settingsNotifications       => 'सूचनाएं';
  @override String get settingsNotificationsCrop   => 'फसल स्कैन सतर्कता';
  @override String get settingsNotificationsSoil   => 'मिट्टी परीक्षण सतर्कता';
  @override String get settingsNotificationsAlerts => 'खेत सतर्कता';
  @override String get settingsNotificationsAI     => 'AI सिफारिशें';
  @override String get settingsAppearance          => 'रूप';
  @override String get settingsFontSize            => 'फ़ॉन्ट आकार';
  @override String get settingsFontSmall           => 'छोटा';
  @override String get settingsFontMedium          => 'मध्यम';
  @override String get settingsFontLarge           => 'बड़ा';

  // ── Crop Scanner ──────────────────────────────────────────────────────────
  @override String get scanTitle                => 'फसल स्कैनर';
  @override String get scanTakePhoto            => 'फ़ोटो लें';
  @override String get scanUploadPhoto          => 'गैलरी से अपलोड करें';
  @override String get scanAnalyzing            => 'छवि का विश्लेषण हो रहा है...';
  @override String get scanHistory              => 'स्कैन इतिहास';
  @override String get scanHistoryEmpty         => 'अभी तक कोई स्कैन नहीं है। शुरू करने के लिए फसल की छवि अपलोड करें।';
  @override String get scanCropDetected         => 'फसल का पता चला';
  @override String get scanDiseaseDetected      => 'रोग का पता चला';
  @override String get scanHealthy              => 'स्वस्थ';
  @override String get scanConfidence           => 'विश्वास';
  @override String get scanRecommendations      => 'सिफारिशें';
  @override String get scanSelectField          => 'खेत चुनें (वैकल्पिक)';
  @override String get scanInstructions         => 'रोगों का पता लगाने के लिए अपनी फसल की पत्ती की फोटो लें या अपलोड करें';
  @override String get scanPermissionDenied     => 'अनुमति अस्वीकृत';
  @override String get scanError                => 'छवि अपलोड करने में त्रुटि। कृपया पुनः प्रयास करें।';

  // ── Soil Analysis ─────────────────────────────────────────────────────────
  @override String get soilTitle             => 'मिट्टी विश्लेषण';
  @override String get soilNewTest           => 'नया परीक्षण';
  @override String get soilHistory           => 'परीक्षण इतिहास';
  @override String get soilHistoryEmpty      => 'अभी तक कोई मिट्टी परीक्षण नहीं है। अपना पहला परीक्षण परिणाम सबमिट करें।';
  @override String get soilPH                => 'pH स्तर';
  @override String get soilMoisture          => 'नमी';
  @override String get soilNitrogen          => 'नाइट्रोजन (N)';
  @override String get soilPhosphorus        => 'फास्फोरस (P)';
  @override String get soilPotassium         => 'पोटेशियम (K)';
  @override String get soilEC                => 'EC (लवणता)';
  @override String get soilSummary           => 'मिट्टी सारांश';
  @override String get soilTrends            => 'रुझान';
  @override String get soilStatusLow         => 'कम';
  @override String get soilStatusAdequate    => 'पर्याप्त';
  @override String get soilStatusHigh        => 'उच्च';
  @override String get soilTestSubmitted     => 'मिट्टी परीक्षण सफलतापूर्वक सबमिट हुआ';

  // ── Fields Management ─────────────────────────────────────────────────────
  @override String get fieldsTitle           => 'मेरे खेत';
  @override String get fieldsEmpty           => 'अभी तक कोई खेत नहीं है। अपना पहला खेत जोड़ें।';
  @override String get fieldsAdd             => 'खेत जोड़ें';
  @override String get fieldsName            => 'खेत का नाम';
  @override String get fieldsCrop            => 'फसल';
  @override String get fieldsArea            => 'क्षेत्रफल (हेक्टेयर)';
  @override String get fieldsHealthScore     => 'स्वास्थ्य स्कोर';
  @override String get fieldsLastScanned     => 'अंतिम स्कैन';
  @override String get fieldsDetail          => 'खेत विवरण';
  @override String get fieldsEdit            => 'संपादित करें';
  @override String get fieldsDelete          => 'हटाएं';
  @override String get fieldsDeleteConfirm   => 'क्या आप वाकई इस खेत को हटाना चाहते हैं?';
  @override String get fieldsSaved           => 'खेत सफलतापूर्वक सहेजा गया';
  @override String get fieldsDeleted         => 'खेत सफलतापूर्वक हटाया गया';

  // ── Recommendations ───────────────────────────────────────────────────────
  @override String get recsTitle                => 'सिफारिशें';
  @override String get recsEmpty                => 'अभी तक कोई सिफारिश नहीं है।';
  @override String get recsIrrigation           => 'सिंचाई';
  @override String get recsFertilizer           => 'उर्वरक';
  @override String get recsDiseaseManagement    => 'रोग प्रबंधन';
  @override String get recsGenerate             => 'सिफारिशें उत्पन्न करें';

  // ── AI Assistant ──────────────────────────────────────────────────────────
  @override String get aiTitle               => 'AI सहायक';
  @override String get aiWelcome             => 'नमस्ते! मैं आपका कृषि सहायक हूं। आज मैं आपकी कैसे मदद कर सकता हूं?';
  @override String get aiTypeMessage         => 'अपना प्रश्न टाइप करें...';
  @override String get aiSend                => 'भेजें';
  @override String get aiThinking            => 'सोच रहा हूं...';
  @override String get aiNewConversation     => 'नई बातचीत';
  @override String get aiHistory             => 'बातचीत इतिहास';
  @override String get aiHistoryEmpty        => 'अभी तक कोई बातचीत नहीं है।';

  // ── Weather ───────────────────────────────────────────────────────────────
  @override String get weatherTitle          => 'मौसम';
  @override String get weatherTemperature    => 'तापमान';
  @override String get weatherHumidity       => 'नमी';
  @override String get weatherWind           => 'हवा';
  @override String get weatherRain           => 'बारिश';
  @override String get weatherForecast       => 'पूर्वानुमान';
}
