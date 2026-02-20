import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import 'shared_prefs_service.dart';

/// Tokenlarni xavfsiz saqlash (FlutterSecureStorage)
class SecureStorageService {
  final FlutterSecureStorage _storage;
  bool _usePrefsFallback = false;

  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        webOptions: WebOptions(
          dbName: 'school_app_auth',
          publicKey: 'school_app_secret',
        ),
        // Linux va Windows uchun ham kerak bo'lsa qo'shish mumkin
      );

  // ─── Access Token ───
  Future<void> saveAccessToken(String token) async {
    await _write(StorageKeys.accessToken, token);
  }

  Future<String?> getAccessToken() async {
    return await _read(StorageKeys.accessToken);
  }

  Future<void> deleteAccessToken() async {
    await _delete(StorageKeys.accessToken);
  }

  // ─── Refresh Token ───
  Future<void> saveRefreshToken(String token) async {
    await _write(StorageKeys.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return await _read(StorageKeys.refreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _delete(StorageKeys.refreshToken);
  }

  // ─── Save Both ───
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  // ─── Clear All ───
  Future<void> clearAll() async {
    if (_usePrefsFallback) {
      await _delete(StorageKeys.accessToken);
      await _delete(StorageKeys.refreshToken);
      await SharedPrefsService.remove(_prefsKey(StorageKeys.accessToken));
      await SharedPrefsService.remove(_prefsKey(StorageKeys.refreshToken));
      return;
    }
    try {
      await _storage.deleteAll();
      await SharedPrefsService.remove(_prefsKey(StorageKeys.accessToken));
      await SharedPrefsService.remove(_prefsKey(StorageKeys.refreshToken));
    } on PlatformException catch (e) {
      if (_shouldFallbackToPrefs(e)) {
        _usePrefsFallback = true;
        await _delete(StorageKeys.accessToken);
        await _delete(StorageKeys.refreshToken);
        await SharedPrefsService.remove(_prefsKey(StorageKeys.accessToken));
        await SharedPrefsService.remove(_prefsKey(StorageKeys.refreshToken));
        return;
      }
      rethrow;
    }
  }

  // ─── General ───
  Future<void> write(String key, String value) async {
    await _write(key, value);
  }

  Future<String?> read(String key) async {
    return await _read(key);
  }

  Future<void> delete(String key) async {
    await _delete(key);
  }

  String _prefsKey(String key) => '__secure_fallback__$key';

  bool _shouldFallbackToPrefs(PlatformException e) {
    // macOS debug runlarda keychain entitlement yo'q bo'lsa -34018 qaytadi.
    if (defaultTargetPlatform != TargetPlatform.macOS) return false;
    final message = e.message ?? '';
    return e.code == '-34018' ||
        e.code == '13' ||
        message.contains('A required entitlement') ||
        message.contains('OSStatus error 13');
  }

  Future<void> _write(String key, String value) async {
    if (_usePrefsFallback) {
      await SharedPrefsService.setString(_prefsKey(key), value);
      return;
    }
    try {
      await _storage.write(key: key, value: value);
      // Secure storage ishlayotgan holatda fallbackdagi eski qiymatni tozalaymiz.
      await SharedPrefsService.remove(_prefsKey(key));
    } on PlatformException catch (e) {
      if (_shouldFallbackToPrefs(e)) {
        _usePrefsFallback = true;
        await SharedPrefsService.setString(_prefsKey(key), value);
        return;
      }
      rethrow;
    }
  }

  Future<String?> _read(String key) async {
    if (_usePrefsFallback) {
      return SharedPrefsService.getString(_prefsKey(key));
    }
    try {
      final value = await _storage.read(key: key);
      if (value != null && value.isNotEmpty) {
        return value;
      }

      final fallbackValue = SharedPrefsService.getString(_prefsKey(key));
      if (fallbackValue != null && fallbackValue.isNotEmpty) {
        // Keychain o'qishi null qaytargan bo'lsa ham oldingi fallback tokenni yo'qotmaymiz.
        _usePrefsFallback = true;
        return fallbackValue;
      }

      return value;
    } on PlatformException catch (e) {
      if (_shouldFallbackToPrefs(e)) {
        _usePrefsFallback = true;
        return SharedPrefsService.getString(_prefsKey(key));
      }
      rethrow;
    }
  }

  Future<void> _delete(String key) async {
    if (_usePrefsFallback) {
      await SharedPrefsService.remove(_prefsKey(key));
      return;
    }
    try {
      await _storage.delete(key: key);
      await SharedPrefsService.remove(_prefsKey(key));
    } on PlatformException catch (e) {
      if (_shouldFallbackToPrefs(e)) {
        _usePrefsFallback = true;
        await SharedPrefsService.remove(_prefsKey(key));
        return;
      }
      rethrow;
    }
  }
}
