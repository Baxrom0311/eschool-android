import '../localization/app_localizations.dart';

class AppStrings {
  AppStrings._();

  static String get home => AppLocalizations.current.home;
  static String get academics => AppLocalizations.current.academics;
  static String get menu => AppLocalizations.current.menu;
  static String get payments => AppLocalizations.current.paymentShort;
  static String get profile => AppLocalizations.current.profile;
  static String get retry => AppLocalizations.current.retry;
  static String get noData => AppLocalizations.current.noData;
  static String get noInternet => AppLocalizations.current.noInternet;
  static String get errorGeneric => AppLocalizations.current.errorGeneric;
  static String get errorServer => AppLocalizations.current.errorServer;
  static String get errorAuth => AppLocalizations.current.errorAuth;
  static String get fieldRequired => AppLocalizations.current.fieldRequired;
  static String get phoneRequired => AppLocalizations.current.phoneRequired;
  static String get invalidPhone => AppLocalizations.current.invalidPhone;
  static String get emailRequired => AppLocalizations.current.emailRequired;
  static String get invalidEmail => AppLocalizations.current.invalidEmail;
  static String get passwordRequired =>
      AppLocalizations.current.passwordRequired;
  static String get passwordTooShort =>
      AppLocalizations.current.passwordTooShort;
  static String get confirmPasswordRequired =>
      AppLocalizations.current.confirmPasswordRequired;
  static String get passwordsDoNotMatch =>
      AppLocalizations.current.passwordsDoNotMatch;
  static String get requestTimeout => AppLocalizations.current.requestTimeout;
  static String get requestCancelled =>
      AppLocalizations.current.requestCancelled;
  static String get badRequest => AppLocalizations.current.badRequest;
  static String get forbidden => AppLocalizations.current.forbidden;
  static String get notFound => AppLocalizations.current.notFound;

  static String minimumLength(int min) =>
      AppLocalizations.current.minimumLength(min);
}
