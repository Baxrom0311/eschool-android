import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/notification_model.dart';
import 'api_helpers.dart';

/// Notification API — push xabarnomalar bilan bog'liq API so'rovlari
class NotificationApi with ApiHelpers {
  final DioClient _client;

  NotificationApi(this._client);

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    try {
      final response = await _client.get(
        ApiConstants.notifications,
        queryParameters: {'page': page},
      );

      return parseListResponse(
        response.data,
        NotificationModel.fromJson,
        listKey: 'notifications',
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _client.post(ApiConstants.markAsRead(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// FCM tokenni backendga saqlash
  /// POST /api/notifications/token
  /// Body: { "token": "..." }
  Future<void> saveFcmToken(String token) async {
    try {
      await _client.post(ApiConstants.saveFcmToken, data: {'token': token});
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
