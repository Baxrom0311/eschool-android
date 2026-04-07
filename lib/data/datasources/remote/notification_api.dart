import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import 'api_helpers.dart';

/// Notification API — push xabarnomalar bilan bog'liq API so'rovlari
class NotificationApi with ApiHelpers {
  final DioClient _client;

  NotificationApi(this._client);

  /// FCM tokenni backendga saqlash
  /// POST /api/notifications/token
  /// Body: { "token": "..." }
  Future<void> saveFcmToken(String token) async {
    try {
      await _client.post(
        ApiConstants.saveFcmToken,
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
