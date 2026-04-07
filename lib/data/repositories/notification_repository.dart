import '../datasources/remote/notification_api.dart';
import 'base_repository.dart';

/// Notification Repository — push xabarnomalar biznes logikasi
class NotificationRepository extends BaseRepository {
  final NotificationApi _notificationApi;

  NotificationRepository({required NotificationApi notificationApi})
      : _notificationApi = notificationApi;

  /// FCM tokenni saqlash
  Future<void> saveFcmToken(String token) async {
    return safeExecute(() => _notificationApi.saveFcmToken(token));
  }
}
