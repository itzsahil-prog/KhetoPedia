import 'package:flutter/material.dart';
import 'strings_en.dart';
import 'strings_hi.dart';

/// Minimal hand-rolled localizations — no code generation needed.
///
/// Add a new locale:
///   1. Create `strings_xx.dart` implementing [AppStrings].
///   2. Register the locale in [AppLocalizationsDelegate._map].
class AppLocalizations {
  const AppLocalizations._(this._strings);

  final AppStrings _strings;

  // ── Convenience accessor ───────────────────────────────────────────────
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations._(StringsEn());
  }

  // ── Delegates required by MaterialApp ─────────────────────────────────
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  // ── General string accessors ──────────────────────────────────────────
  String get appName           => _strings.appName;
  String get tabHome           => _strings.tabHome;
  String get tabScan           => _strings.tabScan;
  String get tabFields         => _strings.tabFields;
  String get tabSoil           => _strings.tabSoil;
  String get tabAI             => _strings.tabAI;
  String get loading           => _strings.loading;
  String get retry             => _strings.retry;
  String get errorGeneric      => _strings.errorGeneric;
  String get emptyGeneric      => _strings.emptyGeneric;
  String get cancel            => _strings.cancel;
  String get confirm           => _strings.confirm;
  String get save              => _strings.save;
  String get delete            => _strings.delete;
  String get search            => _strings.search;
  String get settings          => _strings.settings;
  String get theme             => _strings.theme;
  String get language          => _strings.language;
  String get themeLight        => _strings.themeLight;
  String get themeDark         => _strings.themeDark;
  String get themeSystem       => _strings.themeSystem;

  // ── Auth string accessors ─────────────────────────────────────────────
  String get authLogin               => _strings.authLogin;
  String get authSignUp              => _strings.authSignUp;
  String get authLogout              => _strings.authLogout;
  String get authEmail               => _strings.authEmail;
  String get authEmailHint           => _strings.authEmailHint;
  String get authPassword            => _strings.authPassword;
  String get authPasswordHint        => _strings.authPasswordHint;
  String get authConfirmPassword     => _strings.authConfirmPassword;
  String get authConfirmPasswordHint => _strings.authConfirmPasswordHint;
  String get authFullName            => _strings.authFullName;
  String get authFullNameHint        => _strings.authFullNameHint;
  String get authPhone               => _strings.authPhone;
  String get authPhoneHint           => _strings.authPhoneHint;
  String get authForgotPassword      => _strings.authForgotPassword;
  String get authForgotPasswordTitle => _strings.authForgotPasswordTitle;
  String get authForgotPasswordBody  => _strings.authForgotPasswordBody;
  String get authSendOtp             => _strings.authSendOtp;
  String get authOtpTitle            => _strings.authOtpTitle;
  String get authOtpBody             => _strings.authOtpBody;
  String get authOtpHint             => _strings.authOtpHint;
  String get authVerify              => _strings.authVerify;
  String get authResendOtp           => _strings.authResendOtp;
  String get authResendOtpIn         => _strings.authResendOtpIn;
  String get authNewPassword         => _strings.authNewPassword;
  String get authNewPasswordHint     => _strings.authNewPasswordHint;
  String get authResetPassword       => _strings.authResetPassword;
  String get authResetPasswordTitle  => _strings.authResetPasswordTitle;
  String get authNoAccount           => _strings.authNoAccount;
  String get authHaveAccount         => _strings.authHaveAccount;
  String get authWelcomeBack         => _strings.authWelcomeBack;
  String get authCreateAccount       => _strings.authCreateAccount;
  String get authAgreeToTerms        => _strings.authAgreeToTerms;
  String get authTermsOfService      => _strings.authTermsOfService;
  String get authPrivacyPolicy       => _strings.authPrivacyPolicy;
  String get authPasswordsDoNotMatch => _strings.authPasswordsDoNotMatch;
  String get authPasswordTooShort    => _strings.authPasswordTooShort;
  String get authInvalidEmail        => _strings.authInvalidEmail;
  String get authFieldRequired       => _strings.authFieldRequired;
  String get authOtpSentTo           => _strings.authOtpSentTo;
  String get authSessionExpired      => _strings.authSessionExpired;
  String get authShowPassword        => _strings.authShowPassword;
  String get authHidePassword        => _strings.authHidePassword;
  String get authOrContinueWith      => _strings.authOrContinueWith;

  // ── Dashboard string accessors ────────────────────────────────────────────
  String get dashboardTitle              => _strings.dashboardTitle;
  String get dashboardGreetingMorning    => _strings.dashboardGreetingMorning;
  String get dashboardGreetingAfternoon  => _strings.dashboardGreetingAfternoon;
  String get dashboardGreetingEvening    => _strings.dashboardGreetingEvening;
  String get dashboardSectionStats       => _strings.dashboardSectionStats;
  String get dashboardSectionAlerts      => _strings.dashboardSectionAlerts;
  String get dashboardSectionRecentFields => _strings.dashboardSectionRecentFields;
  String get dashboardAlertsEmpty        => _strings.dashboardAlertsEmpty;
  String get dashboardFieldsEmpty        => _strings.dashboardFieldsEmpty;
  String get dashboardStatsEmpty         => _strings.dashboardStatsEmpty;
  String get dashboardRefresh            => _strings.dashboardRefresh;
  String get dashboardAlertSeverityInfo  => _strings.dashboardAlertSeverityInfo;
  String get dashboardAlertSeverityWarning => _strings.dashboardAlertSeverityWarning;
  String get dashboardAlertSeverityCritical => _strings.dashboardAlertSeverityCritical;
  String get dashboardFieldHealthScore   => _strings.dashboardFieldHealthScore;
  String get dashboardFieldLastScanned   => _strings.dashboardFieldLastScanned;
  String get dashboardFieldNeverScanned  => _strings.dashboardFieldNeverScanned;
  String get dashboardFieldAreaHectares  => _strings.dashboardFieldAreaHectares;
  String get dashboardSeeAllAlerts       => _strings.dashboardSeeAllAlerts;
  String get dashboardSeeAllFields       => _strings.dashboardSeeAllFields;
  String get dashboardStatusHealthy      => _strings.dashboardStatusHealthy;
  String get dashboardStatusAtRisk       => _strings.dashboardStatusAtRisk;
  String get dashboardStatusCritical     => _strings.dashboardStatusCritical;
}

// ── Delegate ───────────────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  static const _map = <String, AppStrings>{
    'en': StringsEn(),
    'hi': StringsHi(),
  };

  @override
  bool isSupported(Locale locale) =>
      _map.containsKey(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final strings = _map[locale.languageCode] ?? const StringsEn();
    return AppLocalizations._(strings);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ── Abstract string contract ───────────────────────────────────────────────
abstract class AppStrings {
  const AppStrings();

  // General
  String get appName;
  String get tabHome;
  String get tabScan;
  String get tabFields;
  String get tabSoil;
  String get tabAI;
  String get loading;
  String get retry;
  String get errorGeneric;
  String get emptyGeneric;
  String get cancel;
  String get confirm;
  String get save;
  String get delete;
  String get search;
  String get settings;
  String get theme;
  String get language;
  String get themeLight;
  String get themeDark;
  String get themeSystem;

  // Auth
  String get authLogin;
  String get authSignUp;
  String get authLogout;
  String get authEmail;
  String get authEmailHint;
  String get authPassword;
  String get authPasswordHint;
  String get authConfirmPassword;
  String get authConfirmPasswordHint;
  String get authFullName;
  String get authFullNameHint;
  String get authPhone;
  String get authPhoneHint;
  String get authForgotPassword;
  String get authForgotPasswordTitle;
  String get authForgotPasswordBody;
  String get authSendOtp;
  String get authOtpTitle;
  String get authOtpBody;
  String get authOtpHint;
  String get authVerify;
  String get authResendOtp;
  String get authResendOtpIn;
  String get authNewPassword;
  String get authNewPasswordHint;
  String get authResetPassword;
  String get authResetPasswordTitle;
  String get authNoAccount;
  String get authHaveAccount;
  String get authWelcomeBack;
  String get authCreateAccount;
  String get authAgreeToTerms;
  String get authTermsOfService;
  String get authPrivacyPolicy;
  String get authPasswordsDoNotMatch;
  String get authPasswordTooShort;
  String get authInvalidEmail;
  String get authFieldRequired;
  String get authOtpSentTo;
  String get authSessionExpired;
  String get authShowPassword;
  String get authHidePassword;
  String get authOrContinueWith;

  // Dashboard
  String get dashboardTitle;
  String get dashboardGreetingMorning;
  String get dashboardGreetingAfternoon;
  String get dashboardGreetingEvening;
  String get dashboardSectionStats;
  String get dashboardSectionAlerts;
  String get dashboardSectionRecentFields;
  String get dashboardAlertsEmpty;
  String get dashboardFieldsEmpty;
  String get dashboardStatsEmpty;
  String get dashboardRefresh;
  String get dashboardAlertSeverityInfo;
  String get dashboardAlertSeverityWarning;
  String get dashboardAlertSeverityCritical;
  String get dashboardFieldHealthScore;
  String get dashboardFieldLastScanned;
  String get dashboardFieldNeverScanned;
  String get dashboardFieldAreaHectares;
  String get dashboardSeeAllAlerts;
  String get dashboardSeeAllFields;
  String get dashboardStatusHealthy;
  String get dashboardStatusAtRisk;
  String get dashboardStatusCritical;
}
