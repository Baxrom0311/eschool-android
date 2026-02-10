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

  // ─── Settings ───
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String fcmToken = 'fcm_token';

  // ─── First Launch ───
  static const String isFirstLaunch = 'is_first_launch';
}
