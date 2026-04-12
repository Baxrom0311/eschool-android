import '../../core/storage/secure_storage.dart';
import '../datasources/remote/auth_api.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// Auth Repository — Autentifikatsiya biznes logikasi
///
/// [AuthApi] va [SecureStorageService] ni birlashtiradi.
class AuthRepository extends BaseRepository {
  final AuthApi _authApi;
  final SecureStorageService _secureStorage;

  AuthRepository({
    required AuthApi authApi,
    required SecureStorageService secureStorage,
  }) : _authApi = authApi,
       _secureStorage = secureStorage;

  /// Login — tizimga kirish
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    return safeExecute(() async {
      final response = await _authApi.login(
        username: username,
        password: password,
      );
      await _secureStorage.saveAccessToken(response.accessToken);
      return response.user;
    });
  }

  /// Logout — tizimdan chiqish
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // Server logout xatoligi sessiyani tugatishga to'sqinlik qilmaydi
    } finally {
      await _secureStorage.clearAll();
    }
  }

  /// FCM tokenni serverga yuborish va lokal saqlash
  Future<void> updateFCMToken(String token) async {
    await _authApi.updateFcmToken(token);
    await _secureStorage.saveFcmToken(token);
  }

  /// Lokal FCM tokenni olish
  Future<String?> getFCMToken() => _secureStorage.getFcmToken();

  /// Parol tiklash
  Future<void> forgotPassword({required String phone}) =>
      _authApi.forgotPassword(phone: phone);

  /// Token mavjudligini tekshirish (tez auth holat tekshiruvi)
  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Tokenni qaytarish
  Future<String?> getAccessToken() async {
    return _secureStorage.getAccessToken();
  }

  /// QR Kod orqali login
  Future<UserModel> qrLogin({required String qrToken}) async {
    return safeExecute(() async {
      final response = await _authApi.qrLogin(qrToken: qrToken);
      await _secureStorage.saveAccessToken(response.accessToken);
      return response.user;
    });
  }
}
