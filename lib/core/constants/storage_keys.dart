/// Local storage key nomlari
class StorageKeys {
  StorageKeys._();

  // ─── Auth ───
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';

  // ─── User ───
  static const String userProfile = 'user_profile';
  static const String selectedChildId = 'selected_child_id';

  // ─── Offline Cache ───
  static const String gradesCachePrefix = 'cache_grades_';
  static const String gradeSummaryCachePrefix = 'cache_grade_summary_';
  static const String scheduleCachePrefix = 'cache_schedule_';
  static const String attendanceCachePrefix = 'cache_attendance_';
  static const String attendanceSummaryCachePrefix =
      'cache_attendance_summary_';
  static const String weeklyMenuCachePrefix = 'cache_weekly_menu_';
  static const String dailyMenuCachePrefix = 'cache_daily_menu_';
  static const String paymentStateCachePrefix = 'cache_payment_state_';
  static const String assignmentsCachePrefix = 'cache_assignments_';
  static const String assignmentDetailCachePrefix = 'cache_assignment_detail_';
  static const String notificationsCache = 'cache_notifications';
  static const String classRatingCachePrefix = 'cache_class_rating_';
  static const String schoolRatingCache = 'cache_school_rating';
  static const String childRatingCachePrefix = 'cache_child_rating_';
  static const String conversationsCache = 'cache_conversations';
  static const String chatMessagesCachePrefix = 'cache_chat_messages_';

  // ─── Settings ───
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String fcmToken = 'fcm_token';

  // ─── First Launch ───
  static const String isFirstLaunch = 'is_first_launch';
}
