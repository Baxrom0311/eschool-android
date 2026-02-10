import 'package:dio/dio.dart';
import '../constants/app_strings.dart';

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

    return AppStrings.errorGeneric;
  }

  static String _handleStatusCode(Response? response) {
    if (response == null) return AppStrings.errorServer;

    // Try to extract message from response body
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message != null && message is String && message.isNotEmpty) {
        return message;
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
      case 422:
        return AppStrings.errorGeneric;
      case 500:
        return AppStrings.errorServer;
      default:
        return AppStrings.errorGeneric;
    }
  }
}
