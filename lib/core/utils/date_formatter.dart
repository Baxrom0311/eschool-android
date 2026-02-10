import 'package:intl/intl.dart';

/// Sana va vaqtni formatlash uchun yordamchi klass
class DateFormatter {
  DateFormatter._();

  // ─── Formatterlar ───
  static final _dayMonth = DateFormat('dd MMM');
  static final _dayMonthYear = DateFormat('dd MMM, yyyy');
  static final _fullDate = DateFormat('dd MMMM yyyy');
  static final _time = DateFormat('HH:mm');
  static final _dayOfWeek = DateFormat('EEEE');
  static final _shortDay = DateFormat('EE');

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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Bugun';
    if (diff == 1) return 'Kecha';
    if (diff == -1) return 'Ertaga';
    return formatDate(date);
  }

  /// "2 soat oldin" / "5 daqiqa oldin"
  static String formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return formatDate(date);
  }

  /// String → DateTime
  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }
}
