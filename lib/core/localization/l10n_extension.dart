import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:parent_school_app/l10n/app_localizations.dart';

import 'app_locale.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsRegistry.instance;
}

extension AppLocalizationsHelpers on AppLocalizations {
  AppLocale get appLocale => appLocaleFromCode(localeName.split('_').first);

  String get intlLocaleTag => localeName.replaceAll('_', '-');

  bool get _isUz => localeName.startsWith('uz');
  bool get _isRu => localeName.startsWith('ru');

  String _pick({required String uz, required String ru, required String en}) {
    if (_isUz) return uz;
    if (_isRu) return ru;
    return en;
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) {
      return intl.DateFormat.yMMMd(intlLocaleTag).format(value);
    }

    final raw = value.toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return intl.DateFormat.yMMMd(intlLocaleTag).format(parsed);
  }

  String minimumLength(int min) => _pick(
    uz: 'Kamida $min ta belgi kiriting',
    ru: 'Введите минимум $min символов',
    en: 'Enter at least $min characters',
  );

  String minutesAgo(int value) => _pick(
    uz: '$value daqiqa oldin',
    ru: '$value минут назад',
    en: '$value minutes ago',
  );

  String hoursAgo(int value) => _pick(
    uz: '$value soat oldin',
    ru: '$value часов назад',
    en: '$value hours ago',
  );

  String daysAgo(int value) => _pick(
    uz: '$value kun oldin',
    ru: '$value дней назад',
    en: '$value days ago',
  );

  String groupText(String groupName) => '$groupLabel: $groupName';

  String absenceStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return _pick(uz: 'Tasdiqlangan', ru: 'Одобрено', en: 'Approved');
      case 'rejected':
        return _pick(uz: 'Rad etilgan', ru: 'Отклонено', en: 'Rejected');
      default:
        return _pick(uz: 'Kutilmoqda', ru: 'Ожидает', en: 'Pending');
    }
  }

  String scorePoints(num score) =>
      _pick(uz: '$score ball', ru: '$score баллов', en: '$score pts');

  String versionLabel(String version) => _pick(
    uz: 'Versiya $version',
    ru: 'Версия $version',
    en: 'Version $version',
  );

  String homeGreeting(String name) =>
      _pick(uz: 'Salom, $name', ru: 'Здравствуйте, $name', en: 'Hello, $name');

  String assignmentDueDateText(dynamic date) => _pick(
    uz: 'Topshirish muddati: ${_formatDate(date)}',
    ru: 'Срок сдачи: ${_formatDate(date)}',
    en: 'Due date: ${_formatDate(date)}',
  );

  String assignmentStatusText(Object status) => assignmentStatusLabel(status);

  String assignmentStatusLabel(Object status) {
    switch (status.toString().toLowerCase()) {
      case 'submitted':
      case 'assignmentstatus.submitted':
        return _pick(uz: 'Topshirilgan', ru: 'Сдано', en: 'Submitted');
      case 'graded':
      case 'assignmentstatus.graded':
        return _pick(uz: 'Baholangan', ru: 'Оценено', en: 'Graded');
      case 'overdue':
      case 'assignmentstatus.overdue':
        return _pick(uz: 'Muddati o\'tgan', ru: 'Просрочено', en: 'Overdue');
      default:
        return _pick(uz: 'Kutilmoqda', ru: 'Ожидает', en: 'Pending');
    }
  }

  String debtPaymentPrompt(String amount) => _pick(
    uz: '$amount qarzdorlikni qoplash uchun to\'lov qiling',
    ru: 'Оплатите $amount для погашения задолженности',
    en: 'Pay $amount to cover the outstanding balance',
  );

  String paymentRecordTitle(Object id) =>
      _pick(uz: 'To\'lov #$id', ru: 'Платёж #$id', en: 'Payment #$id');

  String paymentMethodLabelText(String method) => _pick(
    uz: 'Usul: ${_paymentMethodName(method)}',
    ru: 'Метод: ${_paymentMethodName(method)}',
    en: 'Method: ${_paymentMethodName(method)}',
  );

  String _paymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'payme':
        return 'Payme';
      case 'click':
        return 'Click';
      case 'cash':
        return _pick(uz: 'Naqd', ru: 'Наличные', en: 'Cash');
      case 'transfer':
        return _pick(uz: 'O\'tkazma', ru: 'Перевод', en: 'Transfer');
      default:
        return method;
    }
  }

  String paymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _pick(uz: 'Muvaffaqiyatli', ru: 'Успешно', en: 'Completed');
      case 'failed':
        return _pick(uz: 'Muvaffaqiyatsiz', ru: 'Неуспешно', en: 'Failed');
      case 'refunded':
        return _pick(uz: 'Qaytarilgan', ru: 'Возвращён', en: 'Refunded');
      default:
        return _pick(uz: 'Kutilmoqda', ru: 'Ожидает', en: 'Pending');
    }
  }

  String childClassText(String className) => _pick(
    uz: 'Sinf: $className',
    ru: 'Класс: $className',
    en: 'Class: $className',
  );

  String levelBadge(int level) =>
      _pick(uz: '$level-daraja', ru: '$level уровень', en: 'Level $level');

  String leaderboardCoins(int coins) =>
      _pick(uz: '$coins tanga', ru: '$coins монет', en: '$coins coins');

  String unlockableBadgesCount(int count) => _pick(
    uz: '$count ta ochiladigan badge',
    ru: '$count доступных значков',
    en: '$count unlockable badges',
  );

  String meetingWithTeacher(String teacherName) => _pick(
    uz: '$teacherName bilan uchrashuv',
    ru: 'Встреча с $teacherName',
    en: 'Meeting with $teacherName',
  );

  String conferenceStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
      case 'approved':
        return _pick(uz: 'Tasdiqlangan', ru: 'Подтверждено', en: 'Confirmed');
      case 'cancelled':
      case 'rejected':
        return _pick(uz: 'Bekor qilingan', ru: 'Отменено', en: 'Cancelled');
      default:
        return _pick(uz: 'Kutilmoqda', ru: 'Ожидает', en: 'Pending');
    }
  }

  String availableSlotsCount(int count) => _pick(
    uz: '$count ta bo\'sh vaqt',
    ru: '$count свободных слотов',
    en: '$count available slots',
  );

  String libraryLoanDates(String borrowedAt, String dueAt) => _pick(
    uz: 'Olingan: ${_formatDate(borrowedAt)} • Qaytarish: ${_formatDate(dueAt)}',
    ru: 'Выдано: ${_formatDate(borrowedAt)} • Вернуть: ${_formatDate(dueAt)}',
    en: 'Borrowed: ${_formatDate(borrowedAt)} • Due: ${_formatDate(dueAt)}',
  );

  String lastUpdatedLabel(dynamic value) => _pick(
    uz: 'Oxirgi yangilanish: ${_formatDate(value)}',
    ru: 'Последнее обновление: ${_formatDate(value)}',
    en: 'Last updated: ${_formatDate(value)}',
  );

  String roomLabelText(String room) =>
      _pick(uz: 'Xona: $room', ru: 'Кабинет: $room', en: 'Room: $room');

  String phoneDisplay(String phone) =>
      _pick(uz: 'Telefon: $phone', ru: 'Телефон: $phone', en: 'Phone: $phone');

  String childrenCount(int count) =>
      _pick(uz: '$count ta farzand', ru: '$count детей', en: '$count children');
}

/// A static localization holder to bridger the gap for Notifiers and tests
/// where BuildContext is not available.
class AppLocalizationsRegistry {
  static AppLocalizations _instance = lookupAppLocalizations(
    const Locale('uz'),
  );

  static AppLocalizations get instance => _instance;

  static void update(dynamic instance) {
    if (instance is AppLocalizations) {
      _instance = instance;
    }
  }
}
