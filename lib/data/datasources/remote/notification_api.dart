import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/notification_model.dart';

/// Notification API — bildirishnomalar
class NotificationApi {
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
      return _parseList(response.data, NotificationModel.fromJson);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Parent Tenant OAS da notifications endpoint bo'lmasligi mumkin.
      if (status == 404 || status == 405) {
        return const [];
      }
      throw _handleDioError(e);
    }
  }

  /// Bildirishnomani o'qilgan deb belgilash
  Future<void> markAsRead(int notificationId) async {
    try {
      await _client.post(ApiConstants.markAsRead(notificationId));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 405) return;
      throw _handleDioError(e);
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
      throw _handleDioError(e);
    }
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data.containsKey('notifications')) {
        list = data['notifications'] as List<dynamic>;
      } else {
        return [];
      }
    } else {
      return [];
    }
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Server xatoligi';
        if (data is Map<String, dynamic>) {
          message =
              (data['message'] as String?) ??
              (data['error'] as String?) ??
              message;
        }
        if (statusCode == 401) return AuthException(message: message);
        return ServerException(message: message, statusCode: statusCode);
      default:
        return const ServerException();
    }
  }
}
