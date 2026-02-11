import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../../models/notification_model.dart';
import 'api_helpers.dart';

/// Notification API — bildirishnomalar
class NotificationApi with ApiHelpers {
  final DioClient _client;

  NotificationApi(this._client);

  /// Bildirishnomalar ro'yxati (pagination bilan)
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return parseListResponse(
        response.data,
        NotificationModel.fromJson,
        listKey: 'notifications',
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Parent Tenant OAS da notifications endpoint bo'lmasligi mumkin.
      if (status == 404 || status == 405) {
        return const [];
      }
      throw handleDioError(e);
    }
  }

  /// Bildirishnomani o'qilgan deb belgilash
  Future<void> markAsRead(int notificationId) async {
    try {
      await _client.post(ApiConstants.markAsRead(notificationId));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 405) return;
      throw handleDioError(e);
    }
  }

  /// FCM tokenni serverga yuborish
  Future<void> saveFcmToken(String token) async {
    try {
      await _client.post(
        ApiConstants.saveFcmToken,
        data: {'token': token, 'fcm_token': token, 'device_type': 'android'},
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 405) return;
      throw handleDioError(e);
    }
  }
}
