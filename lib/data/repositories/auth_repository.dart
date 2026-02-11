import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/storage/secure_storage.dart';
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
  }) async {
    try {
      final response = await _authApi.login(
        username: username,
        password: password,
      );

      // Tokenlarni saqlash
      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: '', // No refresh token in new API
      );

      return Right(response.user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Kutilmagan xatolik: ${e.toString()}'));
    }
  }

  /// Register — yangi hisob yaratish
  ///
  /// 1. API ga ro'yxatdan o'tish so'rovi
  /// 2. Tokenlarni saqlash
  /// 3. UserModel qaytaradi
  Future<Either<Failure, UserModel>> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    try {
      final response = await _authApi.register(
        fullName: fullName,
        phone: phone,
        password: password,
        email: email,
      );

      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: '', // No refresh token
      );

      return Right(response.user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.errors));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Kutilmagan xatolik: ${e.toString()}'));
    }
  }

  /// Google Sign In — Google orqali kirish
  ///
  /// 1. Google ID tokenni serverga yuboradi
  /// 2. Tokenlarni saqlash
  /// 3. UserModel qaytaradi
  Future<Either<Failure, UserModel>> googleSignIn({
    required String idToken,
  }) async {
    try {
      final response = await _authApi.googleSignIn(idToken: idToken);

      await _secureStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: '', // No refresh token
      );

      return Right(response.user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Google kirish xatoligi: ${e.toString()}'));
    }
  }

  /// Logout — tizimdan chiqish
  ///
  /// 1. Server dagi tokenni bekor qiladi (ixtiyoriy — xatolik bo'lsa ham davom etadi)
  /// 2. Lokal tokenlarni tozalaydi (albatta bajariladi)
  Future<Either<Failure, void>> logout() async {
    try {
      // Server logout — muvaffaqiyatsiz bo'lsa ham lokal tozalash davom etadi
      try {
        await _authApi.logout();
      } catch (_) {
        // Server logout xatoligi sessiyani tugatishga to'sqinlik qilmaydi
      }

      // Lokal tokenlarni tozalash — bu albatta bajariladi
      await _secureStorage.clearAll();

      return const Right(null);
    } catch (e) {
      // Hatto catch da ham tokenlarni tozalashga urinish
      await _secureStorage.clearAll();
      return const Right(null);
    }
  }


  /// FCM tokenni serverga yuborish
  Future<Either<Failure, void>> updateFCMToken(String token) async {
    try {
      await _authApi.updateFcmToken(token);
      return const Right(null);
    } catch (e) {
      // Token xatoligi foydalanuvchiga ko'rsatilmaydi
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Parolni tiklash — SMS yuborish
  Future<Either<Failure, void>> forgotPassword({
    required String phone,
  }) async {
    try {
      await _authApi.forgotPassword(phone: phone);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Kutilmagan xatolik: ${e.toString()}'));
    }
  }

  /// Token mavjudligini tekshirish (tez auth holat tekshiruvi)
  ///
  /// Auto-login logikasi uchun ishlatiladi.
  /// Token mavjud bo'lsa `true` qaytaradi.
  /// Token yangilanishi [DioClient] interceptor orqali avtomatik amalga oshiriladi.
  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
