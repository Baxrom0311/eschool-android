import '../../core/constants/storage_keys.dart';
import '../../core/storage/secure_storage.dart';
import '../datasources/remote/auth_api.dart';
import '../models/parent_login_response.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// Auth Repository — Autentifikatsiya biznes logikasi
class AuthRepository extends BaseRepository {
  final AuthApi _authApi;
  final SecureStorageService _secureStorage;

  AuthRepository({
    required AuthApi authApi,
    required SecureStorageService secureStorage,
  }) : _authApi = authApi,
       _secureStorage = secureStorage;

  /// Login — tizimga kirish (Central)
  Future<ParentLoginResponse> login({
    required String username,
    required String password,
  }) async {
    return safeExecute(() async {
      final response = await _authApi.login(
        username: username,
        password: password,
      );
      
      // Save central token
      await _secureStorage.write('central_token', response.centralToken);

      // If auto-tenant is provided, save it
      if (response.autoTenant != null) {
        await saveTenantSession(
          host: response.autoTenant!.host,
          token: response.autoTenant!.token,
          studentId: response.autoTenant!.studentId,
        );
      }

      return response;
    });
  }

  Future<void> issueTenantToken({
    required int studentId,
    required String tenantId,
    required String host,
  }) async {
    return safeExecute(() async {
      final response = await _authApi.issueTenantToken(
        studentId: studentId,
        tenantId: tenantId,
      );
      
      await saveTenantSession(
        host: host,
        token: response.accessToken,
        studentId: studentId,
      );
    });
  }

  Future<void> saveTenantSession({
    required String host,
    required String token,
    required int studentId,
  }) async {
    await _secureStorage.write(StorageKeys.tenantHost, host);
    await _secureStorage.saveAccessToken(token);
    await _secureStorage.write(StorageKeys.selectedChildId, studentId.toString());
    await _secureStorage.write(StorageKeys.isLoggedIn, 'true');
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
