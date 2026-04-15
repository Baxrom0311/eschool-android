// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Ranch School Parent';

  @override
  String get notificationFallbackTitle => 'Новое уведомление';

  @override
  String get close => 'Закрыть';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get changeTheme => 'Сменить тему';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get loginHeader => 'Вход';

  @override
  String get homeScreen => 'Главный экран';

  @override
  String get welcome => 'Добро пожаловать!';

  @override
  String get loginHint => 'Введите данные,\nчтобы войти в систему';

  @override
  String get emailSection => 'НОМЕР ТЕЛЕФОНА';

  @override
  String get passwordSection => 'ПАРОЛЬ';

  @override
  String get emailExample => 'Например: 90 123 45 67';

  @override
  String get forgotPasswordShort => 'Забыли пароль?';

  @override
  String get loginButton => 'Войти';

  @override
  String get orLabel => 'ИЛИ';

  @override
  String get googleLabel => 'Google';

  @override
  String get qrCodeLabel => 'QR-код';

  @override
  String get googleSoon => 'Вход через Google скоро будет доступен';

  @override
  String get accountCreatedByAdmin => 'Аккаунт создается администратором';

  @override
  String get registerUnavailableMessage =>
      'В tenant API нет endpoint для регистрации. Аккаунты создаются администратором.';

  @override
  String get loginFailed => 'Не удалось войти';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSubtitle => 'Создать новый аккаунт';

  @override
  String get fullNameLabel => 'Имя и фамилия';

  @override
  String get fullNameHint => 'Введите полное имя';

  @override
  String get fullNameRequired => 'Пожалуйста, введите ваше имя';

  @override
  String get phoneNumberLabel => 'Номер телефона';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get createAccountAction => 'Создать аккаунт';

  @override
  String get haveAccountPrompt => 'У вас уже есть аккаунт?';

  @override
  String get qrLoginTitle => 'Вход по QR-коду';

  @override
  String get qrInvalidFormat => 'Неверный формат QR-кода';

  @override
  String get qrLoginFailed => 'Не удалось войти через QR';

  @override
  String get qrScanInstruction => 'Поднесите QR-код к камере';

  @override
  String get qrAdminInstruction =>
      'Отсканируйте QR-код, выданный администратором школы';

  @override
  String get profileLoadError => 'Не удалось загрузить профиль';

  @override
  String get home => 'Главная';

  @override
  String get academics => 'Учёба';

  @override
  String get menu => 'Питание';

  @override
  String get paymentShort => 'Оплата';

  @override
  String get profile => 'Профиль';

  @override
  String get homeTitle => 'E-School';

  @override
  String get academicsTitle => 'Учёба';

  @override
  String get retry => 'Повторить';

  @override
  String get noData => 'Нет данных';

  @override
  String get noInternet => 'Нет подключения к интернету';

  @override
  String get backendErrorTitle => 'Ошибка backend';

  @override
  String get errorGeneric => 'Что-то пошло не так';

  @override
  String get errorServer => 'Ошибка сервера';

  @override
  String get errorAuth => 'Неверный логин или пароль';

  @override
  String get fieldRequired => 'Обязательное поле';

  @override
  String get phoneRequired => 'Введите номер телефона';

  @override
  String get invalidPhone => 'Неверный номер телефона';

  @override
  String get emailRequired => 'Введите номер телефона';

  @override
  String get invalidEmail => 'Неверный номер телефона';

  @override
  String get passwordRequired => 'Введите пароль';

  @override
  String get passwordTooShort => 'Пароль должен содержать минимум 6 символов';

  @override
  String get confirmPasswordRequired => 'Подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get requestTimeout =>
      'Время ожидания ответа сервера истекло. Повторите попытку.';

  @override
  String get requestCancelled => 'Запрос отменен';

  @override
  String get badRequest => 'Некорректный запрос';

  @override
  String get forbidden => 'Доступ запрещен';

  @override
  String get notFound => 'Данные не найдены';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmpty => 'Уведомлений пока нет';

  @override
  String get notificationsLoadFailed => 'Не удалось загрузить уведомления';

  @override
  String get chatFallbackTitle => 'Чат';

  @override
  String get userFallbackName => 'Пользователь';

  @override
  String get subjectFallbackName => 'Предмет';

  @override
  String get teacherLabel => 'Учитель';

  @override
  String get meLabel => 'Вы';

  @override
  String get groupLabel => 'Группа';

  @override
  String get balanceLabel => 'Баланс';

  @override
  String get childrenLabel => 'Дети';

  @override
  String get myChildrenTitle => 'Мои дети';

  @override
  String get noChildrenFound => 'Дети не найдены';

  @override
  String get editProfileTitle => 'Личные данные';

  @override
  String get changeAvatarAction => 'Изменить аватар';

  @override
  String get basicInfoTitle => 'Основная информация';

  @override
  String get notificationsToggleTitle => 'Уведомления';

  @override
  String get notificationsToggleSubtitle =>
      'Включить или отключить push-уведомления';

  @override
  String get profileUpdatedSuccess => 'Профиль успешно обновлен.';

  @override
  String get achievementsTitle => 'Достижения и значки';

  @override
  String get achievementsSubtitle => 'Игровой рейтинг';

  @override
  String get conferencesTitle => 'Родительское собрание';

  @override
  String get conferencesSubtitle => 'Запись на встречу с учителем';

  @override
  String get absenceAppealTitle => 'Э-обращение';

  @override
  String get absenceAppealSubtitle => 'Оправдания по посещаемости';

  @override
  String get digitalLibraryTitle => 'Цифровая библиотека';

  @override
  String get digitalLibrarySubtitle => 'Учебники и книги';

  @override
  String get personalInfoTitle => 'Личные данные';

  @override
  String get personalInfoSubtitle => 'Редактирование профиля';

  @override
  String get passwordChangeTitle => 'Изменить пароль';

  @override
  String get passwordChangeSubtitle => 'Настройки безопасности';

  @override
  String get chatSupportTitle => 'Чат / Поддержка';

  @override
  String get chatSupportSubtitle => 'Служба поддержки';

  @override
  String get notificationSettingsSubtitle => 'Настройки уведомлений';

  @override
  String get aboutAppTitle => 'О приложении';

  @override
  String get logoutTitle => 'Выйти из системы';

  @override
  String get logoutConfirmMessage =>
      'Вы действительно хотите выйти из системы?';

  @override
  String get cancel => 'Отмена';

  @override
  String get logoutAction => 'Выйти';

  @override
  String get schoolAppName => 'E-School';

  @override
  String get conferenceTitle => 'Родительское собрание';

  @override
  String get selectChildFirst => 'Сначала выберите ребенка';

  @override
  String get conferenceBookedSuccess => 'Встреча успешно назначена';

  @override
  String get conferenceBookFailed => 'Не удалось назначить встречу';

  @override
  String get invalidMeetingLink => 'Ссылка на встречу некорректна';

  @override
  String get openMeetingLinkFailed => 'Не удалось открыть ссылку на встречу';

  @override
  String get conferenceEmpty => 'Встреч пока не забронировано';

  @override
  String get scheduleConferenceAction => 'Назначить встречу';

  @override
  String get availableSlotsTitle => 'Свободные слоты для встречи';

  @override
  String get noAvailableSlots => 'Свободные слоты пока не найдены';

  @override
  String get noteOptional => 'Комментарий (необязательно)';

  @override
  String get bookConferenceAction => 'Назначить встречу';

  @override
  String get absenceTitle => 'Э-обращение (посещаемость)';

  @override
  String get absenceNeedChild =>
      'Выберите ребенка, чтобы отправить обращение по посещаемости.';

  @override
  String get submitRequestAction => 'Оставить обращение';

  @override
  String get noRequestsYet => 'Заявок пока нет';

  @override
  String get requestStatusCaption =>
      'После отправки обращения его статус появится здесь.';

  @override
  String get noReasonProvided => 'Причина не указана';

  @override
  String get fileAttached => 'Файл прикреплен';

  @override
  String get absenceRequestTitle => 'Оставить обращение по посещаемости';

  @override
  String get startDateLabel => 'Дата начала';

  @override
  String get endDateLabel => 'Дата окончания';

  @override
  String get reasonLabel => 'Причина';

  @override
  String get reasonHint => 'Кратко опишите причину';

  @override
  String get attachFile => 'Прикрепить файл';

  @override
  String get fileReady => 'Файл готов';

  @override
  String get reasonRequired => 'Укажите причину';

  @override
  String get requestSubmitted => 'Обращение отправлено';

  @override
  String get requestSubmitFailed => 'Не удалось отправить обращение';

  @override
  String get sendAction => 'Отправить';

  @override
  String get libraryBooksTab => 'Книги';

  @override
  String get libraryMyBooksTab => 'Мои книги';

  @override
  String get librarySearchHint => 'Поиск книги...';

  @override
  String get libraryNoBooksFound => 'Книги не найдены';

  @override
  String get libraryUnknownAuthor => 'Автор неизвестен';

  @override
  String get libraryBorrowAction => 'Взять';

  @override
  String get libraryUnavailableAction => 'Нет в наличии';

  @override
  String get libraryNoLoans => 'У вас нет взятых книг';

  @override
  String get libraryUnknownBook => 'Неизвестная книга';

  @override
  String get libraryReturnAction => 'Вернуть';

  @override
  String get libraryReturnedStatus => 'Возвращено';

  @override
  String get libraryBorrowedSuccess => 'Книга забронирована!';

  @override
  String get libraryReturnedSuccess => 'Книга возвращена!';

  @override
  String get currentPasswordLabel => 'Текущий пароль';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get confirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get saveAction => 'Сохранить';

  @override
  String get passwordUpdatedSuccess => 'Пароль успешно изменен!';

  @override
  String get forgotPasswordTitle => 'Восстановление пароля';

  @override
  String get forgotPasswordPhoneSubtitle => 'Введите номер телефона';

  @override
  String get forgotPasswordCodeSubtitle => 'Введите код из SMS';

  @override
  String get phoneNumberSection => 'НОМЕР ТЕЛЕФОНА';

  @override
  String get sendCodeAction => 'Отправить код';

  @override
  String get backToLoginAction => 'Вернуться ко входу';

  @override
  String get verificationCodeSection => 'КОД ПОДТВЕРЖДЕНИЯ';

  @override
  String get verificationCodeHint => '123456';

  @override
  String get codeRequired => 'Введите код';

  @override
  String get codeLengthInvalid => 'Код должен состоять из 6 цифр';

  @override
  String get resetPasswordAction => 'Обновить пароль';

  @override
  String get resendCodeAction => 'Отправить код повторно';

  @override
  String get verificationCodeSent => 'Код подтверждения отправлен';

  @override
  String get verificationCodeSendFailed =>
      'Не удалось отправить код подтверждения';

  @override
  String get passwordResetSuccess => 'Пароль успешно обновлен!';

  @override
  String get passwordResetFailed => 'Не удалось обновить пароль';

  @override
  String get paymentsTitle => 'Платежи';

  @override
  String get accountBalanceTitle => 'Баланс счета';

  @override
  String get notUpdatedLabel => 'Не обновлялось';

  @override
  String get todayLabel => 'Сегодня';

  @override
  String get yesterdayLabel => 'Вчера';

  @override
  String get tomorrowLabel => 'Завтра';

  @override
  String get justNowLabel => 'Только что';

  @override
  String get noFinancialData => 'Нет данных';

  @override
  String get contractInfoTitle => 'Информация по договору';

  @override
  String get contractLabel => 'Договор';

  @override
  String get studentLabel => 'Ученик';

  @override
  String get classLabel => 'Класс';

  @override
  String get monthlyPaymentLabel => 'Ежемесячный платеж';

  @override
  String get debtExistsTitle => 'Есть задолженность';

  @override
  String debtPaymentPrompt(Object amount) {
    return 'Обнаружена задолженность в размере $amount. Пожалуйста, произведите оплату, чтобы избежать перебоев в обслуживании.';
  }

  @override
  String get payNowAction => 'Оплатить сейчас';

  @override
  String get paymentHistoryTitle => 'История платежей';

  @override
  String get paymentHistoryEmpty => 'История платежей пуста';

  @override
  String get paymentMethodTitle => 'Способ оплаты';

  @override
  String get paymentAmountLabel => 'Сумма платежа (UZS)';

  @override
  String get paymentMethodsPrompt => 'Как вы хотите оплатить?';

  @override
  String get paymentAction => 'Перейти к оплате';

  @override
  String get paymentAgreementText =>
      'Нажимая кнопку, вы соглашаетесь с условиями публичной оферты.';

  @override
  String get paymentAmountInvalid => 'Введите корректную сумму платежа';

  @override
  String get paymentCreateUnsupported =>
      'Создание платежа пока не поддерживается в Parent API.';

  @override
  String get paymentRedirectOpenFallback =>
      'Не удалось открыть приложение. Попробуйте открыть ссылку в браузере.';

  @override
  String get paymentLinkOpenFailed => 'Не удалось перейти по платежной ссылке';

  @override
  String get paymentCreatedNoLink => 'Платеж создан, но ссылка не получена';

  @override
  String get allPaymentsFilter => 'Все';

  @override
  String get successfulPaymentsFilter => 'Успешные';

  @override
  String get rejectedPaymentsFilter => 'Отклоненные';

  @override
  String get paymentStatusPending => 'Ожидается';

  @override
  String get paymentStatusCompleted => 'Успешно';

  @override
  String get paymentStatusFailed => 'Неуспешно';

  @override
  String get paymentStatusRefunded => 'Возвращено';

  @override
  String get paymentMethodCash => 'Наличные';

  @override
  String get paymentMethodTransfer => 'Перевод';

  @override
  String get currencyCode => 'UZS';

  @override
  String get gradesTab => 'Оценки';

  @override
  String get ratingTab => 'Рейтинг';

  @override
  String get todayLessonsSectionTitle => 'Сегодняшние уроки';

  @override
  String get viewAllAction => 'Все';

  @override
  String get noLessonsTodayShort => 'На сегодня уроки не найдены';

  @override
  String get servicesTitle => 'Сервисы';

  @override
  String get conferenceServiceTitle => 'Встреча';

  @override
  String get absenceServiceTitle => 'Причина';

  @override
  String get libraryServiceTitle => 'Библиотека';

  @override
  String get ratingServiceTitle => 'Рейтинг';

  @override
  String get averageGradeTitle => 'Средняя оценка';

  @override
  String get classRankingTitle => 'Рейтинг в классе';

  @override
  String get placeSuffix => 'место';

  @override
  String get attendanceStatLabel => 'Посещаемость';

  @override
  String get attendanceTitle => 'Статистика посещаемости';

  @override
  String get attendanceTotalLessonsLabel => 'Всего уроков';

  @override
  String get attendancePresentLabel => 'Присутствовал';

  @override
  String get attendanceAbsentLabel => 'Без причины';

  @override
  String get attendancePresentLegend => 'Был';

  @override
  String get attendanceAbsentLegend => 'Не был';

  @override
  String get attendanceLateLegend => 'Опоздал';

  @override
  String get attendanceBackendErrorTitle => 'Ошибка backend';

  @override
  String get coinsStatLabel => 'Монеты';

  @override
  String get latestNewsTitle => 'Последняя новость';

  @override
  String get todayLunchTitle => 'Сегодняшний обед';

  @override
  String get todayLunchSubtitle => 'В столовой приготовили новые блюда';

  @override
  String get dailyMenuTitle => 'Меню питания';

  @override
  String get noMenuOnSelectedDay => 'На выбранный день меню недоступно';

  @override
  String get mealIngredientsTitle => 'Состав:';

  @override
  String get chatsTitle => 'Чаты';

  @override
  String get chatsEmpty => 'Чатов пока нет';

  @override
  String get noMessageShort => 'Нет сообщений';

  @override
  String get ratingTitle => 'Рейтинг';

  @override
  String get classScopeTab => 'В классе';

  @override
  String get schoolScopeTab => 'В школе';

  @override
  String get ratingDataEmpty => 'Нет данных';

  @override
  String get ratingListEmpty => 'Данные рейтинга не найдены';

  @override
  String get ratingLoadFailed => 'Не удалось загрузить рейтинг';

  @override
  String get schoolRatingLoadFailed => 'Не удалось загрузить школьный рейтинг';

  @override
  String get leaderboardTitle => 'Таблица лидеров';

  @override
  String get leaderboardClassTab => 'Класс';

  @override
  String get leaderboardSchoolTab => 'Школа';

  @override
  String get leaderboardBadgesTab => 'Значки';

  @override
  String get leaderboardClassEmpty => 'Рейтинг класса пока недоступен';

  @override
  String get leaderboardSchoolEmpty => 'Школьный рейтинг пока недоступен';

  @override
  String get myBadgesTitle => 'Мои значки';

  @override
  String get noBadgesYet => 'Значков пока нет';

  @override
  String get scheduleTitle => 'Расписание уроков';

  @override
  String get noScheduleAvailable => 'Расписание недоступно';

  @override
  String get currentLessonBadge => 'Сейчас';

  @override
  String get noClassLabel => 'Класс не указан';

  @override
  String get assignmentsTab => 'Задания';

  @override
  String get newAssignmentsTab => 'Новые задания';

  @override
  String get allAssignmentsTab => 'Все';

  @override
  String get assignmentsEmpty => 'Задания не найдены';

  @override
  String get assignmentStatusPending => 'В процессе';

  @override
  String get assignmentStatusSubmitted => 'Сдано';

  @override
  String get assignmentStatusGraded => 'Оценено';

  @override
  String get assignmentStatusOverdue => 'Просрочено';

  @override
  String get assignmentSubmitAction => 'Отправить';

  @override
  String get assignmentSubmitSoon =>
      'Функция отправки задания скоро появится...';

  @override
  String get myPerformanceTitle => 'Мои показатели';

  @override
  String get noGradesAvailable => 'Оценок пока нет';

  @override
  String get gradesBySubjectTitle => 'По предметам';

  @override
  String get averageShortLabel => 'Среднее';

  @override
  String get overallPerformanceTitle => 'Общая успеваемость';

  @override
  String get overallPerformanceSubtitle => 'Ваш общий результат по предметам';

  @override
  String get lessonsStatLabel => 'Уроки';

  @override
  String get assignmentDetailsTitle => 'Детали задания';

  @override
  String get assignmentNotFound => 'Задание не найдено';

  @override
  String get assignmentSelectFileFirst => 'Сначала выберите файл';

  @override
  String get assignmentStudentResolveFailed =>
      'Не удалось определить ученика для задания. Попробуйте еще раз.';

  @override
  String get assignmentSubmittedSuccess => 'Задание успешно отправлено';

  @override
  String get assignmentSubmitFailed => 'Не удалось отправить задание';

  @override
  String get assignmentTeacherFilesTitle => 'Файлы учителя';

  @override
  String get assignmentNoTeacherFiles => 'Прикрепленных файлов нет';

  @override
  String get assignmentSubmittedFilesTitle => 'Отправленные файлы';

  @override
  String get assignmentNotSubmittedYet => 'Пока не отправлено';

  @override
  String get chooseFileAction => 'Выбрать файл';

  @override
  String get chooseAnotherFileAction => 'Выбрать другой файл';

  @override
  String get chatOnlineStatus => 'Онлайн';

  @override
  String get chatOfflineStatus => 'Не в сети';

  @override
  String get refreshAction => 'Обновить';

  @override
  String get backToChatsAction => 'Вернуться к списку чатов';

  @override
  String get chatMessageHint => 'Введите сообщение...';

  @override
  String get chatMessageSendFailed => 'Не удалось отправить сообщение';

  @override
  String get chatFileSendFailed => 'Не удалось отправить файл';

  @override
  String get breakfastLabel => 'Завтрак';

  @override
  String get lunchLabel => 'Обед';

  @override
  String get afternoonTeaLabel => 'Полдник';

  @override
  String get dinnerLabel => 'Ужин';

  @override
  String get snackLabel => 'Перекус';

  @override
  String get gradesLoadFailed => 'Не удалось загрузить оценки';

  @override
  String get gradeSummaryLoadFailed => 'Не удалось загрузить сводку оценок';

  @override
  String get scheduleLoadFailed => 'Не удалось загрузить расписание';

  @override
  String get assignmentsLoadFailed => 'Не удалось загрузить задания';

  @override
  String get assignmentDetailsLoadFailed =>
      'Не удалось загрузить детали задания';

  @override
  String get assignmentUploadFailed => 'Не удалось загрузить файл';

  @override
  String get attendanceLoadFailed => 'Не удалось загрузить посещаемость';

  @override
  String get attendanceSummaryLoadFailed =>
      'Не удалось загрузить сводку посещаемости';

  @override
  String get menuLoadFailed => 'Не удалось загрузить меню';

  @override
  String get weeklyMenuLoadFailed => 'Не удалось загрузить недельное меню';

  @override
  String get conversationsLoadFailed => 'Не удалось загрузить чаты';

  @override
  String get messagesLoadFailed => 'Не удалось загрузить сообщения';

  @override
  String get profileUpdateFailed => 'Не удалось обновить профиль';

  @override
  String get imageUploadFailed => 'Не удалось загрузить изображение';

  @override
  String get childrenLoadFailed => 'Не удалось загрузить детей';

  @override
  String get dataLoadFailed => 'Не удалось загрузить данные';

  @override
  String get changePasswordFailed => 'Не удалось изменить пароль';

  @override
  String get balanceLoadFailed => 'Не удалось загрузить баланс';

  @override
  String get paymentHistoryLoadFailed =>
      'Не удалось загрузить историю платежей';

  @override
  String get paymentCreateFailed => 'Не удалось создать платеж';

  @override
  String get paymentMethodsLoadFailed => 'Не удалось загрузить способы оплаты';

  @override
  String get gradeTypeDaily => 'Ежедневная';

  @override
  String get gradeTypeExam => 'Экзамен';

  @override
  String get gradeTypeHomework => 'Домашнее задание';

  @override
  String get gradeTypeTest => 'Тест';

  @override
  String get langUz => 'Узбекский';

  @override
  String get langRu => 'Русский';

  @override
  String get langEn => 'Английский';

  @override
  String get paymentSuccessTitle => 'Оплата успешна!';

  @override
  String get paymentSuccessMessage =>
      'Оплата прошла успешно. Баланс вашего ребенка обновится в ближайшие минуты.';

  @override
  String get backToHome => 'Вернуться на главную';

  @override
  String get paymentFailedTitle => 'Ошибка оплаты';

  @override
  String get paymentFailedMessage =>
      'Произошла ошибка при совершении платежа. Пожалуйста, попробуйте еще раз или обратитесь в службу поддержки.';

  @override
  String get aiInsightsTitle => 'AI Рекомендации';

  @override
  String aiInsightsError(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get aiInsightsEmpty => 'Данные не найдены';

  @override
  String aiRiskLevelLabel(String level) {
    return 'Уровень риска: $level';
  }

  @override
  String aiAttendanceAndGrade(String attendance, String grade) {
    return 'Посещаемость: $attendance% | Средний балл: $grade';
  }

  @override
  String get aiWeakAreasTitle => 'По каким предметам нужно больше заниматься';

  @override
  String get diaryServiceTitle => 'Дневник';

  @override
  String get diaryTitle => 'Дневник';

  @override
  String get diaryWeeklyView => 'Неделя';

  @override
  String get diaryDailyView => 'День';

  @override
  String get diaryNoLessons => 'В этот день уроков нет';

  @override
  String get diaryNoData => 'Данные дневника не найдены';

  @override
  String get diaryLoadFailed => 'Не удалось загрузить дневник';

  @override
  String get diarySubject => 'Предмет';

  @override
  String get diaryTeacher => 'Учитель';

  @override
  String get diaryTopic => 'Тема';

  @override
  String get diaryGrade => 'Оценка';

  @override
  String get diaryHomework => 'Домашнее задание';

  @override
  String get diaryComment => 'Комментарий';

  @override
  String get diaryPresent => 'Присутствовал';

  @override
  String get diaryAbsent => 'Отсутствовал';

  @override
  String get diaryLate => 'Опоздал';

  @override
  String get diaryExcused => 'По уважительной причине';

  @override
  String diaryLessonsCount(int count) => '$count уроков';

  @override
  String diaryAvgGrade(String grade) => 'Средняя: $grade';

  @override
  String diaryAttendanceRate(int present, int total) =>
      'Посещаемость: $present/$total';

  @override
  String get classStoryServiceTitle => 'Новости класса';

  @override
  String get classStoryTitle => 'Новости класса';

  @override
  String get classStoryEmpty => 'Пока нет новостей';

  @override
  String get classStoryLoadFailed => 'Не удалось загрузить новости';

  @override
  String get classStoryCommentHint => 'Напишите комментарий...';

  @override
  String classStoryLikes(int count) => '$count лайков';

  @override
  String classStoryComments(int count) => '$count комментариев';

  @override
  String get transportServiceTitle => 'Транспорт';

  @override
  String get transportTitle => 'Школьный автобус';

  @override
  String get transportNoBus => 'Автобус не найден';

  @override
  String get transportNoBusDesc =>
      'Ваш ребёнок не закреплён за активным маршрутом';

  @override
  String get transportDriver => 'Водитель';

  @override
  String get transportLiveLocation => 'Местоположение';

  @override
  String get transportJustNow => 'Только что';

  @override
  String get transportStops => 'Остановки';

  @override
  String get transportPickup => 'Посадка';

  @override
  String get transportDropoff => 'Высадка';

  @override
  String get quizServiceTitle => 'Тесты';
  @override
  String get quizTitle => 'Тесты';
  @override
  String get quizEmpty => 'Нет доступных тестов';
  @override
  String get quizLoadFailed => 'Не удалось загрузить тесты';
  @override
  String get quizMinutes => 'мин';
  @override
  String get quizMaxScore => 'Макс. балл';
  @override
  String get quizAlreadyAttempted => 'Завершён';
  @override
  String get quizQuestion => 'Вопрос';
  @override
  String get quizAnswered => 'отвечено';
  @override
  String get quizPrevious => 'Назад';
  @override
  String get quizNext => 'Далее';
  @override
  String get quizSubmit => 'Завершить';
  @override
  String get quizStartFailed => 'Не удалось начать тест';
  @override
  String get quizScore => 'Баллы';
  @override
  String get quizResultGreat => 'Отличный результат!';
  @override
  String get quizResultTryAgain => 'В следующий раз будет лучше!';
  @override
  String get quizBackToList => 'К списку тестов';

  @override
  String get eventsServiceTitle => 'Мероприятия';
  @override
  String get eventsTitle => 'Мероприятия';
  @override
  String get eventsEmpty => 'Мероприятий не найдено';
  @override
  String get eventsLoadFailed => 'Не удалось загрузить мероприятия';
  @override
  String get eventsAll => 'Все';
  @override
  String get eventsHoliday => 'Праздник';
  @override
  String get eventsExam => 'Экзамен';
  @override
  String get eventsMeeting => 'Собрание';
  @override
  String get eventsSport => 'Спорт';
  @override
  String get eventsOther => 'Другое';
  @override
  String get galleryServiceTitle => 'Галерея';
  @override
  String get galleryTitle => 'Фотогалерея';
  @override
  String get galleryEmpty => 'Альбомов пока нет';
  @override
  String get galleryLoadFailed => 'Не удалось загрузить галерею';
  @override
  String get galleryPhotos => 'фото';
  @override
  String get galleryNoPhotos => 'В этом альбоме нет фотографий';
  @override
  String get formsServiceTitle => 'Опросы';
  @override
  String get formsTitle => 'Опросы';
  @override
  String get formsEmpty => 'Опросов пока нет';
  @override
  String get formsLoadFailed => 'Не удалось загрузить опросы';
  @override
  String get formsSubmitted => 'Отправлено';
  @override
  String get formsExpired => 'Истёк';
  @override
  String get formsPending => 'Ожидает';
  @override
  String get formsSubmitAction => 'Отправить';
  @override
  String get formsSubmitFailed => 'Не удалось отправить';
  @override
  String get formsAlreadySubmitted => 'Вы уже ответили на этот опрос';
  @override
  String get formsSubmittedSuccess => 'Ваш ответ успешно отправлен!';
  @override
  String get formsBackToList => 'К списку опросов';
  @override
  String get behaviorServiceTitle => 'Поведение';
  @override
  String get behaviorTitle => 'Поведение';
  @override
  String get behaviorLoadFailed => 'Не удалось загрузить данные';
  @override
  String get behaviorEmpty => 'Записей о поведении нет';
  @override
  String get behaviorNetScore => 'Общий балл';
  @override
  String get behaviorPositive => 'Положительные';
  @override
  String get behaviorNegative => 'Отрицательные';
  @override
  String get behaviorTotal => 'Всего';
  @override
  String get behaviorHistory => 'История';
}
