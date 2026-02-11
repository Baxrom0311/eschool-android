import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/safe_api_call.dart';
import '../datasources/remote/auth_api.dart';
import '../models/user_model.dart';

/// Auth Repository — Autentifikatsiya biznes logikasi
///
/// [AuthApi] va [SecureStorageService] ni birlashtiradi.
/// API so'rov → token saqlash → xatolik qayta ishlash
/// hammasi shu yerda amalga oshiriladi.
///
/// Har bir metod [Either<Failure, T>] qaytaradi:
/// - `Left(Failure)` — xatolik
/// - `Right(T)` — muvaffaqiyat
class AuthRepository {
  final AuthApi _authApi;
  final SecureStorageService _secureStorage;

  AuthRepository({
    required AuthApi authApi,
    required SecureStorageService secureStorage,
  })  : _authApi = authApi,
        _secureStorage = secureStorage;

  /// Login — tizimga kirish
  ///
  /// 1. API ga so'rov yuboradi
  /// 2. Tokenlarni xavfsiz saqlaydi
  /// 3. UserModel qaytaradi
  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
  }) {
    return safeApiCall(
      () async {
        final response = await _authApi.login(
          username: username,
          password: password,
        );
        await _secureStorage.saveTokens(
          accessToken: response.accessToken,
          refreshToken: '',
        );
        return response.user;
      },
      errorMessage: 'Kirish amalga oshmadi',
    );
  }

  /// Register — yangi hisob yaratish
  Future<Either<Failure, UserModel>> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) {
    return safeApiCall(
      () async {
        final response = await _authApi.register(
          fullName: fullName,
          phone: phone,
          password: password,
          email: email,
        );
        await _secureStorage.saveTokens(
          accessToken: response.accessToken,
          refreshToken: '',
        );
        return response.user;
      },
      errorMessage: 'Ro\'yxatdan o\'tishda xatolik',
    );
  }

  /// Google Sign In — Google orqali kirish
  Future<Either<Failure, UserModel>> googleSignIn({
    required String idToken,
  }) {
    return safeApiCall(
      () async {
        final response = await _authApi.googleSignIn(idToken: idToken);
        await _secureStorage.saveTokens(
          accessToken: response.accessToken,
          refreshToken: '',
        );
        return response.user;
      },
      errorMessage: 'Google kirish xatoligi',
    );
  }

  /// Logout — tizimdan chiqish
  ///
  /// Server dagi tokenni bekor qiladi (ixtiyoriy — xatolik bo'lsa ham davom etadi).
  /// Lokal tokenlarni tozalaydi (albatta bajariladi).
  Future<Either<Failure, void>> logout() async {
    try {
      try {
        await _authApi.logout();
      } catch (_) {
        // Server logout xatoligi sessiyani tugatishga to'sqinlik qilmaydi
      }
      await _secureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      await _secureStorage.clearAll();
      return const Right(null);
    }
  }

  /// FCM tokenni serverga yuborish
  Future<Either<Failure, void>> updateFCMToken(String token) {
    return safeApiCall(
      () => _authApi.updateFcmToken(token),
      errorMessage: 'FCM token yangilashda xatolik',
    );
  }

  /// Parolni tiklash — SMS yuborish
  Future<Either<Failure, void>> forgotPassword({
    required String phone,
  }) {
    return safeApiCall(
      () => _authApi.forgotPassword(phone: phone),
      errorMessage: 'Parolni tiklashda xatolik',
    );
  }

  /// Token mavjudligini tekshirish (tez auth holat tekshiruvi)
  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
