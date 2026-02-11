import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auth_response.dart';

/// Auth API — Autentifikatsiya bilan bog'liq barcha API so'rovlari
///
/// Bu klass faqat HTTP so'rov yuboradi va javobni parse qiladi.
/// Biznes logika (token saqlash, xatolik qayta ishlash)
/// [AuthRepository] da amalga oshiriladi.
class AuthApi {
  final DioClient _client;

  AuthApi(this._client);

  /// Login — foydalanuvchi nomi va parol bilan kirish
  ///
  /// [username] — telefon raqam yoki login
  /// [password] — parol
  ///
  /// Muvaffaqiyatli bo'lsa [AuthResponse] qaytaradi.
  /// Xatolik bo'lsa [ServerException] yoki [NetworkException] otadi.
  Future<AuthResponse> login({
    required String username, // Kept for compatibility with existing UI.
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.login,
        data: {
          'email': username,
          'password': password,
          'device_name': 'android_app',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final root = _asMap(response.data);
      final normalized = _normalizeAuthResponse(root);
      if ((normalized['token'] as String).isEmpty) {
        throw const ServerException(
          message: 'Login javobida token topilmadi',
          statusCode: 500,
        );
      }
      return AuthResponse.fromJson(normalized);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register — yangi foydalanuvchi ro'yxatdan o'tkazish
  /// (Note: Not currently supported in Tenant API)
  ///
  /// [fullName] — to'liq ism
  /// [phone] — telefon raqam (+998 format)
  /// [password] — parol (kamida 6 belgi)
  /// [email] — ixtiyoriy email
  Future<AuthResponse> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    final _ = (fullName, phone, password, email);
    throw const ServerException(
      message:
          'Tenant API bo\'yicha ro\'yxatdan o\'tish endpointi mavjud emas. '
          'Hisoblar administrator tomonidan yaratiladi.',
      statusCode: 405,
    );
  }

  /// Google Sign In — Google ID token orqali kirish
  ///
  /// [idToken] — Google Sign In dan olingan ID token
  Future<AuthResponse> googleSignIn({required String idToken}) async {
    final _ = idToken;
    throw const ServerException(
      message:
          'Tenant API bo\'yicha Google orqali kirish endpointi mavjud emas.',
      statusCode: 405,
    );
  }

  /// Logout — sessiyani tugatish
  ///
  /// Server tomonida tokenni bekor qiladi.
  /// Lokal token tozalash [AuthRepository] da amalga oshiriladi.
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } on DioException catch (e) {
      // Logout xatoligi sessiyani tugatishga to'sqinlik qilmasligi kerak
      // Lokal tokenlar baribir tozalanadi
      throw _handleDioError(e);
    }
  }

  /// FCM tokenni yangilash
  Future<void> updateFcmToken(String token) async {
    try {
      await _client.post(
        ApiConstants.saveFcmToken,
        data: {'token': token, 'fcm_token': token},
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      // OAS'da bu endpoint yo'q bo'lishi mumkin, ilova oqimini to'xtatmaymiz.
      if (statusCode == 404 || statusCode == 405) return;
      throw _handleDioError(e);
    }
  }

  /// Parolni tiklash — telefon raqamga SMS yuborish
  ///
  /// [phone] — ro'yxatdan o'tgan telefon raqam
  Future<void> forgotPassword({required String phone}) async {
    final _ = phone;
    throw const ServerException(
      message:
          'Tenant API bo\'yicha parol tiklash endpointi mavjud emas. '
          'Administratorga murojaat qiling.',
      statusCode: 405,
    );
  }

  /// DioException → Custom Exception mapping
  ///
  /// Barcha API xatoliklarini yagona formatga keltiradi.
  Exception _handleDioError(DioException e) {
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

        // API dan kelgan xabarni olish
        if (data is Map<String, dynamic>) {
          message =
              (data['message'] as String?) ??
              (data['error'] as String?) ??
              message;
        }

        // Status code ga qarab exception turi
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

  Map<String, dynamic> _normalizeAuthResponse(Map<String, dynamic> raw) {
    final user = _asMap(raw['user']);
    final roles = user['roles'] is List
        ? (user['roles'] as List).map((e) => e.toString()).toList()
        : const <String>[];

    final email = user['email']?.toString();
    final fullNameRaw = (user['full_name'] ?? user['name'] ?? '').toString();
    final fullName = fullNameRaw.isNotEmpty
        ? fullNameRaw
        : (email != null && email.isNotEmpty ? email : 'Parent');

    return <String, dynamic>{
      'token': (raw['token'] ?? raw['access_token'] ?? '').toString(),
      'user': <String, dynamic>{
        'id': _toInt(user['id']),
        'full_name': fullName,
        'phone': user['phone']?.toString() ?? '',
        'email': email,
        'avatar_url': user['avatar_url'] ?? user['photo_url'],
        'role': (user['role'] ?? (roles.isNotEmpty ? roles.first : 'parent'))
            .toString(),
        'balance': _toInt(user['balance']),
        'contract_number': user['contract_number']?.toString(),
        'monthly_fee': _toInt(user['monthly_fee']),
        'children': user['children'] is List ? user['children'] : const [],
        'created_at': user['created_at']?.toString(),
        'notifications_enabled': user['notifications_enabled'] ?? true,
      },
    };
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
