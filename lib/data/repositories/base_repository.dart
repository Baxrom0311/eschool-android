import 'package:dio/dio.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/error/exceptions.dart';

abstract class BaseRepository {
  /// Safely executes an API call and handles mapping.
  /// Use this when the API returns a raw Dio [Response].
  Future<T> safeCall<T>(
      Future<Response> Function() call, T Function(dynamic data) mapper) async {
    try {
      final response = await call();
      return mapper(response.data);
    } catch (error, stackTrace) {
      ApiErrorHandler.throwAsException(error, stackTrace);
    }
  }

  /// Same as [safeCall] but for list responses with key mapping support.
  Future<List<T>> safeCallList<T>(
    Future<Response> Function() call,
    T Function(dynamic data) mapper, {
    String? listKey,
  }) async {
    try {
      final response = await call();
      var data = response.data;

      List? list;
      if (listKey != null) {
        list = data[listKey] as List?;
      } else if (data is List) {
        list = data;
      } else if (data is Map) {
        list = (data['data'] ?? data['items'] ?? data['students'] ?? data['history']) as List?;
      }

      return (list ?? []).map((e) => mapper(e)).toList();
    } catch (error, stackTrace) {
      ApiErrorHandler.throwAsException(error, stackTrace);
    }
  }

  /// Safely executes an arbitrary async call and maps errors via ApiErrorHandler.
  /// Use this when calling methods that already return parsed models.
  Future<T> safeExecute<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error, stackTrace) {
      if (error is ServerException ||
          error is AuthException ||
          error is NetworkException ||
          error is ValidationException) {
        rethrow;
      }
      ApiErrorHandler.throwAsException(error, stackTrace);
    }
  }
}
