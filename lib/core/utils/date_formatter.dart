import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';

/// Sana va vaqtni formatlash uchun yordamchi klass
class DateFormatter {
  DateFormatter._();

  static String get _localeTag => AppLocalizations.current.intlLocaleTag;

  static DateFormat get _dayMonth => DateFormat('dd MMM', _localeTag);
  static DateFormat get _dayMonthYear => DateFormat('dd MMM, yyyy', _localeTag);
  static DateFormat get _fullDate => DateFormat('dd MMMM yyyy', _localeTag);
  static DateFormat get _time => DateFormat('HH:mm', _localeTag);
  static DateFormat get _dayOfWeek => DateFormat('EEEE', _localeTag);
  static DateFormat get _shortDay => DateFormat('EE', _localeTag);

  /// "24 Okt, 2023"
  static String formatDate(DateTime date) => _dayMonthYear.format(date);

  /// "24 Okt"
  static String formatShortDate(DateTime date) => _dayMonth.format(date);

  /// "24 Oktyabr 2023"
  static String formatFullDate(DateTime date) => _fullDate.format(date);

  /// "14:30"
  static String formatTime(DateTime date) => _time.format(date);

  /// "Dushanba"
  static String formatDayOfWeek(DateTime date) => _dayOfWeek.format(date);

  /// "Du"
  static String formatShortDay(DateTime date) => _shortDay.format(date);

  /// "Bugun" / "Kecha" / "24 Okt"
  static String formatRelative(DateTime date) {
    final l10n = AppLocalizations.current;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return l10n.todayLabel;
    if (diff == 1) return l10n.yesterdayLabel;
    if (diff == -1) return l10n.tomorrowLabel;
    return formatDate(date);
  }

  /// "2 soat oldin" / "5 daqiqa oldin"
  static String formatTimeAgo(DateTime date) {
    final l10n = AppLocalizations.current;
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return l10n.justNowLabel;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return formatDate(date);
  }

  /// String → DateTime
  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }
}
