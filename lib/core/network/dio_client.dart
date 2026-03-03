import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

/// Dio HTTP Client — barcha API so'rovlar shu orqali boradi
class DioClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;
  bool _isClearingSession = false;
  final VoidCallback? onUnauthorized;

  DioClient(this._secureStorage, {this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        sendTimeout: kIsWeb
            ? null
            : const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuth = options.extra['skipAuth'] == true;
          if (skipAuth) {
            options.headers.remove('Authorization');
            handler.next(options);
            return;
          }

          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;
            final explicitRule = requestOptions.extra['clearSessionOn401'];
            final skipAuth = requestOptions.extra['skipAuth'] == true;
            final isRefreshReq = requestOptions.path == '/api/refresh';
            final hasAuthHeader =
                requestOptions.headers['Authorization'] != null;

            final shouldClearSession = explicitRule is bool
                ? explicitRule
                : (!skipAuth && hasAuthHeader && !isRefreshReq);

            if (shouldClearSession) {
              if (!_isClearingSession) {
                _isClearingSession = true;
                
                try {
                  // Attempt silent refresh
                  final oldToken = await _secureStorage.getAccessToken();
                  final dioRefresh = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
                  
                  final refreshRes = await dioRefresh.post(
                    '/api/refresh',
                    options: Options(headers: {'Authorization': 'Bearer $oldToken'}),
                  );
                  
                  if (refreshRes.statusCode == 200) {
                    final newToken = refreshRes.data['token'];
                    await _secureStorage.saveAccessToken(newToken);
                    _isClearingSession = false;
                    
                    // Replay failed request
                    requestOptions.headers['Authorization'] = 'Bearer $newToken';
                    final response = await _dio.fetch(requestOptions);
                    return handler.resolve(response);
                  }
                } catch (e) {
                  // Refresh failed, proceed to local logout
                  await _secureStorage.clearAll();
                  onUnauthorized?.call();
                } finally {
                  _isClearingSession = false;
                }
              }
            }
          }



          if (kIsWeb && error.type == DioExceptionType.connectionError) {
            // Web da CORS yoki Network xatosi ko'pincha connectionError yoki unknown bo'ladi.
            debugPrint(
              'WEB NETWORK ERROR: ${error.message}. This might be a CORS issue if calling external API from localhost.',
            );
          }
          handler.next(error);
        },
      ),
    );

    // Logging — faqat debug mode da
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // ─── CRUD Methods ───

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(String path, {dynamic data, Options? options}) {
    return _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) {
    return _dio.delete(path, data: data, options: options);
  }

  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
  }) {
    return _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
