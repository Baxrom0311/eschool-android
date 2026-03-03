import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/auth_response.dart';
import 'api_helpers.dart';

/// Auth API — Autentifikatsiya bilan bog'liq barcha API so'rovlari
///
/// Bu klass faqat HTTP so'rov yuboradi va javobni parse qiladi.
/// Biznes logika (token saqlash, xatolik qayta ishlash)
/// [AuthRepository] da amalga oshiriladi.
class AuthApi with ApiHelpers {
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
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {'skipAuth': true},
        ),
      );

      final root = asMap(response.data);
      final normalized = _normalizeAuthResponse(root);
      if ((normalized['token'] as String).isEmpty) {
        throw const ServerException(
          message: 'Login javobida token topilmadi',
          statusCode: 500,
        );
      }
      return AuthResponse.fromJson(normalized);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
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
      throw handleDioError(e);
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
      throw handleDioError(e);
    }
  }

  /// Parolni tiklash — telefon raqamga SMS kod yuborish
  ///
  /// POST /api/forgot-password
  /// Body: { "phone": "+998901234567" }
  Future<void> forgotPassword({required String phone}) async {
    try {
      await _client.post(
        ApiConstants.forgotPassword,
        data: {'phone': phone},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {'skipAuth': true},
        ),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// Parolni tiklash — SMS kod bilan parolni yangilash
  ///
  /// POST /api/reset-password
  /// Body: { "phone": "...", "code": "123456", "password": "...", "password_confirmation": "..." }
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _client.post(
        ApiConstants.resetPassword,
        data: {
          'phone': phone,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {'skipAuth': true},
        ),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// QR Kod orqali login
  ///
  /// POST /api/qr-login
  /// Body: { "qr_token": "..." }
  Future<AuthResponse> qrLogin({required String qrToken}) async {
    try {
      final response = await _client.post(
        ApiConstants.qrLogin,
        data: {'qr_token': qrToken},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {'skipAuth': true},
        ),
      );

      final root = asMap(response.data);
      final normalized = _normalizeAuthResponse(root);
      if ((normalized['token'] as String).isEmpty) {
        throw const ServerException(
          message: 'QR Login javobida token topilmadi',
          statusCode: 500,
        );
      }
      return AuthResponse.fromJson(normalized);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
  Map<String, dynamic> _normalizeAuthResponse(Map<String, dynamic> raw) {
    final user = asMap(raw['user']);
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
        'id': toInt(user['id']),
        'full_name': fullName,
        'phone': user['phone']?.toString() ?? '',
        'email': email,
        'avatar_url': user['avatar_url'] ?? user['photo_url'],
        'role': (user['role'] ?? (roles.isNotEmpty ? roles.first : 'parent'))
            .toString(),
        'balance': toInt(user['balance']),
        'contract_number': user['contract_number']?.toString(),
        'monthly_fee': toInt(user['monthly_fee']),
        'children': user['children'] is List ? user['children'] : const [],
        'created_at': user['created_at']?.toString(),
        'notifications_enabled': user['notifications_enabled'] ?? true,
      },
    };
  }
}
