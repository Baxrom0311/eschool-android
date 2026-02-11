import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';

/// Barcha API klasslarda takrorlanadigan yordamchi funksiyalarni
/// bitta joyga jamlaydigan mixin.
///
/// Har bir API klass `with ApiHelpers` qo'shib ishlatadi.
mixin ApiHelpers {
  /// DioException → Custom Exception mapping
  ///
  /// Barcha API xatoliklarini yagona formatga keltiradi.
  /// 422 validatsiya xatoliklari ham qo'llab-quvvatlanadi.
  Exception handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Internet bilan aloqa yo\'q. Tarmoqni tekshiring.',
        );

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

        if (statusCode == 401) {
          return AuthException(message: message);
        }

        if (statusCode == 422 && data is Map<String, dynamic>) {
          final errors = data['errors'];
          Map<String, List<String>>? validationErrors;

          if (errors is Map<String, dynamic>) {
            validationErrors = errors.map(
              (key, value) => MapEntry(
                key,
                (value is List) ? value.cast<String>() : [value.toString()],
              ),
            );
          }

          return ValidationException(
            message: message,
            errors: validationErrors,
          );
        }

        return ServerException(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const ServerException(message: 'So\'rov bekor qilindi');

      default:
        return const ServerException(message: 'Noma\'lum xatolik yuz berdi');
    }
  }

  /// dynamic → Map<String, dynamic> xavfsiz konvertatsiya
  Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  /// dynamic → int xavfsiz konvertatsiya (default: 0)
  int toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// dynamic → int? xavfsiz konvertatsiya (null agar konvert bo'lmasa)
  int? toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// dynamic → double? xavfsiz konvertatsiya
  double? toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// dynamic → double xavfsiz konvertatsiya (default: 0.0)
  double toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  /// Map ichidagi ma'lumotlardan barqaror ID yaratish
  int stableId(Map<String, dynamic> row) {
    return row.toString().hashCode.abs();
  }

  /// API javobidagi ro'yxatni xavfsiz parse qilish
  ///
  /// Quyidagi formatlarda ishlaydi:
  /// - `[ ... ]` — to'g'ridan-to'g'ri list
  /// - `{ "data": [ ... ] }` — Laravel pagination wrapper
  /// - `{ "<key>": [ ... ] }` — nomi bilan berilgan list
  List<T> parseListResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson, {
    String? listKey,
  }) {
    List<dynamic> list;

    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      if (listKey != null && data[listKey] is List) {
        list = data[listKey] as List<dynamic>;
      } else if (data['data'] is List) {
        list = data['data'] as List<dynamic>;
      } else {
        return [];
      }
    } else {
      return [];
    }

    return list
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
