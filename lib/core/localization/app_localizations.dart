import 'package:flutter/widgets.dart';

import '../../data/models/assignment_model.dart';
import 'app_locale.dart';

class AppLocalizations {
  AppLocalizations(this.appLocale);

  final AppLocale appLocale;

  static AppLocalizations _current = AppLocalizations(AppLocale.uz);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales =>
      AppLocale.values.map((locale) => locale.locale).toList(growable: false);

  String get intlLocaleTag {
    switch (appLocale) {
      case AppLocale.uz:
        return 'uz';
      case AppLocale.ru:
        return 'ru';
      case AppLocale.en:
        return 'en';
    }
  }

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
  String get changeTheme => _text('changeTheme');
  String get themeSystem => _text('themeSystem');
  String get themeLight => _text('themeLight');
  String get themeDark => _text('themeDark');
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
  String get registerUnavailableMessage => _text('registerUnavailableMessage');
  String get loginFailed => _text('loginFailed');
  String get registerTitle => _text('registerTitle');
  String get registerSubtitle => _text('registerSubtitle');
  String get fullNameLabel => _text('fullNameLabel');
  String get fullNameHint => _text('fullNameHint');
  String get fullNameRequired => _text('fullNameRequired');
  String get phoneNumberLabel => _text('phoneNumberLabel');
  String get passwordLabel => _text('passwordLabel');
  String get createAccountAction => _text('createAccountAction');
  String get haveAccountPrompt => _text('haveAccountPrompt');
  String get qrLoginTitle => _text('qrLoginTitle');
  String get qrInvalidFormat => _text('qrInvalidFormat');
  String get qrLoginFailed => _text('qrLoginFailed');
  String get qrScanInstruction => _text('qrScanInstruction');
  String get qrAdminInstruction => _text('qrAdminInstruction');
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
  String get backendErrorTitle => _text('backendErrorTitle');
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
  String get notificationsTitle => _text('notificationsTitle');
  String get notificationsEmpty => _text('notificationsEmpty');
  String get notificationsLoadFailed => _text('notificationsLoadFailed');
  String get chatFallbackTitle => _text('chatFallbackTitle');
  String get userFallbackName => _text('userFallbackName');
  String get subjectFallbackName => _text('subjectFallbackName');
  String get teacherLabel => _text('teacherLabel');
  String get meLabel => _text('meLabel');
  String get groupLabel => _text('groupLabel');
  String get balanceLabel => _text('balanceLabel');
  String get childrenLabel => _text('childrenLabel');
  String get myChildrenTitle => _text('myChildrenTitle');
  String get noChildrenFound => _text('noChildrenFound');
  String get editProfileTitle => _text('editProfileTitle');
  String get changeAvatarAction => _text('changeAvatarAction');
  String get basicInfoTitle => _text('basicInfoTitle');
  String get notificationsToggleTitle => _text('notificationsToggleTitle');
  String get notificationsToggleSubtitle =>
      _text('notificationsToggleSubtitle');
  String get profileUpdatedSuccess => _text('profileUpdatedSuccess');
  String get achievementsTitle => _text('achievementsTitle');
  String get achievementsSubtitle => _text('achievementsSubtitle');
  String get conferencesTitle => _text('conferencesTitle');
  String get conferencesSubtitle => _text('conferencesSubtitle');
  String get absenceAppealTitle => _text('absenceAppealTitle');
  String get absenceAppealSubtitle => _text('absenceAppealSubtitle');
  String get digitalLibraryTitle => _text('digitalLibraryTitle');
  String get digitalLibrarySubtitle => _text('digitalLibrarySubtitle');
  String get personalInfoTitle => _text('personalInfoTitle');
  String get personalInfoSubtitle => _text('personalInfoSubtitle');
  String get passwordChangeTitle => _text('passwordChangeTitle');
  String get passwordChangeSubtitle => _text('passwordChangeSubtitle');
  String get chatSupportTitle => _text('chatSupportTitle');
  String get chatSupportSubtitle => _text('chatSupportSubtitle');
  String get notificationSettingsSubtitle =>
      _text('notificationSettingsSubtitle');
  String get aboutAppTitle => _text('aboutAppTitle');
  String get logoutTitle => _text('logoutTitle');
  String get logoutConfirmMessage => _text('logoutConfirmMessage');
  String get cancel => _text('cancel');
  String get logoutAction => _text('logoutAction');
  String get schoolAppName => _text('schoolAppName');
  String get conferenceTitle => _text('conferenceTitle');
  String get selectChildFirst => _text('selectChildFirst');
  String get conferenceBookedSuccess => _text('conferenceBookedSuccess');
  String get conferenceBookFailed => _text('conferenceBookFailed');
  String get invalidMeetingLink => _text('invalidMeetingLink');
  String get openMeetingLinkFailed => _text('openMeetingLinkFailed');
  String get conferenceEmpty => _text('conferenceEmpty');
  String get scheduleConferenceAction => _text('scheduleConferenceAction');
  String get availableSlotsTitle => _text('availableSlotsTitle');
  String get noAvailableSlots => _text('noAvailableSlots');
  String get noteOptional => _text('noteOptional');
  String get bookConferenceAction => _text('bookConferenceAction');
  String get absenceTitle => _text('absenceTitle');
  String get absenceNeedChild => _text('absenceNeedChild');
  String get submitRequestAction => _text('submitRequestAction');
  String get noRequestsYet => _text('noRequestsYet');
  String get requestStatusCaption => _text('requestStatusCaption');
  String get noReasonProvided => _text('noReasonProvided');
  String get fileAttached => _text('fileAttached');
  String get absenceRequestTitle => _text('absenceRequestTitle');
  String get startDateLabel => _text('startDateLabel');
  String get endDateLabel => _text('endDateLabel');
  String get reasonLabel => _text('reasonLabel');
  String get reasonHint => _text('reasonHint');
  String get attachFile => _text('attachFile');
  String get fileReady => _text('fileReady');
  String get reasonRequired => _text('reasonRequired');
  String get requestSubmitted => _text('requestSubmitted');
  String get requestSubmitFailed => _text('requestSubmitFailed');
  String get sendAction => _text('sendAction');
  String get libraryBooksTab => _text('libraryBooksTab');
  String get libraryMyBooksTab => _text('libraryMyBooksTab');
  String get librarySearchHint => _text('librarySearchHint');
  String get libraryNoBooksFound => _text('libraryNoBooksFound');
  String get libraryUnknownAuthor => _text('libraryUnknownAuthor');
  String get libraryBorrowAction => _text('libraryBorrowAction');
  String get libraryUnavailableAction => _text('libraryUnavailableAction');
  String get libraryNoLoans => _text('libraryNoLoans');
  String get libraryUnknownBook => _text('libraryUnknownBook');
  String get libraryReturnAction => _text('libraryReturnAction');
  String get libraryReturnedStatus => _text('libraryReturnedStatus');
  String get libraryBorrowedSuccess => _text('libraryBorrowedSuccess');
  String get libraryReturnedSuccess => _text('libraryReturnedSuccess');
  String get currentPasswordLabel => _text('currentPasswordLabel');
  String get newPasswordLabel => _text('newPasswordLabel');
  String get confirmPasswordLabel => _text('confirmPasswordLabel');
  String get saveAction => _text('saveAction');
  String get passwordUpdatedSuccess => _text('passwordUpdatedSuccess');
  String get forgotPasswordTitle => _text('forgotPasswordTitle');
  String get forgotPasswordPhoneSubtitle =>
      _text('forgotPasswordPhoneSubtitle');
  String get forgotPasswordCodeSubtitle => _text('forgotPasswordCodeSubtitle');
  String get phoneNumberSection => _text('phoneNumberSection');
  String get sendCodeAction => _text('sendCodeAction');
  String get backToLoginAction => _text('backToLoginAction');
  String get verificationCodeSection => _text('verificationCodeSection');
  String get verificationCodeHint => _text('verificationCodeHint');
  String get codeRequired => _text('codeRequired');
  String get codeLengthInvalid => _text('codeLengthInvalid');
  String get resetPasswordAction => _text('resetPasswordAction');
  String get resendCodeAction => _text('resendCodeAction');
  String get verificationCodeSent => _text('verificationCodeSent');
  String get verificationCodeSendFailed => _text('verificationCodeSendFailed');
  String get passwordResetSuccess => _text('passwordResetSuccess');
  String get passwordResetFailed => _text('passwordResetFailed');
  String get paymentsTitle => _text('paymentsTitle');
  String get accountBalanceTitle => _text('accountBalanceTitle');
  String get notUpdatedLabel => _text('notUpdatedLabel');
  String get todayLabel => _text('todayLabel');
  String get yesterdayLabel => _text('yesterdayLabel');
  String get tomorrowLabel => _text('tomorrowLabel');
  String get justNowLabel => _text('justNowLabel');
  String get noFinancialData => _text('noFinancialData');
  String get contractInfoTitle => _text('contractInfoTitle');
  String get contractLabel => _text('contractLabel');
  String get studentLabel => _text('studentLabel');
  String get classLabel => _text('classLabel');
  String get monthlyPaymentLabel => _text('monthlyPaymentLabel');
  String get debtExistsTitle => _text('debtExistsTitle');
  String get payNowAction => _text('payNowAction');
  String get paymentHistoryTitle => _text('paymentHistoryTitle');
  String get paymentHistoryEmpty => _text('paymentHistoryEmpty');
  String get paymentMethodTitle => _text('paymentMethodTitle');
  String get paymentAmountLabel => _text('paymentAmountLabel');
  String get paymentMethodsPrompt => _text('paymentMethodsPrompt');
  String get paymentAction => _text('paymentAction');
  String get paymentAgreementText => _text('paymentAgreementText');
  String get paymentAmountInvalid => _text('paymentAmountInvalid');
  String get paymentCreateUnsupported => _text('paymentCreateUnsupported');
  String get paymentRedirectOpenFallback =>
      _text('paymentRedirectOpenFallback');
  String get paymentLinkOpenFailed => _text('paymentLinkOpenFailed');
  String get paymentCreatedNoLink => _text('paymentCreatedNoLink');
  String get allPaymentsFilter => _text('allPaymentsFilter');
  String get successfulPaymentsFilter => _text('successfulPaymentsFilter');
  String get rejectedPaymentsFilter => _text('rejectedPaymentsFilter');
  String get paymentStatusPending => _text('paymentStatusPending');
  String get paymentStatusCompleted => _text('paymentStatusCompleted');
  String get paymentStatusFailed => _text('paymentStatusFailed');
  String get paymentStatusRefunded => _text('paymentStatusRefunded');
  String get paymentMethodCash => _text('paymentMethodCash');
  String get paymentMethodTransfer => _text('paymentMethodTransfer');
  String get currencyCode => _text('currencyCode');
  String get gradesTab => _text('gradesTab');
  String get ratingTab => _text('ratingTab');
  String get todayLessonsSectionTitle => _text('todayLessonsSectionTitle');
  String get viewAllAction => _text('viewAllAction');
  String get noLessonsTodayShort => _text('noLessonsTodayShort');
  String get servicesTitle => _text('servicesTitle');
  String get conferenceServiceTitle => _text('conferenceServiceTitle');
  String get absenceServiceTitle => _text('absenceServiceTitle');
  String get libraryServiceTitle => _text('libraryServiceTitle');
  String get ratingServiceTitle => _text('ratingServiceTitle');
  String get averageGradeTitle => _text('averageGradeTitle');
  String get classRankingTitle => _text('classRankingTitle');
  String get placeSuffix => _text('placeSuffix');
  String get attendanceStatLabel => _text('attendanceStatLabel');
  String get attendanceTitle => _text('attendanceTitle');
  String get attendanceTotalLessonsLabel =>
      _text('attendanceTotalLessonsLabel');
  String get attendancePresentLabel => _text('attendancePresentLabel');
  String get attendanceAbsentLabel => _text('attendanceAbsentLabel');
  String get attendancePresentLegend => _text('attendancePresentLegend');
  String get attendanceAbsentLegend => _text('attendanceAbsentLegend');
  String get attendanceLateLegend => _text('attendanceLateLegend');
  String get attendanceBackendErrorTitle =>
      _text('attendanceBackendErrorTitle');
  String get coinsStatLabel => _text('coinsStatLabel');
  String get latestNewsTitle => _text('latestNewsTitle');
  String get todayLunchTitle => _text('todayLunchTitle');
  String get todayLunchSubtitle => _text('todayLunchSubtitle');
  String get dailyMenuTitle => _text('dailyMenuTitle');
  String get noMenuOnSelectedDay => _text('noMenuOnSelectedDay');
  String get mealIngredientsTitle => _text('mealIngredientsTitle');
  String get chatsTitle => _text('chatsTitle');
  String get chatsEmpty => _text('chatsEmpty');
  String get noMessageShort => _text('noMessageShort');
  String get ratingTitle => _text('ratingTitle');
  String get classScopeTab => _text('classScopeTab');
  String get schoolScopeTab => _text('schoolScopeTab');
  String get ratingDataEmpty => _text('ratingDataEmpty');
  String get ratingListEmpty => _text('ratingListEmpty');
  String get ratingLoadFailed => _text('ratingLoadFailed');
  String get schoolRatingLoadFailed => _text('schoolRatingLoadFailed');
  String get leaderboardTitle => _text('leaderboardTitle');
  String get leaderboardClassTab => _text('leaderboardClassTab');
  String get leaderboardSchoolTab => _text('leaderboardSchoolTab');
  String get leaderboardBadgesTab => _text('leaderboardBadgesTab');
  String get leaderboardClassEmpty => _text('leaderboardClassEmpty');
  String get leaderboardSchoolEmpty => _text('leaderboardSchoolEmpty');
  String get myBadgesTitle => _text('myBadgesTitle');
  String get noBadgesYet => _text('noBadgesYet');
  String get scheduleTitle => _text('scheduleTitle');
  String get noScheduleAvailable => _text('noScheduleAvailable');
  String get currentLessonBadge => _text('currentLessonBadge');
  String get noClassLabel => _text('noClassLabel');
  String get assignmentsTab => _text('assignmentsTab');
  String get newAssignmentsTab => _text('newAssignmentsTab');
  String get allAssignmentsTab => _text('allAssignmentsTab');
  String get assignmentsEmpty => _text('assignmentsEmpty');
  String get assignmentStatusPending => _text('assignmentStatusPending');
  String get assignmentStatusSubmitted => _text('assignmentStatusSubmitted');
  String get assignmentStatusGraded => _text('assignmentStatusGraded');
  String get assignmentStatusOverdue => _text('assignmentStatusOverdue');
  String get assignmentSubmitAction => _text('assignmentSubmitAction');
  String get assignmentSubmitSoon => _text('assignmentSubmitSoon');
  String get myPerformanceTitle => _text('myPerformanceTitle');
  String get noGradesAvailable => _text('noGradesAvailable');
  String get gradesBySubjectTitle => _text('gradesBySubjectTitle');
  String get averageShortLabel => _text('averageShortLabel');
  String get overallPerformanceTitle => _text('overallPerformanceTitle');
  String get overallPerformanceSubtitle => _text('overallPerformanceSubtitle');
  String get lessonsStatLabel => _text('lessonsStatLabel');
  String get assignmentDetailsTitle => _text('assignmentDetailsTitle');
  String get assignmentNotFound => _text('assignmentNotFound');
  String get assignmentSelectFileFirst => _text('assignmentSelectFileFirst');
  String get assignmentStudentResolveFailed =>
      _text('assignmentStudentResolveFailed');
  String get assignmentSubmittedSuccess => _text('assignmentSubmittedSuccess');
  String get assignmentSubmitFailed => _text('assignmentSubmitFailed');
  String get assignmentTeacherFilesTitle =>
      _text('assignmentTeacherFilesTitle');
  String get assignmentNoTeacherFiles => _text('assignmentNoTeacherFiles');
  String get assignmentSubmittedFilesTitle =>
      _text('assignmentSubmittedFilesTitle');
  String get assignmentNotSubmittedYet => _text('assignmentNotSubmittedYet');
  String get chooseFileAction => _text('chooseFileAction');
  String get chooseAnotherFileAction => _text('chooseAnotherFileAction');
  String get chatOnlineStatus => _text('chatOnlineStatus');
  String get chatOfflineStatus => _text('chatOfflineStatus');
  String get refreshAction => _text('refreshAction');
  String get backToChatsAction => _text('backToChatsAction');
  String get chatMessageHint => _text('chatMessageHint');
  String get chatMessageSendFailed => _text('chatMessageSendFailed');
  String get chatFileSendFailed => _text('chatFileSendFailed');
  String get breakfastLabel => _text('breakfastLabel');
  String get lunchLabel => _text('lunchLabel');
  String get afternoonTeaLabel => _text('afternoonTeaLabel');
  String get dinnerLabel => _text('dinnerLabel');
  String get snackLabel => _text('snackLabel');
  String get gradesLoadFailed => _text('gradesLoadFailed');
  String get gradeSummaryLoadFailed => _text('gradeSummaryLoadFailed');
  String get scheduleLoadFailed => _text('scheduleLoadFailed');
  String get assignmentsLoadFailed => _text('assignmentsLoadFailed');
  String get assignmentDetailsLoadFailed =>
      _text('assignmentDetailsLoadFailed');
  String get assignmentUploadFailed => _text('assignmentUploadFailed');
  String get attendanceLoadFailed => _text('attendanceLoadFailed');
  String get attendanceSummaryLoadFailed =>
      _text('attendanceSummaryLoadFailed');
  String get menuLoadFailed => _text('menuLoadFailed');
  String get weeklyMenuLoadFailed => _text('weeklyMenuLoadFailed');
  String get conversationsLoadFailed => _text('conversationsLoadFailed');
  String get messagesLoadFailed => _text('messagesLoadFailed');
  String get profileUpdateFailed => _text('profileUpdateFailed');
  String get imageUploadFailed => _text('imageUploadFailed');
  String get childrenLoadFailed => _text('childrenLoadFailed');
  String get dataLoadFailed => _text('dataLoadFailed');
  String get changePasswordFailed => _text('changePasswordFailed');
  String get balanceLoadFailed => _text('balanceLoadFailed');
  String get paymentHistoryLoadFailed => _text('paymentHistoryLoadFailed');
  String get paymentCreateFailed => _text('paymentCreateFailed');
  String get paymentMethodsLoadFailed => _text('paymentMethodsLoadFailed');
  String get gradeTypeDaily => _text('gradeTypeDaily');
  String get gradeTypeExam => _text('gradeTypeExam');
  String get gradeTypeHomework => _text('gradeTypeHomework');
  String get gradeTypeTest => _text('gradeTypeTest');

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

  String phoneDisplay(String phone) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Tel: $phone';
      case AppLocale.ru:
        return 'Тел: $phone';
      case AppLocale.en:
        return 'Phone: $phone';
    }
  }

  String childrenCount(int count) {
    switch (appLocale) {
      case AppLocale.uz:
        return '$count ta';
      case AppLocale.ru:
        return '$count';
      case AppLocale.en:
        return '$count';
    }
  }

  String childClassText(String className) {
    switch (appLocale) {
      case AppLocale.uz:
        return '$className - Sinf';
      case AppLocale.ru:
        return '$className - Класс';
      case AppLocale.en:
        return '$className - Class';
    }
  }

  String groupText(String groupName) => '$groupLabel: $groupName';

  String minutesAgo(int count) {
    switch (appLocale) {
      case AppLocale.uz:
        return '$count daqiqa oldin';
      case AppLocale.ru:
        return '$count минут назад';
      case AppLocale.en:
        return count == 1 ? '1 minute ago' : '$count minutes ago';
    }
  }

  String hoursAgo(int count) {
    switch (appLocale) {
      case AppLocale.uz:
        return '$count soat oldin';
      case AppLocale.ru:
        return '$count часов назад';
      case AppLocale.en:
        return count == 1 ? '1 hour ago' : '$count hours ago';
    }
  }

  String daysAgo(int count) {
    switch (appLocale) {
      case AppLocale.uz:
        return '$count kun oldin';
      case AppLocale.ru:
        return '$count дней назад';
      case AppLocale.en:
        return count == 1 ? '1 day ago' : '$count days ago';
    }
  }

  String versionLabel(String version) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Versiya $version';
      case AppLocale.ru:
        return 'Версия $version';
      case AppLocale.en:
        return 'Version $version';
    }
  }

  String homeGreeting(String name) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Salom, $name';
      case AppLocale.ru:
        return 'Здравствуйте, $name';
      case AppLocale.en:
        return 'Hello, $name';
    }
  }

  String meetingWithTeacher(String teacherName) {
    switch (appLocale) {
      case AppLocale.uz:
        return '$teacherName bilan uchrashuv';
      case AppLocale.ru:
        return 'Встреча с $teacherName';
      case AppLocale.en:
        return 'Meeting with $teacherName';
    }
  }

  String availableSlotsCount(int count) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Bo\'sh slotlar ($count)';
      case AppLocale.ru:
        return 'Свободные слоты ($count)';
      case AppLocale.en:
        return 'Available slots ($count)';
    }
  }

  String conferenceStatusLabel(String status) {
    switch (status) {
      case 'booked':
        return appLocale == AppLocale.uz
            ? 'Band qilingan'
            : appLocale == AppLocale.ru
            ? 'Забронировано'
            : 'Booked';
      case 'approved':
        return appLocale == AppLocale.uz
            ? 'Tasdiqlangan'
            : appLocale == AppLocale.ru
            ? 'Подтверждено'
            : 'Approved';
      case 'cancelled':
        return appLocale == AppLocale.uz
            ? 'Bekor qilingan'
            : appLocale == AppLocale.ru
            ? 'Отменено'
            : 'Cancelled';
      case 'rejected':
        return appLocale == AppLocale.uz
            ? 'Rad etilgan'
            : appLocale == AppLocale.ru
            ? 'Отклонено'
            : 'Rejected';
      default:
        return status;
    }
  }

  String absenceStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return appLocale == AppLocale.uz
            ? 'Tasdiqlangan'
            : appLocale == AppLocale.ru
            ? 'Подтверждено'
            : 'Approved';
      case 'rejected':
        return appLocale == AppLocale.uz
            ? 'Rad etilgan'
            : appLocale == AppLocale.ru
            ? 'Отклонено'
            : 'Rejected';
      case 'pending':
        return appLocale == AppLocale.uz
            ? 'Kutilmoqda'
            : appLocale == AppLocale.ru
            ? 'Ожидается'
            : 'Pending';
      default:
        return status;
    }
  }

  String libraryLoanDates(String borrowedAt, String dueAt) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Olindi: $borrowedAt | Qaytish: $dueAt';
      case AppLocale.ru:
        return 'Выдано: $borrowedAt | Возврат: $dueAt';
      case AppLocale.en:
        return 'Borrowed: $borrowedAt | Due: $dueAt';
    }
  }

  String lastUpdatedLabel(String value) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Oxirgi yangilanish: $value';
      case AppLocale.ru:
        return 'Последнее обновление: $value';
      case AppLocale.en:
        return 'Last updated: $value';
    }
  }

  String debtPaymentPrompt(String amount) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Iltimos, $amount to\'lov qiling';
      case AppLocale.ru:
        return 'Пожалуйста, оплатите $amount';
      case AppLocale.en:
        return 'Please pay $amount';
    }
  }

  String paymentRecordTitle(int id) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'To\'lov #$id';
      case AppLocale.ru:
        return 'Платеж #$id';
      case AppLocale.en:
        return 'Payment #$id';
    }
  }

  String paymentStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return paymentStatusPending;
      case 'completed':
        return paymentStatusCompleted;
      case 'failed':
        return paymentStatusFailed;
      case 'refunded':
        return paymentStatusRefunded;
      default:
        return status;
    }
  }

  String paymentMethodLabelText(String method) {
    switch (method) {
      case 'payme':
        return 'PayMe';
      case 'click':
        return 'Click';
      case 'cash':
        return paymentMethodCash;
      case 'transfer':
        return paymentMethodTransfer;
      default:
        return method;
    }
  }

  String levelBadge(int level) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Lvl $level';
      case AppLocale.ru:
        return 'Ур. $level';
      case AppLocale.en:
        return 'Lvl $level';
    }
  }

  String scorePoints(num score) {
    final normalized = score % 1 == 0 ? score.toInt().toString() : '$score';

    switch (appLocale) {
      case AppLocale.uz:
        return '$normalized ball';
      case AppLocale.ru:
        return '$normalized балл';
      case AppLocale.en:
        return '$normalized pts';
    }
  }

  String roomLabelText(String room) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Xona: $room';
      case AppLocale.ru:
        return 'Кабинет: $room';
      case AppLocale.en:
        return 'Room: $room';
    }
  }

  String leaderboardCoins(int count) {
    switch (appLocale) {
      case AppLocale.uz:
        return '$count Tangalar';
      case AppLocale.ru:
        return '$count монет';
      case AppLocale.en:
        return '$count coins';
    }
  }

  String unlockableBadgesCount(int count) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Ochiladigan nishonlar: $count';
      case AppLocale.ru:
        return 'Доступные значки: $count';
      case AppLocale.en:
        return 'Unlockable badges: $count';
    }
  }

  String assignmentStatusLabel(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending:
        return assignmentStatusPending;
      case AssignmentStatus.submitted:
        return assignmentStatusSubmitted;
      case AssignmentStatus.graded:
        return assignmentStatusGraded;
      case AssignmentStatus.overdue:
        return assignmentStatusOverdue;
    }
  }

  String assignmentDueDateText(String dueDate) {
    switch (appLocale) {
      case AppLocale.uz:
        return 'Muddat: $dueDate';
      case AppLocale.ru:
        return 'Срок: $dueDate';
      case AppLocale.en:
        return 'Due: $dueDate';
    }
  }

  String assignmentStatusText(AssignmentStatus status) {
    final label = assignmentStatusLabel(status);

    switch (appLocale) {
      case AppLocale.uz:
        return 'Status: $label';
      case AppLocale.ru:
        return 'Статус: $label';
      case AppLocale.en:
        return 'Status: $label';
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
    'changeTheme': 'Mavzuni o\'zgartirish',
    'themeSystem': 'Tizim bo\'yicha',
    'themeLight': 'Yorug\'',
    'themeDark': 'Qorong\'u',
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
    'registerUnavailableMessage':
        'Tenant API da ro\'yxatdan o\'tish endpointi mavjud emas. Hisoblar administrator tomonidan yaratiladi.',
    'loginFailed': 'Kirish amalga oshmadi',
    'registerTitle': 'Ro\'yxatdan o\'tish',
    'registerSubtitle': 'Yangi hisob yaratish',
    'fullNameLabel': 'Ism Familiya',
    'fullNameHint': 'To\'liq ismingizni kiriting',
    'fullNameRequired': 'Iltimos, ismingizni kiriting',
    'phoneNumberLabel': 'Telefon raqam',
    'passwordLabel': 'Parol',
    'createAccountAction': 'Hisob yaratish',
    'haveAccountPrompt': 'Hisobingiz bormi?',
    'qrLoginTitle': 'QR Kod bilan kirish',
    'qrInvalidFormat': 'Noto\'g\'ri QR kod formati',
    'qrLoginFailed': 'QR orqali kirish amalga oshmadi',
    'qrScanInstruction': 'QR kodni kamera oldiga tuting',
    'qrAdminInstruction': 'Maktab administratori bergan QR kodni skanerlang',
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
    'backendErrorTitle': 'Backend xatoligi',
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
    'notificationsTitle': 'Bildirishnomalar',
    'notificationsEmpty': 'Bildirishnomalar yo\'q',
    'notificationsLoadFailed': 'Bildirishnomalarni yuklashda xatolik',
    'chatFallbackTitle': 'Chat',
    'userFallbackName': 'Foydalanuvchi',
    'subjectFallbackName': 'Fan',
    'teacherLabel': 'O\'qituvchi',
    'meLabel': 'Siz',
    'groupLabel': 'Guruh',
    'balanceLabel': 'Balans',
    'childrenLabel': 'Farzandlar',
    'myChildrenTitle': 'Farzandlarim',
    'noChildrenFound': 'Farzandlar topilmadi',
    'editProfileTitle': 'Shaxsiy ma\'lumotlar',
    'changeAvatarAction': 'Avatarni o\'zgartirish',
    'basicInfoTitle': 'Asosiy ma\'lumotlar',
    'notificationsToggleTitle': 'Bildirishnomalar',
    'notificationsToggleSubtitle': 'Push xabarnomalarni yoqish yoki o\'chirish',
    'profileUpdatedSuccess': 'Profil muvaffaqiyatli yangilandi.',
    'achievementsTitle': 'Yutuqlar va Nishonlar',
    'achievementsSubtitle': 'O\'yinlashtirilgan reyting',
    'conferencesTitle': 'Ota-onalar majlisi',
    'conferencesSubtitle': 'O\'qituvchi bilan uchrashuv belgilash',
    'absenceAppealTitle': 'E-Murojaat',
    'absenceAppealSubtitle': 'Davomat uzrlari',
    'digitalLibraryTitle': 'Raqamli Kutubxona',
    'digitalLibrarySubtitle': 'Darslik va kitoblar',
    'personalInfoTitle': 'Shaxsiy ma\'lumotlar',
    'personalInfoSubtitle': 'Profilingizni tahrirlash',
    'passwordChangeTitle': 'Parolni o\'zgartirish',
    'passwordChangeSubtitle': 'Xavfsizlik sozlamalari',
    'chatSupportTitle': 'Chat / Yordam',
    'chatSupportSubtitle': 'Qo\'llab-quvvatlash xizmati',
    'notificationSettingsSubtitle': 'Bildirishnoma sozlamalari',
    'aboutAppTitle': 'Ilova haqida',
    'logoutTitle': 'Tizimdan chiqish',
    'logoutConfirmMessage': 'Rostdan ham tizimdan chiqmoqchimisiz?',
    'cancel': 'Bekor qilish',
    'logoutAction': 'Chiqish',
    'schoolAppName': 'E-School',
    'conferenceTitle': 'Ota-onalar majlisi',
    'selectChildFirst': 'Avval farzandni tanlang',
    'conferenceBookedSuccess': 'Uchrashuv muvaffaqiyatli belgilandi',
    'conferenceBookFailed': 'Majlisni belgilab bo\'lmadi',
    'invalidMeetingLink': 'Majlis havolasi noto\'g\'ri',
    'openMeetingLinkFailed': 'Majlis havolasini ochib bo\'lmadi',
    'conferenceEmpty': 'Hali majlis bron qilinmagan',
    'scheduleConferenceAction': 'Majlis belgilash',
    'availableSlotsTitle': 'Bo\'sh uchrashuv slotlari',
    'noAvailableSlots': 'Hozircha bo\'sh slotlar topilmadi',
    'noteOptional': 'Izoh (ixtiyoriy)',
    'bookConferenceAction': 'Majlisni belgilash',
    'absenceTitle': 'E-Murojaat (Davomat)',
    'absenceNeedChild': 'Davomat murojaatini yuborish uchun farzandni tanlang.',
    'submitRequestAction': 'Murojaat qoldirish',
    'noRequestsYet': 'Hozircha arizalar yo\'q',
    'requestStatusCaption':
        'Sababnoma yuborsangiz, statusi shu yerda ko\'rinadi.',
    'noReasonProvided': 'Sabab ko\'rsatilmagan',
    'fileAttached': 'Fayl biriktirilgan',
    'absenceRequestTitle': 'Davomat uchun murojaat qoldirish',
    'startDateLabel': 'Boshlanish sanasi',
    'endDateLabel': 'Tugash sanasi',
    'reasonLabel': 'Sabab',
    'reasonHint': 'Sababni qisqacha yozing',
    'attachFile': 'Fayl biriktirish',
    'fileReady': 'Fayl tayyor',
    'reasonRequired': 'Sababni kiriting',
    'requestSubmitted': 'Murojaat yuborildi',
    'requestSubmitFailed': 'Murojaat yuborilmadi',
    'sendAction': 'Yuborish',
    'libraryBooksTab': 'Kitoblar',
    'libraryMyBooksTab': 'Mening kitoblarim',
    'librarySearchHint': 'Kitob qidirish...',
    'libraryNoBooksFound': 'Kitoblar topilmadi',
    'libraryUnknownAuthor': 'Muallif noma\'lum',
    'libraryBorrowAction': 'Olish',
    'libraryUnavailableAction': 'Mavjud emas',
    'libraryNoLoans': 'Sizda olingan kitoblar yo\'q',
    'libraryUnknownBook': 'Noma\'lum kitob',
    'libraryReturnAction': 'Qaytarish',
    'libraryReturnedStatus': 'Qaytarilgan',
    'libraryBorrowedSuccess': 'Kitob band qilindi!',
    'libraryReturnedSuccess': 'Kitob qaytarildi!',
    'currentPasswordLabel': 'Joriy parol',
    'newPasswordLabel': 'Yangi parol',
    'confirmPasswordLabel': 'Parolni tasdiqlang',
    'saveAction': 'Saqlash',
    'passwordUpdatedSuccess': 'Parol muvaffaqiyatli o\'zgartirildi!',
    'forgotPasswordTitle': 'Parolni tiklash',
    'forgotPasswordPhoneSubtitle': 'Telefon raqamingizni kiriting',
    'forgotPasswordCodeSubtitle': 'SMS orqali kelgan kodni kiriting',
    'phoneNumberSection': 'TELEFON RAQAM',
    'sendCodeAction': 'Kod yuborish',
    'backToLoginAction': 'Kirish sahifasiga qaytish',
    'verificationCodeSection': 'TASDIQLASH KODI',
    'verificationCodeHint': '123456',
    'codeRequired': 'Kodni kiriting',
    'codeLengthInvalid': 'Kod 6 xonali bo\'lishi kerak',
    'resetPasswordAction': 'Parolni yangilash',
    'resendCodeAction': 'Qaytadan kod yuborish',
    'verificationCodeSent': 'Tasdiqlash kodi yuborildi',
    'verificationCodeSendFailed': 'Tasdiqlash kodini yuborishda xatolik',
    'passwordResetSuccess': 'Parol muvaffaqiyatli yangilandi!',
    'passwordResetFailed': 'Parolni yangilashda xatolik',
    'paymentsTitle': 'To\'lovlar',
    'accountBalanceTitle': 'Hisob balansi',
    'notUpdatedLabel': 'Yangilanmagan',
    'todayLabel': 'Bugun',
    'yesterdayLabel': 'Kecha',
    'tomorrowLabel': 'Ertaga',
    'justNowLabel': 'Hozirgina',
    'noFinancialData': 'Ma\'lumot yo\'q',
    'contractInfoTitle': 'Shartnoma ma\'lumotlari',
    'contractLabel': 'Shartnoma',
    'studentLabel': 'O\'quvchi',
    'classLabel': 'Sinf',
    'monthlyPaymentLabel': 'Oylik to\'lov',
    'debtExistsTitle': 'Qarzdorlik mavjud',
    'payNowAction': 'Hozir to\'lash',
    'paymentHistoryTitle': 'To\'lovlar tarixi',
    'paymentHistoryEmpty': 'To\'lovlar tarixi bo\'sh',
    'paymentMethodTitle': 'To\'lov usuli',
    'paymentAmountLabel': 'To\'lov summasi (UZS)',
    'paymentMethodsPrompt': 'Xo\'sh, qanday to\'laymiz?',
    'paymentAction': 'To\'lovni amalga oshirish',
    'paymentAgreementText':
        'Tugmani bosish orqali siz ommaviy oferta shartlariga rozilik bildirasiz.',
    'paymentAmountInvalid': 'To\'lov summasini to\'g\'ri kiriting',
    'paymentCreateUnsupported':
        'Parent API da to\'lov yaratish qo\'llab-quvvatlanmaydi.',
    'paymentRedirectOpenFallback':
        'Ilovani ochishda xatolik yuz berdi. Iltimos brauzer orqali urining.',
    'paymentLinkOpenFailed': 'To\'lov havolasiga o\'tib bo\'lmadi',
    'paymentCreatedNoLink': 'To\'lov yaratildi, ammo link olinmadi',
    'allPaymentsFilter': 'Hammasi',
    'successfulPaymentsFilter': 'Muvaffaqiyatli',
    'rejectedPaymentsFilter': 'Rad etilgan',
    'paymentStatusPending': 'Kutilmoqda',
    'paymentStatusCompleted': 'Muvaffaqiyatli',
    'paymentStatusFailed': 'Muvaffaqiyatsiz',
    'paymentStatusRefunded': 'Qaytarilgan',
    'paymentMethodCash': 'Naqd',
    'paymentMethodTransfer': 'O\'tkazma',
    'currencyCode': 'UZS',
    'gradesTab': 'Baholar',
    'ratingTab': 'Reyting',
    'todayLessonsSectionTitle': 'Bugungi darslar',
    'viewAllAction': 'Barchasi',
    'noLessonsTodayShort': 'Bugun darslar topilmadi',
    'servicesTitle': 'Xizmatlar',
    'conferenceServiceTitle': 'Uchrashuv',
    'absenceServiceTitle': 'Sababnoma',
    'libraryServiceTitle': 'Kutubxona',
    'ratingServiceTitle': 'Reyting',
    'averageGradeTitle': 'O\'rtacha baho',
    'classRankingTitle': 'Sinf reytingi',
    'placeSuffix': 'o\'rin',
    'attendanceStatLabel': 'Davomat',
    'attendanceTitle': 'Davomat statistikasi',
    'attendanceTotalLessonsLabel': 'Jami darslar',
    'attendancePresentLabel': 'Qatnashdi',
    'attendanceAbsentLabel': 'Sababsiz',
    'attendancePresentLegend': 'Bor',
    'attendanceAbsentLegend': 'Yo\'q',
    'attendanceLateLegend': 'Kechikkan',
    'attendanceBackendErrorTitle': 'Backend xatoligi',
    'coinsStatLabel': 'Coinlar',
    'latestNewsTitle': 'So\'nggi yangilik',
    'todayLunchTitle': 'Bugungi tushlik',
    'todayLunchSubtitle': 'Oshxonada yangi taomlar tayyorlandi',
    'dailyMenuTitle': 'Ovqat menyusi',
    'noMenuOnSelectedDay': 'Tanlangan kun uchun menyu mavjud emas',
    'mealIngredientsTitle': 'Tarkibi:',
    'chatsTitle': 'Chatlar',
    'chatsEmpty': 'Chatlar hozircha yo\'q',
    'noMessageShort': 'Xabar yo\'q',
    'ratingTitle': 'Reyting',
    'classScopeTab': 'Sinfda',
    'schoolScopeTab': 'Maktabda',
    'ratingDataEmpty': 'Ma\'lumot yo\'q',
    'ratingListEmpty': 'Reyting ma\'lumotlari topilmadi',
    'ratingLoadFailed': 'Reytingni yuklashda xatolik',
    'schoolRatingLoadFailed': 'Maktab reytingini yuklashda xatolik',
    'leaderboardTitle': 'Liderlar jadvali',
    'leaderboardClassTab': 'Sinf',
    'leaderboardSchoolTab': 'Maktab',
    'leaderboardBadgesTab': 'Nishonlar',
    'leaderboardClassEmpty': 'Sinf reytingi hozircha yo\'q',
    'leaderboardSchoolEmpty': 'Maktab reytingi hozircha yo\'q',
    'myBadgesTitle': 'Mening nishonlarim',
    'noBadgesYet': 'Hali nishonlar yo\'q',
    'scheduleTitle': 'Dars jadvali',
    'noScheduleAvailable': 'Darslar mavjud emas',
    'currentLessonBadge': 'Hozir',
    'noClassLabel': 'Sinf yo\'q',
    'assignmentsTab': 'Vazifalar',
    'newAssignmentsTab': 'Yangi vazifalar',
    'allAssignmentsTab': 'Barchasi',
    'assignmentsEmpty': 'Vazifalar topilmadi',
    'assignmentStatusPending': 'Jarayonda',
    'assignmentStatusSubmitted': 'Topshirilgan',
    'assignmentStatusGraded': 'Baholangan',
    'assignmentStatusOverdue': 'Muddati o\'tgan',
    'assignmentSubmitAction': 'Yuborish',
    'assignmentSubmitSoon': 'Vazifa yuborish funksiyasi tez orada...',
    'myPerformanceTitle': 'Mening ko\'rsatkichlarim',
    'noGradesAvailable': 'Baholar mavjud emas',
    'gradesBySubjectTitle': 'Fanlar bo\'yicha',
    'averageShortLabel': 'O\'rtacha',
    'overallPerformanceTitle': 'Umumiy o\'zlashtirish',
    'overallPerformanceSubtitle': 'Fanlar bo\'yicha umumiy natijangiz',
    'lessonsStatLabel': 'Darslar',
    'assignmentDetailsTitle': 'Vazifa tafsilotlari',
    'assignmentNotFound': 'Vazifa topilmadi',
    'assignmentSelectFileFirst': 'Avval fayl tanlang',
    'assignmentStudentResolveFailed':
        'Vazifa uchun o\'quvchi aniqlanmadi. Qayta urinib ko\'ring.',
    'assignmentSubmittedSuccess': 'Vazifa muvaffaqiyatli yuborildi',
    'assignmentSubmitFailed': 'Yuborishda xatolik',
    'assignmentTeacherFilesTitle': 'O\'qituvchi fayllari',
    'assignmentNoTeacherFiles': 'Biriktirilgan fayl yo\'q',
    'assignmentSubmittedFilesTitle': 'Yuborilgan fayllar',
    'assignmentNotSubmittedYet': 'Hali yuborilmagan',
    'chooseFileAction': 'Fayl tanlash',
    'chooseAnotherFileAction': 'Boshqa fayl tanlash',
    'chatOnlineStatus': 'Onlayn',
    'chatOfflineStatus': 'Oflayn',
    'refreshAction': 'Yangilash',
    'backToChatsAction': 'Chatlar ro\'yxatiga qaytish',
    'chatMessageHint': 'Xabar yozing...',
    'chatMessageSendFailed': 'Xabar yuborilmadi',
    'chatFileSendFailed': 'Fayl yuborilmadi',
    'breakfastLabel': 'Nonushta',
    'lunchLabel': 'Tushlik',
    'afternoonTeaLabel': 'Poldnik',
    'dinnerLabel': 'Kechki ovqat',
    'snackLabel': 'Tamaddi',
    'gradesLoadFailed': 'Baholarni yuklashda xatolik',
    'gradeSummaryLoadFailed': 'Baholar xulosasini yuklashda xatolik',
    'scheduleLoadFailed': 'Jadvalni yuklashda xatolik',
    'assignmentsLoadFailed': 'Topshiriqlarni yuklashda xatolik',
    'assignmentDetailsLoadFailed': 'Topshiriq tafsilotlarini yuklashda xatolik',
    'assignmentUploadFailed': 'Fayl yuklashda xatolik',
    'attendanceLoadFailed': 'Davomatni yuklashda xatolik',
    'attendanceSummaryLoadFailed': 'Davomat xulosasini yuklashda xatolik',
    'menuLoadFailed': 'Menyuni yuklashda xatolik',
    'weeklyMenuLoadFailed': 'Haftalik menyuni yuklashda xatolik',
    'conversationsLoadFailed': 'Suhbatlarni yuklashda xatolik',
    'messagesLoadFailed': 'Xabarlarni yuklashda xatolik',
    'profileUpdateFailed': 'Profilni yangilashda xatolik',
    'imageUploadFailed': 'Rasm yuklashda xatolik',
    'childrenLoadFailed': 'Farzandlarni yuklashda xatolik',
    'dataLoadFailed': 'Ma\'lumot yuklashda xatolik',
    'changePasswordFailed': 'Parolni o\'zgartishda xatolik',
    'balanceLoadFailed': 'Balansni yuklashda xatolik',
    'paymentHistoryLoadFailed': 'To\'lovlar tarixini yuklashda xatolik',
    'paymentCreateFailed': 'To\'lov yaratishda xatolik',
    'paymentMethodsLoadFailed': 'To\'lov usullarini yuklashda xatolik',
    'gradeTypeDaily': 'Kunlik',
    'gradeTypeExam': 'Imtihon',
    'gradeTypeHomework': 'Uy vazifasi',
    'gradeTypeTest': 'Test',
  },
  'ru': {
    'appName': 'Ranch School Parent',
    'notificationFallbackTitle': 'Новое уведомление',
    'close': 'Закрыть',
    'changeLanguage': 'Сменить язык',
    'changeTheme': 'Сменить тему',
    'themeSystem': 'Как в системе',
    'themeLight': 'Светлая',
    'themeDark': 'Тёмная',
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
    'registerUnavailableMessage':
        'В tenant API нет endpoint для регистрации. Аккаунты создаются администратором.',
    'loginFailed': 'Не удалось войти',
    'registerTitle': 'Регистрация',
    'registerSubtitle': 'Создать новый аккаунт',
    'fullNameLabel': 'Имя и фамилия',
    'fullNameHint': 'Введите полное имя',
    'fullNameRequired': 'Пожалуйста, введите ваше имя',
    'phoneNumberLabel': 'Номер телефона',
    'passwordLabel': 'Пароль',
    'createAccountAction': 'Создать аккаунт',
    'haveAccountPrompt': 'У вас уже есть аккаунт?',
    'qrLoginTitle': 'Вход по QR-коду',
    'qrInvalidFormat': 'Неверный формат QR-кода',
    'qrLoginFailed': 'Не удалось войти через QR',
    'qrScanInstruction': 'Поднесите QR-код к камере',
    'qrAdminInstruction': 'Отсканируйте QR-код, выданный администратором школы',
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
    'backendErrorTitle': 'Ошибка backend',
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
    'notificationsTitle': 'Уведомления',
    'notificationsEmpty': 'Уведомлений пока нет',
    'notificationsLoadFailed': 'Не удалось загрузить уведомления',
    'chatFallbackTitle': 'Чат',
    'userFallbackName': 'Пользователь',
    'subjectFallbackName': 'Предмет',
    'teacherLabel': 'Учитель',
    'meLabel': 'Вы',
    'groupLabel': 'Группа',
    'balanceLabel': 'Баланс',
    'childrenLabel': 'Дети',
    'myChildrenTitle': 'Мои дети',
    'noChildrenFound': 'Дети не найдены',
    'editProfileTitle': 'Личные данные',
    'changeAvatarAction': 'Изменить аватар',
    'basicInfoTitle': 'Основная информация',
    'notificationsToggleTitle': 'Уведомления',
    'notificationsToggleSubtitle': 'Включить или отключить push-уведомления',
    'profileUpdatedSuccess': 'Профиль успешно обновлен.',
    'achievementsTitle': 'Достижения и значки',
    'achievementsSubtitle': 'Игровой рейтинг',
    'conferencesTitle': 'Родительское собрание',
    'conferencesSubtitle': 'Запись на встречу с учителем',
    'absenceAppealTitle': 'Э-обращение',
    'absenceAppealSubtitle': 'Оправдания по посещаемости',
    'digitalLibraryTitle': 'Цифровая библиотека',
    'digitalLibrarySubtitle': 'Учебники и книги',
    'personalInfoTitle': 'Личные данные',
    'personalInfoSubtitle': 'Редактирование профиля',
    'passwordChangeTitle': 'Изменить пароль',
    'passwordChangeSubtitle': 'Настройки безопасности',
    'chatSupportTitle': 'Чат / Поддержка',
    'chatSupportSubtitle': 'Служба поддержки',
    'notificationSettingsSubtitle': 'Настройки уведомлений',
    'aboutAppTitle': 'О приложении',
    'logoutTitle': 'Выйти из системы',
    'logoutConfirmMessage': 'Вы действительно хотите выйти из системы?',
    'cancel': 'Отмена',
    'logoutAction': 'Выйти',
    'schoolAppName': 'E-School',
    'conferenceTitle': 'Родительское собрание',
    'selectChildFirst': 'Сначала выберите ребенка',
    'conferenceBookedSuccess': 'Встреча успешно назначена',
    'conferenceBookFailed': 'Не удалось назначить встречу',
    'invalidMeetingLink': 'Ссылка на встречу некорректна',
    'openMeetingLinkFailed': 'Не удалось открыть ссылку на встречу',
    'conferenceEmpty': 'Встреч пока не забронировано',
    'scheduleConferenceAction': 'Назначить встречу',
    'availableSlotsTitle': 'Свободные слоты для встречи',
    'noAvailableSlots': 'Свободные слоты пока не найдены',
    'noteOptional': 'Комментарий (необязательно)',
    'bookConferenceAction': 'Назначить встречу',
    'absenceTitle': 'Э-обращение (посещаемость)',
    'absenceNeedChild':
        'Выберите ребенка, чтобы отправить обращение по посещаемости.',
    'submitRequestAction': 'Оставить обращение',
    'noRequestsYet': 'Заявок пока нет',
    'requestStatusCaption':
        'После отправки обращения его статус появится здесь.',
    'noReasonProvided': 'Причина не указана',
    'fileAttached': 'Файл прикреплен',
    'absenceRequestTitle': 'Оставить обращение по посещаемости',
    'startDateLabel': 'Дата начала',
    'endDateLabel': 'Дата окончания',
    'reasonLabel': 'Причина',
    'reasonHint': 'Кратко опишите причину',
    'attachFile': 'Прикрепить файл',
    'fileReady': 'Файл готов',
    'reasonRequired': 'Укажите причину',
    'requestSubmitted': 'Обращение отправлено',
    'requestSubmitFailed': 'Не удалось отправить обращение',
    'sendAction': 'Отправить',
    'libraryBooksTab': 'Книги',
    'libraryMyBooksTab': 'Мои книги',
    'librarySearchHint': 'Поиск книги...',
    'libraryNoBooksFound': 'Книги не найдены',
    'libraryUnknownAuthor': 'Автор неизвестен',
    'libraryBorrowAction': 'Взять',
    'libraryUnavailableAction': 'Нет в наличии',
    'libraryNoLoans': 'У вас нет взятых книг',
    'libraryUnknownBook': 'Неизвестная книга',
    'libraryReturnAction': 'Вернуть',
    'libraryReturnedStatus': 'Возвращено',
    'libraryBorrowedSuccess': 'Книга забронирована!',
    'libraryReturnedSuccess': 'Книга возвращена!',
    'currentPasswordLabel': 'Текущий пароль',
    'newPasswordLabel': 'Новый пароль',
    'confirmPasswordLabel': 'Подтвердите пароль',
    'saveAction': 'Сохранить',
    'passwordUpdatedSuccess': 'Пароль успешно изменен!',
    'forgotPasswordTitle': 'Восстановление пароля',
    'forgotPasswordPhoneSubtitle': 'Введите номер телефона',
    'forgotPasswordCodeSubtitle': 'Введите код из SMS',
    'phoneNumberSection': 'НОМЕР ТЕЛЕФОНА',
    'sendCodeAction': 'Отправить код',
    'backToLoginAction': 'Вернуться ко входу',
    'verificationCodeSection': 'КОД ПОДТВЕРЖДЕНИЯ',
    'verificationCodeHint': '123456',
    'codeRequired': 'Введите код',
    'codeLengthInvalid': 'Код должен состоять из 6 цифр',
    'resetPasswordAction': 'Обновить пароль',
    'resendCodeAction': 'Отправить код повторно',
    'verificationCodeSent': 'Код подтверждения отправлен',
    'verificationCodeSendFailed': 'Не удалось отправить код подтверждения',
    'passwordResetSuccess': 'Пароль успешно обновлен!',
    'passwordResetFailed': 'Не удалось обновить пароль',
    'paymentsTitle': 'Платежи',
    'accountBalanceTitle': 'Баланс счета',
    'notUpdatedLabel': 'Не обновлялось',
    'todayLabel': 'Сегодня',
    'yesterdayLabel': 'Вчера',
    'tomorrowLabel': 'Завтра',
    'justNowLabel': 'Только что',
    'noFinancialData': 'Нет данных',
    'contractInfoTitle': 'Информация по договору',
    'contractLabel': 'Договор',
    'studentLabel': 'Ученик',
    'classLabel': 'Класс',
    'monthlyPaymentLabel': 'Ежемесячный платеж',
    'debtExistsTitle': 'Есть задолженность',
    'payNowAction': 'Оплатить сейчас',
    'paymentHistoryTitle': 'История платежей',
    'paymentHistoryEmpty': 'История платежей пуста',
    'paymentMethodTitle': 'Способ оплаты',
    'paymentAmountLabel': 'Сумма платежа (UZS)',
    'paymentMethodsPrompt': 'Как вы хотите оплатить?',
    'paymentAction': 'Перейти к оплате',
    'paymentAgreementText':
        'Нажимая кнопку, вы соглашаетесь с условиями публичной оферты.',
    'paymentAmountInvalid': 'Введите корректную сумму платежа',
    'paymentCreateUnsupported':
        'Создание платежа пока не поддерживается в Parent API.',
    'paymentRedirectOpenFallback':
        'Не удалось открыть приложение. Попробуйте открыть ссылку в браузере.',
    'paymentLinkOpenFailed': 'Не удалось перейти по платежной ссылке',
    'paymentCreatedNoLink': 'Платеж создан, но ссылка не получена',
    'allPaymentsFilter': 'Все',
    'successfulPaymentsFilter': 'Успешные',
    'rejectedPaymentsFilter': 'Отклоненные',
    'paymentStatusPending': 'Ожидается',
    'paymentStatusCompleted': 'Успешно',
    'paymentStatusFailed': 'Неуспешно',
    'paymentStatusRefunded': 'Возвращено',
    'paymentMethodCash': 'Наличные',
    'paymentMethodTransfer': 'Перевод',
    'currencyCode': 'UZS',
    'gradesTab': 'Оценки',
    'ratingTab': 'Рейтинг',
    'todayLessonsSectionTitle': 'Сегодняшние уроки',
    'viewAllAction': 'Все',
    'noLessonsTodayShort': 'На сегодня уроки не найдены',
    'servicesTitle': 'Сервисы',
    'conferenceServiceTitle': 'Встреча',
    'absenceServiceTitle': 'Причина',
    'libraryServiceTitle': 'Библиотека',
    'ratingServiceTitle': 'Рейтинг',
    'averageGradeTitle': 'Средняя оценка',
    'classRankingTitle': 'Рейтинг в классе',
    'placeSuffix': 'место',
    'attendanceStatLabel': 'Посещаемость',
    'attendanceTitle': 'Статистика посещаемости',
    'attendanceTotalLessonsLabel': 'Всего уроков',
    'attendancePresentLabel': 'Присутствовал',
    'attendanceAbsentLabel': 'Без причины',
    'attendancePresentLegend': 'Был',
    'attendanceAbsentLegend': 'Не был',
    'attendanceLateLegend': 'Опоздал',
    'attendanceBackendErrorTitle': 'Ошибка backend',
    'coinsStatLabel': 'Монеты',
    'latestNewsTitle': 'Последняя новость',
    'todayLunchTitle': 'Сегодняшний обед',
    'todayLunchSubtitle': 'В столовой приготовили новые блюда',
    'dailyMenuTitle': 'Меню питания',
    'noMenuOnSelectedDay': 'На выбранный день меню недоступно',
    'mealIngredientsTitle': 'Состав:',
    'chatsTitle': 'Чаты',
    'chatsEmpty': 'Чатов пока нет',
    'noMessageShort': 'Нет сообщений',
    'ratingTitle': 'Рейтинг',
    'classScopeTab': 'В классе',
    'schoolScopeTab': 'В школе',
    'ratingDataEmpty': 'Нет данных',
    'ratingListEmpty': 'Данные рейтинга не найдены',
    'ratingLoadFailed': 'Не удалось загрузить рейтинг',
    'schoolRatingLoadFailed': 'Не удалось загрузить школьный рейтинг',
    'leaderboardTitle': 'Таблица лидеров',
    'leaderboardClassTab': 'Класс',
    'leaderboardSchoolTab': 'Школа',
    'leaderboardBadgesTab': 'Значки',
    'leaderboardClassEmpty': 'Рейтинг класса пока недоступен',
    'leaderboardSchoolEmpty': 'Школьный рейтинг пока недоступен',
    'myBadgesTitle': 'Мои значки',
    'noBadgesYet': 'Значков пока нет',
    'scheduleTitle': 'Расписание уроков',
    'noScheduleAvailable': 'Расписание недоступно',
    'currentLessonBadge': 'Сейчас',
    'noClassLabel': 'Класс не указан',
    'assignmentsTab': 'Задания',
    'newAssignmentsTab': 'Новые задания',
    'allAssignmentsTab': 'Все',
    'assignmentsEmpty': 'Задания не найдены',
    'assignmentStatusPending': 'В процессе',
    'assignmentStatusSubmitted': 'Сдано',
    'assignmentStatusGraded': 'Оценено',
    'assignmentStatusOverdue': 'Просрочено',
    'assignmentSubmitAction': 'Отправить',
    'assignmentSubmitSoon': 'Функция отправки задания скоро появится...',
    'myPerformanceTitle': 'Мои показатели',
    'noGradesAvailable': 'Оценок пока нет',
    'gradesBySubjectTitle': 'По предметам',
    'averageShortLabel': 'Среднее',
    'overallPerformanceTitle': 'Общая успеваемость',
    'overallPerformanceSubtitle': 'Ваш общий результат по предметам',
    'lessonsStatLabel': 'Уроки',
    'assignmentDetailsTitle': 'Детали задания',
    'assignmentNotFound': 'Задание не найдено',
    'assignmentSelectFileFirst': 'Сначала выберите файл',
    'assignmentStudentResolveFailed':
        'Не удалось определить ученика для задания. Попробуйте еще раз.',
    'assignmentSubmittedSuccess': 'Задание успешно отправлено',
    'assignmentSubmitFailed': 'Не удалось отправить задание',
    'assignmentTeacherFilesTitle': 'Файлы учителя',
    'assignmentNoTeacherFiles': 'Прикрепленных файлов нет',
    'assignmentSubmittedFilesTitle': 'Отправленные файлы',
    'assignmentNotSubmittedYet': 'Пока не отправлено',
    'chooseFileAction': 'Выбрать файл',
    'chooseAnotherFileAction': 'Выбрать другой файл',
    'chatOnlineStatus': 'Онлайн',
    'chatOfflineStatus': 'Не в сети',
    'refreshAction': 'Обновить',
    'backToChatsAction': 'Вернуться к списку чатов',
    'chatMessageHint': 'Введите сообщение...',
    'chatMessageSendFailed': 'Не удалось отправить сообщение',
    'chatFileSendFailed': 'Не удалось отправить файл',
    'breakfastLabel': 'Завтрак',
    'lunchLabel': 'Обед',
    'afternoonTeaLabel': 'Полдник',
    'dinnerLabel': 'Ужин',
    'snackLabel': 'Перекус',
    'gradesLoadFailed': 'Не удалось загрузить оценки',
    'gradeSummaryLoadFailed': 'Не удалось загрузить сводку оценок',
    'scheduleLoadFailed': 'Не удалось загрузить расписание',
    'assignmentsLoadFailed': 'Не удалось загрузить задания',
    'assignmentDetailsLoadFailed': 'Не удалось загрузить детали задания',
    'assignmentUploadFailed': 'Не удалось загрузить файл',
    'attendanceLoadFailed': 'Не удалось загрузить посещаемость',
    'attendanceSummaryLoadFailed': 'Не удалось загрузить сводку посещаемости',
    'menuLoadFailed': 'Не удалось загрузить меню',
    'weeklyMenuLoadFailed': 'Не удалось загрузить недельное меню',
    'conversationsLoadFailed': 'Не удалось загрузить чаты',
    'messagesLoadFailed': 'Не удалось загрузить сообщения',
    'profileUpdateFailed': 'Не удалось обновить профиль',
    'imageUploadFailed': 'Не удалось загрузить изображение',
    'childrenLoadFailed': 'Не удалось загрузить детей',
    'dataLoadFailed': 'Не удалось загрузить данные',
    'changePasswordFailed': 'Не удалось изменить пароль',
    'balanceLoadFailed': 'Не удалось загрузить баланс',
    'paymentHistoryLoadFailed': 'Не удалось загрузить историю платежей',
    'paymentCreateFailed': 'Не удалось создать платеж',
    'paymentMethodsLoadFailed': 'Не удалось загрузить способы оплаты',
    'gradeTypeDaily': 'Ежедневная',
    'gradeTypeExam': 'Экзамен',
    'gradeTypeHomework': 'Домашнее задание',
    'gradeTypeTest': 'Тест',
  },
  'en': {
    'appName': 'Ranch School Parent',
    'notificationFallbackTitle': 'New notification',
    'close': 'Close',
    'changeLanguage': 'Change language',
    'changeTheme': 'Change theme',
    'themeSystem': 'System',
    'themeLight': 'Light',
    'themeDark': 'Dark',
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
    'registerUnavailableMessage':
        'The tenant API does not provide a registration endpoint. Accounts are created by the administrator.',
    'loginFailed': 'Login failed',
    'registerTitle': 'Create account',
    'registerSubtitle': 'Set up a new account',
    'fullNameLabel': 'Full name',
    'fullNameHint': 'Enter your full name',
    'fullNameRequired': 'Please enter your name',
    'phoneNumberLabel': 'Phone number',
    'passwordLabel': 'Password',
    'createAccountAction': 'Create account',
    'haveAccountPrompt': 'Already have an account?',
    'qrLoginTitle': 'Sign in with QR code',
    'qrInvalidFormat': 'Invalid QR code format',
    'qrLoginFailed': 'QR sign-in failed',
    'qrScanInstruction': 'Hold the QR code in front of the camera',
    'qrAdminInstruction':
        'Scan the QR code provided by the school administrator',
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
    'backendErrorTitle': 'Backend error',
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
    'notificationsTitle': 'Notifications',
    'notificationsEmpty': 'No notifications yet',
    'notificationsLoadFailed': 'Failed to load notifications',
    'chatFallbackTitle': 'Chat',
    'userFallbackName': 'User',
    'subjectFallbackName': 'Subject',
    'teacherLabel': 'Teacher',
    'meLabel': 'You',
    'groupLabel': 'Group',
    'balanceLabel': 'Balance',
    'childrenLabel': 'Children',
    'myChildrenTitle': 'My children',
    'noChildrenFound': 'No children found',
    'editProfileTitle': 'Personal information',
    'changeAvatarAction': 'Change avatar',
    'basicInfoTitle': 'Basic information',
    'notificationsToggleTitle': 'Notifications',
    'notificationsToggleSubtitle': 'Enable or disable push notifications',
    'profileUpdatedSuccess': 'Profile updated successfully.',
    'achievementsTitle': 'Achievements & Badges',
    'achievementsSubtitle': 'Gamified ranking',
    'conferencesTitle': 'Parent Meetings',
    'conferencesSubtitle': 'Schedule a meeting with the teacher',
    'absenceAppealTitle': 'E-Request',
    'absenceAppealSubtitle': 'Attendance excuses',
    'digitalLibraryTitle': 'Digital Library',
    'digitalLibrarySubtitle': 'Textbooks and books',
    'personalInfoTitle': 'Personal information',
    'personalInfoSubtitle': 'Edit your profile',
    'passwordChangeTitle': 'Change password',
    'passwordChangeSubtitle': 'Security settings',
    'chatSupportTitle': 'Chat / Support',
    'chatSupportSubtitle': 'Support service',
    'notificationSettingsSubtitle': 'Notification settings',
    'aboutAppTitle': 'About the app',
    'logoutTitle': 'Log out',
    'logoutConfirmMessage': 'Do you really want to log out?',
    'cancel': 'Cancel',
    'logoutAction': 'Log out',
    'schoolAppName': 'E-School',
    'conferenceTitle': 'Parent meetings',
    'selectChildFirst': 'Select a child first',
    'conferenceBookedSuccess': 'Meeting scheduled successfully',
    'conferenceBookFailed': 'Failed to schedule the meeting',
    'invalidMeetingLink': 'The meeting link is invalid',
    'openMeetingLinkFailed': 'Failed to open the meeting link',
    'conferenceEmpty': 'No meetings have been booked yet',
    'scheduleConferenceAction': 'Schedule meeting',
    'availableSlotsTitle': 'Available meeting slots',
    'noAvailableSlots': 'No available slots found yet',
    'noteOptional': 'Note (optional)',
    'bookConferenceAction': 'Schedule meeting',
    'absenceTitle': 'E-request (attendance)',
    'absenceNeedChild': 'Select a child to submit an attendance request.',
    'submitRequestAction': 'Create request',
    'noRequestsYet': 'No requests yet',
    'requestStatusCaption':
        'Once you submit an excuse request, its status will appear here.',
    'noReasonProvided': 'No reason provided',
    'fileAttached': 'File attached',
    'absenceRequestTitle': 'Create attendance request',
    'startDateLabel': 'Start date',
    'endDateLabel': 'End date',
    'reasonLabel': 'Reason',
    'reasonHint': 'Briefly describe the reason',
    'attachFile': 'Attach file',
    'fileReady': 'File ready',
    'reasonRequired': 'Enter the reason',
    'requestSubmitted': 'Request submitted',
    'requestSubmitFailed': 'Failed to submit the request',
    'sendAction': 'Send',
    'libraryBooksTab': 'Books',
    'libraryMyBooksTab': 'My books',
    'librarySearchHint': 'Search books...',
    'libraryNoBooksFound': 'No books found',
    'libraryUnknownAuthor': 'Unknown author',
    'libraryBorrowAction': 'Borrow',
    'libraryUnavailableAction': 'Unavailable',
    'libraryNoLoans': 'You have no borrowed books',
    'libraryUnknownBook': 'Unknown book',
    'libraryReturnAction': 'Return',
    'libraryReturnedStatus': 'Returned',
    'libraryBorrowedSuccess': 'Book reserved!',
    'libraryReturnedSuccess': 'Book returned!',
    'currentPasswordLabel': 'Current password',
    'newPasswordLabel': 'New password',
    'confirmPasswordLabel': 'Confirm password',
    'saveAction': 'Save',
    'passwordUpdatedSuccess': 'Password updated successfully!',
    'forgotPasswordTitle': 'Reset password',
    'forgotPasswordPhoneSubtitle': 'Enter your phone number',
    'forgotPasswordCodeSubtitle': 'Enter the code sent via SMS',
    'phoneNumberSection': 'PHONE NUMBER',
    'sendCodeAction': 'Send code',
    'backToLoginAction': 'Back to login',
    'verificationCodeSection': 'VERIFICATION CODE',
    'verificationCodeHint': '123456',
    'codeRequired': 'Enter the code',
    'codeLengthInvalid': 'The code must be 6 digits long',
    'resetPasswordAction': 'Update password',
    'resendCodeAction': 'Send code again',
    'verificationCodeSent': 'Verification code sent',
    'verificationCodeSendFailed': 'Failed to send the verification code',
    'passwordResetSuccess': 'Password updated successfully!',
    'passwordResetFailed': 'Failed to update the password',
    'paymentsTitle': 'Payments',
    'accountBalanceTitle': 'Account balance',
    'notUpdatedLabel': 'Not updated',
    'todayLabel': 'Today',
    'yesterdayLabel': 'Yesterday',
    'tomorrowLabel': 'Tomorrow',
    'justNowLabel': 'Just now',
    'noFinancialData': 'No data',
    'contractInfoTitle': 'Contract information',
    'contractLabel': 'Contract',
    'studentLabel': 'Student',
    'classLabel': 'Class',
    'monthlyPaymentLabel': 'Monthly payment',
    'debtExistsTitle': 'Outstanding debt',
    'payNowAction': 'Pay now',
    'paymentHistoryTitle': 'Payment history',
    'paymentHistoryEmpty': 'Payment history is empty',
    'paymentMethodTitle': 'Payment method',
    'paymentAmountLabel': 'Payment amount (UZS)',
    'paymentMethodsPrompt': 'How would you like to pay?',
    'paymentAction': 'Proceed to payment',
    'paymentAgreementText':
        'By pressing the button, you agree to the terms of the public offer.',
    'paymentAmountInvalid': 'Enter a valid payment amount',
    'paymentCreateUnsupported':
        'Payment creation is not yet supported in the Parent API.',
    'paymentRedirectOpenFallback':
        'Failed to open the app. Please try the link in a browser.',
    'paymentLinkOpenFailed': 'Could not open the payment link',
    'paymentCreatedNoLink': 'Payment was created, but no link was returned',
    'allPaymentsFilter': 'All',
    'successfulPaymentsFilter': 'Successful',
    'rejectedPaymentsFilter': 'Rejected',
    'paymentStatusPending': 'Pending',
    'paymentStatusCompleted': 'Completed',
    'paymentStatusFailed': 'Failed',
    'paymentStatusRefunded': 'Refunded',
    'paymentMethodCash': 'Cash',
    'paymentMethodTransfer': 'Transfer',
    'currencyCode': 'UZS',
    'gradesTab': 'Grades',
    'ratingTab': 'Rating',
    'todayLessonsSectionTitle': 'Today\'s classes',
    'viewAllAction': 'View all',
    'noLessonsTodayShort': 'No classes found for today',
    'servicesTitle': 'Services',
    'conferenceServiceTitle': 'Meeting',
    'absenceServiceTitle': 'Absence note',
    'libraryServiceTitle': 'Library',
    'ratingServiceTitle': 'Rating',
    'averageGradeTitle': 'Average grade',
    'classRankingTitle': 'Class ranking',
    'placeSuffix': 'place',
    'attendanceStatLabel': 'Attendance',
    'attendanceTitle': 'Attendance statistics',
    'attendanceTotalLessonsLabel': 'Total lessons',
    'attendancePresentLabel': 'Present',
    'attendanceAbsentLabel': 'Unexcused',
    'attendancePresentLegend': 'Present',
    'attendanceAbsentLegend': 'Absent',
    'attendanceLateLegend': 'Late',
    'attendanceBackendErrorTitle': 'Backend error',
    'coinsStatLabel': 'Coins',
    'latestNewsTitle': 'Latest update',
    'todayLunchTitle': 'Today\'s lunch',
    'todayLunchSubtitle': 'Fresh meals are ready in the cafeteria',
    'dailyMenuTitle': 'Meal menu',
    'noMenuOnSelectedDay': 'No menu is available for the selected day',
    'mealIngredientsTitle': 'Ingredients:',
    'chatsTitle': 'Chats',
    'chatsEmpty': 'No chats yet',
    'noMessageShort': 'No messages',
    'ratingTitle': 'Rating',
    'classScopeTab': 'Class',
    'schoolScopeTab': 'School',
    'ratingDataEmpty': 'No data',
    'ratingListEmpty': 'No rating data found',
    'ratingLoadFailed': 'Failed to load the rating',
    'schoolRatingLoadFailed': 'Failed to load the school rating',
    'leaderboardTitle': 'Leaderboard',
    'leaderboardClassTab': 'Class',
    'leaderboardSchoolTab': 'School',
    'leaderboardBadgesTab': 'Badges',
    'leaderboardClassEmpty': 'No class ranking yet',
    'leaderboardSchoolEmpty': 'No school ranking yet',
    'myBadgesTitle': 'My badges',
    'noBadgesYet': 'No badges yet',
    'scheduleTitle': 'Class schedule',
    'noScheduleAvailable': 'No classes available',
    'currentLessonBadge': 'Now',
    'noClassLabel': 'No class',
    'assignmentsTab': 'Assignments',
    'newAssignmentsTab': 'New assignments',
    'allAssignmentsTab': 'All',
    'assignmentsEmpty': 'No assignments found',
    'assignmentStatusPending': 'In progress',
    'assignmentStatusSubmitted': 'Submitted',
    'assignmentStatusGraded': 'Graded',
    'assignmentStatusOverdue': 'Overdue',
    'assignmentSubmitAction': 'Submit',
    'assignmentSubmitSoon': 'Assignment submission is coming soon...',
    'myPerformanceTitle': 'My performance',
    'noGradesAvailable': 'No grades available',
    'gradesBySubjectTitle': 'By subject',
    'averageShortLabel': 'Average',
    'overallPerformanceTitle': 'Overall performance',
    'overallPerformanceSubtitle': 'Your overall result across subjects',
    'lessonsStatLabel': 'Lessons',
    'assignmentDetailsTitle': 'Assignment details',
    'assignmentNotFound': 'Assignment not found',
    'assignmentSelectFileFirst': 'Select a file first',
    'assignmentStudentResolveFailed':
        'Could not determine the student for this assignment. Please try again.',
    'assignmentSubmittedSuccess': 'Assignment submitted successfully',
    'assignmentSubmitFailed': 'Failed to submit the assignment',
    'assignmentTeacherFilesTitle': 'Teacher files',
    'assignmentNoTeacherFiles': 'No files attached',
    'assignmentSubmittedFilesTitle': 'Submitted files',
    'assignmentNotSubmittedYet': 'Not submitted yet',
    'chooseFileAction': 'Choose file',
    'chooseAnotherFileAction': 'Choose another file',
    'chatOnlineStatus': 'Online',
    'chatOfflineStatus': 'Offline',
    'refreshAction': 'Refresh',
    'backToChatsAction': 'Back to chats',
    'chatMessageHint': 'Type a message...',
    'chatMessageSendFailed': 'Message was not sent',
    'chatFileSendFailed': 'File was not sent',
    'breakfastLabel': 'Breakfast',
    'lunchLabel': 'Lunch',
    'afternoonTeaLabel': 'Afternoon tea',
    'dinnerLabel': 'Dinner',
    'snackLabel': 'Snack',
    'gradesLoadFailed': 'Failed to load grades',
    'gradeSummaryLoadFailed': 'Failed to load the grade summary',
    'scheduleLoadFailed': 'Failed to load the schedule',
    'assignmentsLoadFailed': 'Failed to load assignments',
    'assignmentDetailsLoadFailed': 'Failed to load assignment details',
    'assignmentUploadFailed': 'Failed to upload the file',
    'attendanceLoadFailed': 'Failed to load attendance',
    'attendanceSummaryLoadFailed': 'Failed to load the attendance summary',
    'menuLoadFailed': 'Failed to load the menu',
    'weeklyMenuLoadFailed': 'Failed to load the weekly menu',
    'conversationsLoadFailed': 'Failed to load conversations',
    'messagesLoadFailed': 'Failed to load messages',
    'profileUpdateFailed': 'Failed to update the profile',
    'imageUploadFailed': 'Failed to upload the image',
    'childrenLoadFailed': 'Failed to load children',
    'dataLoadFailed': 'Failed to load the data',
    'changePasswordFailed': 'Failed to change the password',
    'balanceLoadFailed': 'Failed to load the balance',
    'paymentHistoryLoadFailed': 'Failed to load the payment history',
    'paymentCreateFailed': 'Failed to create the payment',
    'paymentMethodsLoadFailed': 'Failed to load payment methods',
    'gradeTypeDaily': 'Daily',
    'gradeTypeExam': 'Exam',
    'gradeTypeHomework': 'Homework',
    'gradeTypeTest': 'Test',
  },
};
