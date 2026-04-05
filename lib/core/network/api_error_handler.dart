import 'package:dio/dio.dart';

import '../constants/app_strings.dart';
import '../error/exceptions.dart';

/// DioException → foydalanuvchi uchun tushunarli xabar
class ApiErrorHandler {
  ApiErrorHandler._();

  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Server bilan aloqa vaqti tugadi. Qayta urinib ko\'ring.';

        case DioExceptionType.connectionError:
          return AppStrings.noInternet;

        case DioExceptionType.badResponse:
          return _handleStatusCode(error.response);

        case DioExceptionType.cancel:
          return 'So\'rov bekor qilindi';

        default:
          return AppStrings.errorGeneric;
      }
    }

    return readableMessage(error);
  }

  static String readableMessage(
    Object? error, {
    String fallback = AppStrings.errorGeneric,
  }) {
    if (error == null) return fallback;
    if (error is DioException) return handleError(error);
    if (error is ServerException) return error.message;
    if (error is NetworkException) return error.message;
    if (error is AuthException) return error.message;
    if (error is ValidationException) return error.message;

    final rawMessage = error is String ? error : error.toString();
    final normalized = _normalizeMessage(rawMessage);
    return normalized.isEmpty ? fallback : normalized;
  }

  static String _handleStatusCode(Response? response) {
    if (response == null) return AppStrings.errorServer;

    final data = response.data;

    if (response.statusCode == 422) {
      return _extractValidationErrors(data) ?? AppStrings.errorGeneric;
    }

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message != null && message is String && message.isNotEmpty) {
        return readableMessage(message);
      }
    }

    switch (response.statusCode) {
      case 400:
        return 'Noto\'g\'ri so\'rov';
      case 401:
        return AppStrings.errorAuth;
      case 403:
        return 'Ruxsat berilmagan';
      case 404:
        return 'Ma\'lumot topilmadi';
      case 500:
        return AppStrings.errorServer;
      default:
        return AppStrings.errorGeneric;
    }
  }

  /// Laravel 422 validation xatolarini parse qilish.
  ///
  /// Laravel format: { "message": "...", "errors": { "field": ["msg1", "msg2"] } }
  static String? _extractValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final errors = data['errors'];
    if (errors is Map<String, dynamic> && errors.isNotEmpty) {
      final messages = <String>[];
      for (final entry in errors.entries) {
        if (entry.value is List) {
          for (final msg in entry.value) {
            if (msg is String && msg.isNotEmpty) {
              messages.add(msg);
            }
          }
        }
      }
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    // Fallback: "message" maydonini tekshirish
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return null;
  }

  static String _normalizeMessage(String rawMessage) {
    var message = rawMessage.trim();
    if (message.isEmpty || message == 'null') return '';

    message = message.replaceFirst(RegExp(r'^[A-Za-z_ ]*Exception:\s*'), '');
    message = message.replaceFirst(RegExp(r'^[A-Za-z_ ]*Error:\s*'), '');
    message = message.replaceFirst('Bad state: ', '');
    message = message.replaceFirst('Invalid argument(s): ', '');

    return message.trim();
  }
}
