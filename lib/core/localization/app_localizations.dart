import 'package:flutter/widgets.dart';

import 'app_locale.dart';

class AppLocalizations {
  AppLocalizations(this.appLocale);

  final AppLocale appLocale;

  static AppLocalizations _current = AppLocalizations(AppLocale.uz);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales =>
      AppLocale.values.map((locale) => locale.locale).toList(growable: false);

  static AppLocalizations get current => _current;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        _current;
  }

  static void updateCurrent(AppLocalizations localizations) {
    _current = localizations;
  }

  String get appName => _text('appName');
  String get notificationFallbackTitle => _text('notificationFallbackTitle');
  String get close => _text('close');
  String get changeLanguage => _text('changeLanguage');
  String get loginHeader => _text('loginHeader');
  String get homeScreen => _text('homeScreen');
  String get welcome => _text('welcome');
  String get loginHint => _text('loginHint');
  String get emailSection => _text('emailSection');
  String get passwordSection => _text('passwordSection');
  String get emailExample => _text('emailExample');
  String get forgotPasswordShort => _text('forgotPasswordShort');
  String get loginButton => _text('loginButton');
  String get orLabel => _text('orLabel');
  String get googleLabel => _text('googleLabel');
  String get qrCodeLabel => _text('qrCodeLabel');
  String get googleSoon => _text('googleSoon');
  String get accountCreatedByAdmin => _text('accountCreatedByAdmin');
  String get loginFailed => _text('loginFailed');
  String get profileLoadError => _text('profileLoadError');
  String get home => _text('home');
  String get academics => _text('academics');
  String get menu => _text('menu');
  String get paymentShort => _text('paymentShort');
  String get profile => _text('profile');
  String get homeTitle => _text('homeTitle');
  String get academicsTitle => _text('academicsTitle');
  String get retry => _text('retry');
  String get noData => _text('noData');
  String get noInternet => _text('noInternet');
  String get errorGeneric => _text('errorGeneric');
  String get errorServer => _text('errorServer');
  String get errorAuth => _text('errorAuth');
  String get fieldRequired => _text('fieldRequired');
  String get phoneRequired => _text('phoneRequired');
  String get invalidPhone => _text('invalidPhone');
  String get emailRequired => _text('emailRequired');
  String get invalidEmail => _text('invalidEmail');
  String get passwordRequired => _text('passwordRequired');
  String get passwordTooShort => _text('passwordTooShort');
  String get confirmPasswordRequired => _text('confirmPasswordRequired');
  String get passwordsDoNotMatch => _text('passwordsDoNotMatch');
  String get requestTimeout => _text('requestTimeout');
  String get requestCancelled => _text('requestCancelled');
  String get badRequest => _text('badRequest');
  String get forbidden => _text('forbidden');
  String get notFound => _text('notFound');

  String minimumLength(int min) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Kamida $min ta belgi kiritilishi kerak';
      case AppLocale.ru:
        return 'Введите минимум $min символа';
      case AppLocale.en:
        return 'Enter at least $min characters';
    }
  }

  String _text(String key) {
    return _localizedValues[appLocale.code]?[key] ??
        _localizedValues[AppLocale.uz.code]![key]!;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocale.values.any(
    (appLocale) => appLocale.code == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(
      appLocaleFromCode(locale.languageCode),
    );
    AppLocalizations.updateCurrent(localizations);
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const Map<String, Map<String, String>> _localizedValues = {
  'uz': {
    'appName': 'Ranch School Parent',
    'notificationFallbackTitle': 'Yangi xabarnoma',
    'close': 'Yopish',
    'changeLanguage': 'Tilni o\'zgartirish',
    'loginHeader': 'Login',
    'homeScreen': 'Asosiy ekran',
    'welcome': 'Xush kelibsiz!',
    'loginHint': 'Tizimga kirish uchun\nma\'lumotlaringizni kiriting',
    'emailSection': 'EMAIL',
    'passwordSection': 'PAROL',
    'emailExample': 'Masalan: parent11@ranch.local',
    'forgotPasswordShort': 'Unutdingizmi?',
    'loginButton': 'Kirish',
    'orLabel': 'YOKI',
    'googleLabel': 'Google',
    'qrCodeLabel': 'QR Kod',
    'googleSoon': 'Google orqali kirish tez kunda ishga tushiriladi',
    'accountCreatedByAdmin': 'Hisob administrator tomonidan yaratiladi',
    'loginFailed': 'Kirish amalga oshmadi',
    'profileLoadError': 'Profil ma\'lumotlarini yuklashda xatolik',
    'home': 'Asosiy',
    'academics': 'Ta\'lim',
    'menu': 'Ovqat',
    'paymentShort': 'To\'lov',
    'profile': 'Profil',
    'homeTitle': 'E-School',
    'academicsTitle': 'Ta\'lim',
    'retry': 'Qayta urinish',
    'noData': 'Ma\'lumot yo\'q',
    'noInternet': 'Internet bilan aloqa yo\'q',
    'errorGeneric': 'Nimadir xato ketdi',
    'errorServer': 'Server xatoligi',
    'errorAuth': 'Login yoki parol noto\'g\'ri',
    'fieldRequired': 'Bu maydon to\'ldirilishi shart',
    'phoneRequired': 'Telefon raqamini kiriting',
    'invalidPhone': 'Telefon raqami noto\'g\'ri',
    'emailRequired': 'Email kiriting',
    'invalidEmail': 'Email noto\'g\'ri',
    'passwordRequired': 'Parol kiriting',
    'passwordTooShort': 'Parol kamida 6 ta belgi bo\'lishi kerak',
    'confirmPasswordRequired': 'Parolni tasdiqlang',
    'passwordsDoNotMatch': 'Parollar mos kelmayapti',
    'requestTimeout': 'Server bilan aloqa vaqti tugadi. Qayta urinib ko\'ring.',
    'requestCancelled': 'So\'rov bekor qilindi',
    'badRequest': 'Noto\'g\'ri so\'rov',
    'forbidden': 'Ruxsat berilmagan',
    'notFound': 'Ma\'lumot topilmadi',
  },
  'ru': {
    'appName': 'Ranch School Parent',
    'notificationFallbackTitle': 'Новое уведомление',
    'close': 'Закрыть',
    'changeLanguage': 'Сменить язык',
    'loginHeader': 'Вход',
    'homeScreen': 'Главный экран',
    'welcome': 'Добро пожаловать!',
    'loginHint': 'Введите данные,\nчтобы войти в систему',
    'emailSection': 'EMAIL',
    'passwordSection': 'ПАРОЛЬ',
    'emailExample': 'Например: parent11@ranch.local',
    'forgotPasswordShort': 'Забыли пароль?',
    'loginButton': 'Войти',
    'orLabel': 'ИЛИ',
    'googleLabel': 'Google',
    'qrCodeLabel': 'QR-код',
    'googleSoon': 'Вход через Google скоро будет доступен',
    'accountCreatedByAdmin': 'Аккаунт создается администратором',
    'loginFailed': 'Не удалось войти',
    'profileLoadError': 'Не удалось загрузить профиль',
    'home': 'Главная',
    'academics': 'Учёба',
    'menu': 'Питание',
    'paymentShort': 'Оплата',
    'profile': 'Профиль',
    'homeTitle': 'E-School',
    'academicsTitle': 'Учёба',
    'retry': 'Повторить',
    'noData': 'Нет данных',
    'noInternet': 'Нет подключения к интернету',
    'errorGeneric': 'Что-то пошло не так',
    'errorServer': 'Ошибка сервера',
    'errorAuth': 'Неверный логин или пароль',
    'fieldRequired': 'Это поле обязательно',
    'phoneRequired': 'Введите номер телефона',
    'invalidPhone': 'Неверный номер телефона',
    'emailRequired': 'Введите email',
    'invalidEmail': 'Неверный email',
    'passwordRequired': 'Введите пароль',
    'passwordTooShort': 'Пароль должен содержать минимум 6 символов',
    'confirmPasswordRequired': 'Подтвердите пароль',
    'passwordsDoNotMatch': 'Пароли не совпадают',
    'requestTimeout':
        'Время ожидания ответа сервера истекло. Повторите попытку.',
    'requestCancelled': 'Запрос отменен',
    'badRequest': 'Некорректный запрос',
    'forbidden': 'Доступ запрещен',
    'notFound': 'Данные не найдены',
  },
  'en': {
    'appName': 'Ranch School Parent',
    'notificationFallbackTitle': 'New notification',
    'close': 'Close',
    'changeLanguage': 'Change language',
    'loginHeader': 'Login',
    'homeScreen': 'Home screen',
    'welcome': 'Welcome!',
    'loginHint': 'Enter your credentials\nto sign in',
    'emailSection': 'EMAIL',
    'passwordSection': 'PASSWORD',
    'emailExample': 'Example: parent11@ranch.local',
    'forgotPasswordShort': 'Forgot password?',
    'loginButton': 'Sign in',
    'orLabel': 'OR',
    'googleLabel': 'Google',
    'qrCodeLabel': 'QR Code',
    'googleSoon': 'Google sign-in will be available soon',
    'accountCreatedByAdmin': 'Accounts are created by the administrator',
    'loginFailed': 'Login failed',
    'profileLoadError': 'Failed to load profile data',
    'home': 'Home',
    'academics': 'Academics',
    'menu': 'Meals',
    'paymentShort': 'Payments',
    'profile': 'Profile',
    'homeTitle': 'E-School',
    'academicsTitle': 'Academics',
    'retry': 'Retry',
    'noData': 'No data',
    'noInternet': 'No internet connection',
    'errorGeneric': 'Something went wrong',
    'errorServer': 'Server error',
    'errorAuth': 'Incorrect login or password',
    'fieldRequired': 'This field is required',
    'phoneRequired': 'Enter a phone number',
    'invalidPhone': 'Invalid phone number',
    'emailRequired': 'Enter your email',
    'invalidEmail': 'Invalid email address',
    'passwordRequired': 'Enter your password',
    'passwordTooShort': 'Password must contain at least 6 characters',
    'confirmPasswordRequired': 'Confirm your password',
    'passwordsDoNotMatch': 'Passwords do not match',
    'requestTimeout': 'The server timed out. Please try again.',
    'requestCancelled': 'Request was cancelled',
    'badRequest': 'Bad request',
    'forbidden': 'Access denied',
    'notFound': 'Data not found',
  },
};
