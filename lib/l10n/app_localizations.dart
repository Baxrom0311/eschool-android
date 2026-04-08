import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'Ranch School Parent'**
  String get appName;

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi xabarnoma'**
  String get notificationFallbackTitle;

  /// No description provided for @close.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get close;

  /// No description provided for @changeLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni o\'zgartirish'**
  String get changeLanguage;

  /// No description provided for @changeTheme.
  ///
  /// In uz, this message translates to:
  /// **'Mavzuni o\'zgartirish'**
  String get changeTheme;

  /// No description provided for @themeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim bo\'yicha'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\''**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'u'**
  String get themeDark;

  /// No description provided for @loginHeader.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginHeader;

  /// No description provided for @homeScreen.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy ekran'**
  String get homeScreen;

  /// No description provided for @welcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get welcome;

  /// No description provided for @loginHint.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirish uchun\nma\'lumotlarni kiriting'**
  String get loginHint;

  /// No description provided for @emailSection.
  ///
  /// In uz, this message translates to:
  /// **'EMAIL'**
  String get emailSection;

  /// No description provided for @passwordSection.
  ///
  /// In uz, this message translates to:
  /// **'PAROL'**
  String get passwordSection;

  /// No description provided for @emailExample.
  ///
  /// In uz, this message translates to:
  /// **'Masalan: parent11@ranch.local'**
  String get emailExample;

  /// No description provided for @forgotPasswordShort.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutdingizmi?'**
  String get forgotPasswordShort;

  /// No description provided for @loginButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginButton;

  /// No description provided for @orLabel.
  ///
  /// In uz, this message translates to:
  /// **'YOKI'**
  String get orLabel;

  /// No description provided for @googleLabel.
  ///
  /// In uz, this message translates to:
  /// **'Google'**
  String get googleLabel;

  /// No description provided for @qrCodeLabel.
  ///
  /// In uz, this message translates to:
  /// **'QR-kod'**
  String get qrCodeLabel;

  /// No description provided for @googleSoon.
  ///
  /// In uz, this message translates to:
  /// **'Google orqali kirish tez orada foydalanishga topshiriladi'**
  String get googleSoon;

  /// No description provided for @accountCreatedByAdmin.
  ///
  /// In uz, this message translates to:
  /// **'Hisob administrator tomonidan yaratiladi'**
  String get accountCreatedByAdmin;

  /// No description provided for @registerUnavailableMessage.
  ///
  /// In uz, this message translates to:
  /// **'Tenant API\'da ro\'yxatdan o\'tish endpoint\'i yo\'q. Hisoblar administrator tomonidan yaratiladi.'**
  String get registerUnavailableMessage;

  /// No description provided for @loginFailed.
  ///
  /// In uz, this message translates to:
  /// **'Kirishda xatolik yuz berdi'**
  String get loginFailed;

  /// No description provided for @registerTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi hisob yaratish'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ism va familiya'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ismingizni kiriting'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, ismingizni kiriting'**
  String get fullNameRequired;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get phoneNumberLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get passwordLabel;

  /// No description provided for @createAccountAction.
  ///
  /// In uz, this message translates to:
  /// **'Hisob yaratish'**
  String get createAccountAction;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz bormi?'**
  String get haveAccountPrompt;

  /// No description provided for @qrLoginTitle.
  ///
  /// In uz, this message translates to:
  /// **'QR-kod orqali kirish'**
  String get qrLoginTitle;

  /// No description provided for @qrInvalidFormat.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri QR-kod formati'**
  String get qrInvalidFormat;

  /// No description provided for @qrLoginFailed.
  ///
  /// In uz, this message translates to:
  /// **'QR orqali kirib bo\'lmadi'**
  String get qrLoginFailed;

  /// No description provided for @qrScanInstruction.
  ///
  /// In uz, this message translates to:
  /// **'QR-kodni kameraga tuting'**
  String get qrScanInstruction;

  /// No description provided for @qrAdminInstruction.
  ///
  /// In uz, this message translates to:
  /// **'Maktab administratoridan olingan QR-kodni skanerlang'**
  String get qrAdminInstruction;

  /// No description provided for @profileLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Profilni yuklab bo\'lmadi'**
  String get profileLoadError;

  /// No description provided for @home.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get home;

  /// No description provided for @academics.
  ///
  /// In uz, this message translates to:
  /// **'O\'qish'**
  String get academics;

  /// No description provided for @menu.
  ///
  /// In uz, this message translates to:
  /// **'Ovqat'**
  String get menu;

  /// No description provided for @paymentShort.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov'**
  String get paymentShort;

  /// No description provided for @profile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @homeTitle.
  ///
  /// In uz, this message translates to:
  /// **'E-School'**
  String get homeTitle;

  /// No description provided for @academicsTitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'qish jarayoni'**
  String get academicsTitle;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot mavjud emas'**
  String get noData;

  /// No description provided for @noInternet.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q'**
  String get noInternet;

  /// No description provided for @backendErrorTitle.
  ///
  /// In uz, this message translates to:
  /// **'Backend xatoligi'**
  String get backendErrorTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get errorGeneric;

  /// No description provided for @errorServer.
  ///
  /// In uz, this message translates to:
  /// **'Serverda xatolik'**
  String get errorServer;

  /// No description provided for @errorAuth.
  ///
  /// In uz, this message translates to:
  /// **'Login yoki parol noto\'g\'ri'**
  String get errorAuth;

  /// No description provided for @fieldRequired.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu maydon majburiy'**
  String get fieldRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamini kiriting'**
  String get phoneRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri telefon raqami'**
  String get invalidPhone;

  /// No description provided for @emailRequired.
  ///
  /// In uz, this message translates to:
  /// **'Emailni kiriting'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri email'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In uz, this message translates to:
  /// **'Parolni kiriting'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In uz, this message translates to:
  /// **'Parol kamida 6 ta belgidan iborat bo\'lishi kerak'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlang'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi'**
  String get passwordsDoNotMatch;

  /// No description provided for @requestTimeout.
  ///
  /// In uz, this message translates to:
  /// **'Server kutish vaqti tugadi. Qayta urinib ko\'ring.'**
  String get requestTimeout;

  /// No description provided for @requestCancelled.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov bekor qilindi'**
  String get requestCancelled;

  /// No description provided for @badRequest.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri so\'rov'**
  String get badRequest;

  /// No description provided for @forbidden.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berilmagan'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot topilmadi'**
  String get notFound;

  /// No description provided for @notificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xabarnomalar'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Xabarnomalar hozircha yo\'q'**
  String get notificationsEmpty;

  /// No description provided for @notificationsLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Xabarnomalarni yuklab bo\'lmadi'**
  String get notificationsLoadFailed;

  /// No description provided for @chatFallbackTitle.
  ///
  /// In uz, this message translates to:
  /// **'Chat'**
  String get chatFallbackTitle;

  /// No description provided for @userFallbackName.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi'**
  String get userFallbackName;

  /// No description provided for @subjectFallbackName.
  ///
  /// In uz, this message translates to:
  /// **'Fan'**
  String get subjectFallbackName;

  /// No description provided for @teacherLabel.
  ///
  /// In uz, this message translates to:
  /// **'O\'qituvchi'**
  String get teacherLabel;

  /// No description provided for @meLabel.
  ///
  /// In uz, this message translates to:
  /// **'Siz'**
  String get meLabel;

  /// No description provided for @groupLabel.
  ///
  /// In uz, this message translates to:
  /// **'Guruh'**
  String get groupLabel;

  /// No description provided for @balanceLabel.
  ///
  /// In uz, this message translates to:
  /// **'Balans'**
  String get balanceLabel;

  /// No description provided for @childrenLabel.
  ///
  /// In uz, this message translates to:
  /// **'Farzandlar'**
  String get childrenLabel;

  /// No description provided for @myChildrenTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening farzandlarim'**
  String get myChildrenTitle;

  /// No description provided for @noChildrenFound.
  ///
  /// In uz, this message translates to:
  /// **'Farzandlar topilmadi'**
  String get noChildrenFound;

  /// No description provided for @editProfileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy ma\'lumotlar'**
  String get editProfileTitle;

  /// No description provided for @changeAvatarAction.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni o\'zgartirish'**
  String get changeAvatarAction;

  /// No description provided for @basicInfoTitle.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy ma\'lumotlar'**
  String get basicInfoTitle;

  /// No description provided for @notificationsToggleTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xabarnomalar'**
  String get notificationsToggleTitle;

  /// No description provided for @notificationsToggleSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Push-xabarnomalarni yoqish yoki o\'chirish'**
  String get notificationsToggleSubtitle;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Profil muvaffaqiyatli yangilandi.'**
  String get profileUpdatedSuccess;

  /// No description provided for @achievementsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yutuqlar va nishonlar'**
  String get achievementsTitle;

  /// No description provided for @achievementsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'yinli reyting'**
  String get achievementsSubtitle;

  /// No description provided for @conferencesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ota-onalar majlisi'**
  String get conferencesTitle;

  /// No description provided for @conferencesSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'qituvchi bilan uchrashuvga yozilish'**
  String get conferencesSubtitle;

  /// No description provided for @absenceAppealTitle.
  ///
  /// In uz, this message translates to:
  /// **'E-murojaat'**
  String get absenceAppealTitle;

  /// No description provided for @absenceAppealSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Davomat bo\'yicha sababnomalar'**
  String get absenceAppealSubtitle;

  /// No description provided for @digitalLibraryTitle.
  ///
  /// In uz, this message translates to:
  /// **'Raqamli kutubxona'**
  String get digitalLibraryTitle;

  /// No description provided for @digitalLibrarySubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Darsliklar va kitoblar'**
  String get digitalLibrarySubtitle;

  /// No description provided for @personalInfoTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy ma\'lumotlar'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get personalInfoSubtitle;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Parolni o\'zgartirish'**
  String get passwordChangeTitle;

  /// No description provided for @passwordChangeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik sozlamalari'**
  String get passwordChangeSubtitle;

  /// No description provided for @chatSupportTitle.
  ///
  /// In uz, this message translates to:
  /// **'Chat / Qo\'llab-quvvatlash'**
  String get chatSupportTitle;

  /// No description provided for @chatSupportSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yordam xizmati'**
  String get chatSupportSubtitle;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xabarnoma sozlamalari'**
  String get notificationSettingsSubtitle;

  /// No description provided for @aboutAppTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get aboutAppTitle;

  /// No description provided for @logoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimdan chiqish'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham tizimdan chiqmoqchimisiz?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancel;

  /// No description provided for @logoutAction.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get logoutAction;

  /// No description provided for @schoolAppName.
  ///
  /// In uz, this message translates to:
  /// **'E-School'**
  String get schoolAppName;

  /// No description provided for @conferenceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ota-onalar majlisi'**
  String get conferenceTitle;

  /// No description provided for @selectChildFirst.
  ///
  /// In uz, this message translates to:
  /// **'Avval farzandni tanlang'**
  String get selectChildFirst;

  /// No description provided for @conferenceBookedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv muvaffaqiyatli belgilandi'**
  String get conferenceBookedSuccess;

  /// No description provided for @conferenceBookFailed.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuvni belgilab bo\'lmadi'**
  String get conferenceBookFailed;

  /// No description provided for @invalidMeetingLink.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv havolasi noto\'g\'ri'**
  String get invalidMeetingLink;

  /// No description provided for @openMeetingLinkFailed.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv havolasini ochib bo\'lmadi'**
  String get openMeetingLinkFailed;

  /// No description provided for @conferenceEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuvlar hali belgilanmagan'**
  String get conferenceEmpty;

  /// No description provided for @scheduleConferenceAction.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv belgilash'**
  String get scheduleConferenceAction;

  /// No description provided for @availableSlotsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv uchun bo\'sh vaqtlar'**
  String get availableSlotsTitle;

  /// No description provided for @noAvailableSlots.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'sh vaqtlar topilmadi'**
  String get noAvailableSlots;

  /// No description provided for @noteOptional.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get noteOptional;

  /// No description provided for @bookConferenceAction.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuvni belgilash'**
  String get bookConferenceAction;

  /// No description provided for @absenceTitle.
  ///
  /// In uz, this message translates to:
  /// **'E-murojaat (davomat)'**
  String get absenceTitle;

  /// No description provided for @absenceNeedChild.
  ///
  /// In uz, this message translates to:
  /// **'Davomat bo\'yicha murojaat qilish uchun farzandni tanlang.'**
  String get absenceNeedChild;

  /// No description provided for @submitRequestAction.
  ///
  /// In uz, this message translates to:
  /// **'Murojaat qoldirish'**
  String get submitRequestAction;

  /// No description provided for @noRequestsYet.
  ///
  /// In uz, this message translates to:
  /// **'Murojaatlar hali yo\'q'**
  String get noRequestsYet;

  /// No description provided for @requestStatusCaption.
  ///
  /// In uz, this message translates to:
  /// **'Murojaat yuborganingizdan so\'ng, uning holati bu yerda ko\'rinadi.'**
  String get requestStatusCaption;

  /// No description provided for @noReasonProvided.
  ///
  /// In uz, this message translates to:
  /// **'Sabab ko\'rsatilmadi'**
  String get noReasonProvided;

  /// No description provided for @fileAttached.
  ///
  /// In uz, this message translates to:
  /// **'Fayl biriktirilgan'**
  String get fileAttached;

  /// No description provided for @absenceRequestTitle.
  ///
  /// In uz, this message translates to:
  /// **'Davomat bo\'yicha murojaat qoldirish'**
  String get absenceRequestTitle;

  /// No description provided for @startDateLabel.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanish sanasi'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In uz, this message translates to:
  /// **'Tugash sanasi'**
  String get endDateLabel;

  /// No description provided for @reasonLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sabab'**
  String get reasonLabel;

  /// No description provided for @reasonHint.
  ///
  /// In uz, this message translates to:
  /// **'Sababni qisqacha yozing'**
  String get reasonHint;

  /// No description provided for @attachFile.
  ///
  /// In uz, this message translates to:
  /// **'Fayl biriktirish'**
  String get attachFile;

  /// No description provided for @fileReady.
  ///
  /// In uz, this message translates to:
  /// **'Fayl tayyor'**
  String get fileReady;

  /// No description provided for @reasonRequired.
  ///
  /// In uz, this message translates to:
  /// **'Sababni ko\'rsating'**
  String get reasonRequired;

  /// No description provided for @requestSubmitted.
  ///
  /// In uz, this message translates to:
  /// **'Murojaat yuborildi'**
  String get requestSubmitted;

  /// No description provided for @requestSubmitFailed.
  ///
  /// In uz, this message translates to:
  /// **'Murojaatni yuborib bo\'lmadi'**
  String get requestSubmitFailed;

  /// No description provided for @sendAction.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get sendAction;

  /// No description provided for @libraryBooksTab.
  ///
  /// In uz, this message translates to:
  /// **'Kitoblar'**
  String get libraryBooksTab;

  /// No description provided for @libraryMyBooksTab.
  ///
  /// In uz, this message translates to:
  /// **'Mening kitoblarim'**
  String get libraryMyBooksTab;

  /// No description provided for @librarySearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Kitob qidirish...'**
  String get librarySearchHint;

  /// No description provided for @libraryNoBooksFound.
  ///
  /// In uz, this message translates to:
  /// **'Kitoblar topilmadi'**
  String get libraryNoBooksFound;

  /// No description provided for @libraryUnknownAuthor.
  ///
  /// In uz, this message translates to:
  /// **'Muallif noma\'lum'**
  String get libraryUnknownAuthor;

  /// No description provided for @libraryBorrowAction.
  ///
  /// In uz, this message translates to:
  /// **'Olish'**
  String get libraryBorrowAction;

  /// No description provided for @libraryUnavailableAction.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud emas'**
  String get libraryUnavailableAction;

  /// No description provided for @libraryNoLoans.
  ///
  /// In uz, this message translates to:
  /// **'Sizda olingan kitoblar yo\'q'**
  String get libraryNoLoans;

  /// No description provided for @libraryUnknownBook.
  ///
  /// In uz, this message translates to:
  /// **'Noma\'lum kitob'**
  String get libraryUnknownBook;

  /// No description provided for @libraryReturnAction.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish'**
  String get libraryReturnAction;

  /// No description provided for @libraryReturnedStatus.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarilgan'**
  String get libraryReturnedStatus;

  /// No description provided for @libraryBorrowedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Kitob band qilindi!'**
  String get libraryBorrowedSuccess;

  /// No description provided for @libraryReturnedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Kitob qaytarildi!'**
  String get libraryReturnedSuccess;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parol'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlang'**
  String get confirmPasswordLabel;

  /// No description provided for @saveAction.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get saveAction;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Parol muvaffaqiyatli o\'zgartirildi!'**
  String get passwordUpdatedSuccess;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tiklash'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordPhoneSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamingizni kiriting'**
  String get forgotPasswordPhoneSubtitle;

  /// No description provided for @forgotPasswordCodeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'SMS orqali kelgan kodni kiriting'**
  String get forgotPasswordCodeSubtitle;

  /// No description provided for @phoneNumberSection.
  ///
  /// In uz, this message translates to:
  /// **'TELEFON RAQAMI'**
  String get phoneNumberSection;

  /// No description provided for @sendCodeAction.
  ///
  /// In uz, this message translates to:
  /// **'Kod yuborish'**
  String get sendCodeAction;

  /// No description provided for @backToLoginAction.
  ///
  /// In uz, this message translates to:
  /// **'Kirishga qaytish'**
  String get backToLoginAction;

  /// No description provided for @verificationCodeSection.
  ///
  /// In uz, this message translates to:
  /// **'TASDIQLASH KODI'**
  String get verificationCodeSection;

  /// No description provided for @verificationCodeHint.
  ///
  /// In uz, this message translates to:
  /// **'123456'**
  String get verificationCodeHint;

  /// No description provided for @codeRequired.
  ///
  /// In uz, this message translates to:
  /// **'Kod kiriting'**
  String get codeRequired;

  /// No description provided for @codeLengthInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Kod 6 ta raqamdan iborat bo\'lishi kerak'**
  String get codeLengthInvalid;

  /// No description provided for @resetPasswordAction.
  ///
  /// In uz, this message translates to:
  /// **'Parolni yangilash'**
  String get resetPasswordAction;

  /// No description provided for @resendCodeAction.
  ///
  /// In uz, this message translates to:
  /// **'Kodni qayta yuborish'**
  String get resendCodeAction;

  /// No description provided for @verificationCodeSent.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodi yuborildi'**
  String get verificationCodeSent;

  /// No description provided for @verificationCodeSendFailed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash kodini yuborib bo\'lmadi'**
  String get verificationCodeSendFailed;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Parol muvaffaqiyatli yangilandi!'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetFailed.
  ///
  /// In uz, this message translates to:
  /// **'Parolni yangilab bo\'lmadi'**
  String get passwordResetFailed;

  /// No description provided for @paymentsTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar'**
  String get paymentsTitle;

  /// No description provided for @accountBalanceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob balansi'**
  String get accountBalanceTitle;

  /// No description provided for @notUpdatedLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangilanmagan'**
  String get notUpdatedLabel;

  /// No description provided for @todayLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get yesterdayLabel;

  /// No description provided for @tomorrowLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ertaga'**
  String get tomorrowLabel;

  /// No description provided for @justNowLabel.
  ///
  /// In uz, this message translates to:
  /// **'Hozirgina'**
  String get justNowLabel;

  /// No description provided for @noFinancialData.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot yo\'q'**
  String get noFinancialData;

  /// No description provided for @contractInfoTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shartnoma ma\'lumotlari'**
  String get contractInfoTitle;

  /// No description provided for @contractLabel.
  ///
  /// In uz, this message translates to:
  /// **'Shartnoma'**
  String get contractLabel;

  /// No description provided for @studentLabel.
  ///
  /// In uz, this message translates to:
  /// **'O\'quvchi'**
  String get studentLabel;

  /// No description provided for @classLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sinf'**
  String get classLabel;

  /// No description provided for @monthlyPaymentLabel.
  ///
  /// In uz, this message translates to:
  /// **'Oylik to\'lov'**
  String get monthlyPaymentLabel;

  /// No description provided for @debtExistsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qarzdorlik mavjud'**
  String get debtExistsTitle;

  /// No description provided for @payNowAction.
  ///
  /// In uz, this message translates to:
  /// **'Hozir to\'lash'**
  String get payNowAction;

  /// No description provided for @paymentHistoryTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar tarixi'**
  String get paymentHistoryTitle;

  /// No description provided for @paymentHistoryEmpty.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar tarixi bo\'sh'**
  String get paymentHistoryEmpty;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get paymentMethodTitle;

  /// No description provided for @paymentAmountLabel.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov summasi (UZS)'**
  String get paymentAmountLabel;

  /// No description provided for @paymentMethodsPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Qanday usulda to\'lamoqchisiz?'**
  String get paymentMethodsPrompt;

  /// No description provided for @paymentAction.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovga o\'tish'**
  String get paymentAction;

  /// No description provided for @paymentAgreementText.
  ///
  /// In uz, this message translates to:
  /// **'Tugmani bosish orqali siz ommaviy oferta shartlariga rozilik bildirasiz.'**
  String get paymentAgreementText;

  /// No description provided for @paymentAmountInvalid.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov summasini to\'g\'ri kiriting'**
  String get paymentAmountInvalid;

  /// No description provided for @paymentCreateUnsupported.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov yaratish Parent API\'da hali qo\'llab-quvvatlanmaydi.'**
  String get paymentCreateUnsupported;

  /// No description provided for @paymentRedirectOpenFallback.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani ochib bo\'lmadi. Havolani brauzerda ochib ko\'ring.'**
  String get paymentRedirectOpenFallback;

  /// No description provided for @paymentLinkOpenFailed.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov havolasiga o\'tib bo\'lmadi'**
  String get paymentLinkOpenFailed;

  /// No description provided for @paymentCreatedNoLink.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov yaratildi, lekin havola olinmadi'**
  String get paymentCreatedNoLink;

  /// No description provided for @allPaymentsFilter.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get allPaymentsFilter;

  /// No description provided for @successfulPaymentsFilter.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatli'**
  String get successfulPaymentsFilter;

  /// No description provided for @rejectedPaymentsFilter.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get rejectedPaymentsFilter;

  /// No description provided for @paymentStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatli'**
  String get paymentStatusCompleted;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In uz, this message translates to:
  /// **'Muvaffaqiyatsiz'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarilgan'**
  String get paymentStatusRefunded;

  /// No description provided for @paymentMethodCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodTransfer.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazma'**
  String get paymentMethodTransfer;

  /// No description provided for @currencyCode.
  ///
  /// In uz, this message translates to:
  /// **'UZS'**
  String get currencyCode;

  /// No description provided for @gradesTab.
  ///
  /// In uz, this message translates to:
  /// **'Baholar'**
  String get gradesTab;

  /// No description provided for @ratingTab.
  ///
  /// In uz, this message translates to:
  /// **'Reyting'**
  String get ratingTab;

  /// No description provided for @todayLessonsSectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi darslar'**
  String get todayLessonsSectionTitle;

  /// No description provided for @viewAllAction.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get viewAllAction;

  /// No description provided for @noLessonsTodayShort.
  ///
  /// In uz, this message translates to:
  /// **'Bugun darslar topilmadi'**
  String get noLessonsTodayShort;

  /// No description provided for @servicesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xizmatlar'**
  String get servicesTitle;

  /// No description provided for @conferenceServiceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv'**
  String get conferenceServiceTitle;

  /// No description provided for @absenceServiceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sababnoma'**
  String get absenceServiceTitle;

  /// No description provided for @libraryServiceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kutubxona'**
  String get libraryServiceTitle;

  /// No description provided for @ratingServiceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Reyting'**
  String get ratingServiceTitle;

  /// No description provided for @averageGradeTitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha baho'**
  String get averageGradeTitle;

  /// No description provided for @classRankingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sinf reytingi'**
  String get classRankingTitle;

  /// No description provided for @placeSuffix.
  ///
  /// In uz, this message translates to:
  /// **'o\'rin'**
  String get placeSuffix;

  /// No description provided for @attendanceStatLabel.
  ///
  /// In uz, this message translates to:
  /// **'Davomat'**
  String get attendanceStatLabel;

  /// No description provided for @attendanceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Davomat statistikasi'**
  String get attendanceTitle;

  /// No description provided for @attendanceTotalLessonsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Jami darslar'**
  String get attendanceTotalLessonsLabel;

  /// No description provided for @attendancePresentLabel.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashdi'**
  String get attendancePresentLabel;

  /// No description provided for @attendanceAbsentLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sababsiz'**
  String get attendanceAbsentLabel;

  /// No description provided for @attendancePresentLegend.
  ///
  /// In uz, this message translates to:
  /// **'Bor'**
  String get attendancePresentLegend;

  /// No description provided for @attendanceAbsentLegend.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get attendanceAbsentLegend;

  /// No description provided for @attendanceLateLegend.
  ///
  /// In uz, this message translates to:
  /// **'Kechikkan'**
  String get attendanceLateLegend;

  /// No description provided for @attendanceBackendErrorTitle.
  ///
  /// In uz, this message translates to:
  /// **'Backend xatoligi'**
  String get attendanceBackendErrorTitle;

  /// No description provided for @coinsStatLabel.
  ///
  /// In uz, this message translates to:
  /// **'Coinlar'**
  String get coinsStatLabel;

  /// No description provided for @latestNewsTitle.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi yangilik'**
  String get latestNewsTitle;

  /// No description provided for @todayLunchTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi tushlik'**
  String get todayLunchTitle;

  /// No description provided for @todayLunchSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Oshxonada yangi taomlar tayyorlandi'**
  String get todayLunchSubtitle;

  /// No description provided for @dailyMenuTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ovqat menyusi'**
  String get dailyMenuTitle;

  /// No description provided for @noMenuOnSelectedDay.
  ///
  /// In uz, this message translates to:
  /// **'Tanlangan kun uchun menyu mavjud emas'**
  String get noMenuOnSelectedDay;

  /// No description provided for @mealIngredientsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tarkibi:'**
  String get mealIngredientsTitle;

  /// No description provided for @chatsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Chatlar'**
  String get chatsTitle;

  /// No description provided for @chatsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Chatlar hozircha yo\'q'**
  String get chatsEmpty;

  /// No description provided for @noMessageShort.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yo\'q'**
  String get noMessageShort;

  /// No description provided for @ratingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Reyting'**
  String get ratingTitle;

  /// No description provided for @classScopeTab.
  ///
  /// In uz, this message translates to:
  /// **'Sinfda'**
  String get classScopeTab;

  /// No description provided for @schoolScopeTab.
  ///
  /// In uz, this message translates to:
  /// **'Maktabda'**
  String get schoolScopeTab;

  /// No description provided for @ratingDataEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot yo\'q'**
  String get ratingDataEmpty;

  /// No description provided for @ratingListEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Reyting ma\'lumotlari topilmadi'**
  String get ratingListEmpty;

  /// No description provided for @ratingLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Reytingni yuklashda xatolik'**
  String get ratingLoadFailed;

  /// No description provided for @schoolRatingLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Maktab reytingini yuklashda xatolik'**
  String get schoolRatingLoadFailed;

  /// No description provided for @leaderboardTitle.
  ///
  /// In uz, this message translates to:
  /// **'Liderlar jadvali'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardClassTab.
  ///
  /// In uz, this message translates to:
  /// **'Sinf'**
  String get leaderboardClassTab;

  /// No description provided for @leaderboardSchoolTab.
  ///
  /// In uz, this message translates to:
  /// **'Maktab'**
  String get leaderboardSchoolTab;

  /// No description provided for @leaderboardBadgesTab.
  ///
  /// In uz, this message translates to:
  /// **'Nishonlar'**
  String get leaderboardBadgesTab;

  /// No description provided for @leaderboardClassEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Sinf reytingi hozircha yo\'q'**
  String get leaderboardClassEmpty;

  /// No description provided for @leaderboardSchoolEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Maktab reytingi hozircha yo\'q'**
  String get leaderboardSchoolEmpty;

  /// No description provided for @myBadgesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening nishonlarim'**
  String get myBadgesTitle;

  /// No description provided for @noBadgesYet.
  ///
  /// In uz, this message translates to:
  /// **'Hali nishonlar yo\'q'**
  String get noBadgesYet;

  /// No description provided for @scheduleTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dars jadvali'**
  String get scheduleTitle;

  /// No description provided for @noScheduleAvailable.
  ///
  /// In uz, this message translates to:
  /// **'Darslar mavjud emas'**
  String get noScheduleAvailable;

  /// No description provided for @currentLessonBadge.
  ///
  /// In uz, this message translates to:
  /// **'Hozir'**
  String get currentLessonBadge;

  /// No description provided for @noClassLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sinf yo\'q'**
  String get noClassLabel;

  /// No description provided for @assignmentsTab.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get assignmentsTab;

  /// No description provided for @newAssignmentsTab.
  ///
  /// In uz, this message translates to:
  /// **'Yangi vazifalar'**
  String get newAssignmentsTab;

  /// No description provided for @allAssignmentsTab.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get allAssignmentsTab;

  /// No description provided for @assignmentsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar topilmadi'**
  String get assignmentsEmpty;

  /// No description provided for @assignmentStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get assignmentStatusPending;

  /// No description provided for @assignmentStatusSubmitted.
  ///
  /// In uz, this message translates to:
  /// **'Topshirilgan'**
  String get assignmentStatusSubmitted;

  /// No description provided for @assignmentStatusGraded.
  ///
  /// In uz, this message translates to:
  /// **'Baholangan'**
  String get assignmentStatusGraded;

  /// No description provided for @assignmentStatusOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o\'tgan'**
  String get assignmentStatusOverdue;

  /// No description provided for @assignmentSubmitAction.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get assignmentSubmitAction;

  /// No description provided for @assignmentSubmitSoon.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa yuborish funksiyasi tez orada...'**
  String get assignmentSubmitSoon;

  /// No description provided for @myPerformanceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening ko\'rsatkichlarim'**
  String get myPerformanceTitle;

  /// No description provided for @noGradesAvailable.
  ///
  /// In uz, this message translates to:
  /// **'Baholar mavjud emas'**
  String get noGradesAvailable;

  /// No description provided for @gradesBySubjectTitle.
  ///
  /// In uz, this message translates to:
  /// **'Fanlar bo\'yicha'**
  String get gradesBySubjectTitle;

  /// No description provided for @averageShortLabel.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha'**
  String get averageShortLabel;

  /// No description provided for @overallPerformanceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy o\'zlashtirish'**
  String get overallPerformanceTitle;

  /// No description provided for @overallPerformanceSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Fanlar bo\'yicha umumiy natijangiz'**
  String get overallPerformanceSubtitle;

  /// No description provided for @lessonsStatLabel.
  ///
  /// In uz, this message translates to:
  /// **'Darslar'**
  String get lessonsStatLabel;

  /// No description provided for @assignmentDetailsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa tafsilotlari'**
  String get assignmentDetailsTitle;

  /// No description provided for @assignmentNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa topilmadi'**
  String get assignmentNotFound;

  /// No description provided for @assignmentSelectFileFirst.
  ///
  /// In uz, this message translates to:
  /// **'Avval fayl tanlang'**
  String get assignmentSelectFileFirst;

  /// No description provided for @assignmentStudentResolveFailed.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa uchun o\'quvchi aniqlanmadi. Qayta urinib ko\'ring.'**
  String get assignmentStudentResolveFailed;

  /// No description provided for @assignmentSubmittedSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa muvaffaqiyatli yuborildi'**
  String get assignmentSubmittedSuccess;

  /// No description provided for @assignmentSubmitFailed.
  ///
  /// In uz, this message translates to:
  /// **'Yuborishda xatolik'**
  String get assignmentSubmitFailed;

  /// No description provided for @assignmentTeacherFilesTitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'qituvchi fayllari'**
  String get assignmentTeacherFilesTitle;

  /// No description provided for @assignmentNoTeacherFiles.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirilgan fayl yo\'q'**
  String get assignmentNoTeacherFiles;

  /// No description provided for @assignmentSubmittedFilesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuborilgan fayllar'**
  String get assignmentSubmittedFilesTitle;

  /// No description provided for @assignmentNotSubmittedYet.
  ///
  /// In uz, this message translates to:
  /// **'Hali yuborilmagan'**
  String get assignmentNotSubmittedYet;

  /// No description provided for @chooseFileAction.
  ///
  /// In uz, this message translates to:
  /// **'Fayl tanlash'**
  String get chooseFileAction;

  /// No description provided for @chooseAnotherFileAction.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa fayl tanlash'**
  String get chooseAnotherFileAction;

  /// No description provided for @chatOnlineStatus.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn'**
  String get chatOnlineStatus;

  /// No description provided for @chatOfflineStatus.
  ///
  /// In uz, this message translates to:
  /// **'Oflayn'**
  String get chatOfflineStatus;

  /// No description provided for @refreshAction.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get refreshAction;

  /// No description provided for @backToChatsAction.
  ///
  /// In uz, this message translates to:
  /// **'Chatlar ro\'yxatiga qaytish'**
  String get backToChatsAction;

  /// No description provided for @chatMessageHint.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yozing...'**
  String get chatMessageHint;

  /// No description provided for @chatMessageSendFailed.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yuborilmadi'**
  String get chatMessageSendFailed;

  /// No description provided for @chatFileSendFailed.
  ///
  /// In uz, this message translates to:
  /// **'Fayl yuborilmadi'**
  String get chatFileSendFailed;

  /// No description provided for @breakfastLabel.
  ///
  /// In uz, this message translates to:
  /// **'Nonushta'**
  String get breakfastLabel;

  /// No description provided for @lunchLabel.
  ///
  /// In uz, this message translates to:
  /// **'Tushlik'**
  String get lunchLabel;

  /// No description provided for @afternoonTeaLabel.
  ///
  /// In uz, this message translates to:
  /// **'Poldnik'**
  String get afternoonTeaLabel;

  /// No description provided for @dinnerLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kechki ovqat'**
  String get dinnerLabel;

  /// No description provided for @snackLabel.
  ///
  /// In uz, this message translates to:
  /// **'Tamaddi'**
  String get snackLabel;

  /// No description provided for @gradesLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Baholarni yuklashda xatolik'**
  String get gradesLoadFailed;

  /// No description provided for @gradeSummaryLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Baholar xulosasini yuklashda xatolik'**
  String get gradeSummaryLoadFailed;

  /// No description provided for @scheduleLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Jadvalni yuklashda xatolik'**
  String get scheduleLoadFailed;

  /// No description provided for @assignmentsLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Topshiriqlarni yuklashda xatolik'**
  String get assignmentsLoadFailed;

  /// No description provided for @assignmentDetailsLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Topshiriq tafsilotlarini yuklashda xatolik'**
  String get assignmentDetailsLoadFailed;

  /// No description provided for @assignmentUploadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Fayl yuklashda xatolik'**
  String get assignmentUploadFailed;

  /// No description provided for @attendanceLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Davomatni yuklashda xatolik'**
  String get attendanceLoadFailed;

  /// No description provided for @attendanceSummaryLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Davomat xulosasini yuklashda xatolik'**
  String get attendanceSummaryLoadFailed;

  /// No description provided for @menuLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Menyuni yuklashda xatolik'**
  String get menuLoadFailed;

  /// No description provided for @weeklyMenuLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Haftalik menyuni yuklashda xatolik'**
  String get weeklyMenuLoadFailed;

  /// No description provided for @conversationsLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Suhbatlarni yuklashda xatolik'**
  String get conversationsLoadFailed;

  /// No description provided for @messagesLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Xabarlarni yuklashda xatolik'**
  String get messagesLoadFailed;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In uz, this message translates to:
  /// **'Profilni yangilashda xatolik'**
  String get profileUpdateFailed;

  /// No description provided for @imageUploadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklashda xatolik'**
  String get imageUploadFailed;

  /// No description provided for @childrenLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Farzandlarni yuklashda xatolik'**
  String get childrenLoadFailed;

  /// No description provided for @dataLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot yuklashda xatolik'**
  String get dataLoadFailed;

  /// No description provided for @changePasswordFailed.
  ///
  /// In uz, this message translates to:
  /// **'Parolni o\'zgartishda xatolik'**
  String get changePasswordFailed;

  /// No description provided for @balanceLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Balansni yuklashda xatolik'**
  String get balanceLoadFailed;

  /// No description provided for @paymentHistoryLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'To\'lovlar tarixini yuklashda xatolik'**
  String get paymentHistoryLoadFailed;

  /// No description provided for @paymentCreateFailed.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov yaratishda xatolik'**
  String get paymentCreateFailed;

  /// No description provided for @paymentMethodsLoadFailed.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usullarini yuklashda xatolik'**
  String get paymentMethodsLoadFailed;

  /// No description provided for @gradeTypeDaily.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik'**
  String get gradeTypeDaily;

  /// No description provided for @gradeTypeExam.
  ///
  /// In uz, this message translates to:
  /// **'Imtihon'**
  String get gradeTypeExam;

  /// No description provided for @gradeTypeHomework.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifasi'**
  String get gradeTypeHomework;

  /// No description provided for @gradeTypeTest.
  ///
  /// In uz, this message translates to:
  /// **'Test'**
  String get gradeTypeTest;

  /// No description provided for @langUz.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekcha'**
  String get langUz;

  /// No description provided for @langRu.
  ///
  /// In uz, this message translates to:
  /// **'Ruscha'**
  String get langRu;

  /// No description provided for @langEn.
  ///
  /// In uz, this message translates to:
  /// **'Inglizcha'**
  String get langEn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
