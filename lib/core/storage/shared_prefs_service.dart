import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// SharedPreferences wrapper — oddiy ma'lumotlarni saqlash
class SharedPrefsService {
  static SharedPreferences? _prefs;

  /// main.dart da chaqiriladi
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('SharedPrefsService.init() ni main.dart da chaqiring!');
    }
    return _prefs!;
  }

  static String? _userScope;

  static void setUserScope(int? userId) {
    if (userId == null) {
      _userScope = null;
    } else {
      final tenantStr = ApiConstants.baseUrl.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      _userScope = 't${tenantStr}_u${userId}_';
    }
  }

  static String? getUserScope() => _userScope;

  static String _resolveKey(String key) {
    if (_userScope != null && key.startsWith('cache_')) {
      return '$_userScope$key';
    }
    return key;
  }

  static bool get isInitialized => _prefs != null;

  // ─── String ───
  static Future<bool> setString(String key, String value) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.setString(_resolveKey(key), value);
  }

  static String? getString(String key) {
    return _prefs?.getString(_resolveKey(key));
  }

  // ─── Bool ───
  static Future<bool> setBool(String key, bool value) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.setBool(_resolveKey(key), value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(_resolveKey(key));
  }

  // ─── Int ───
  static Future<bool> setInt(String key, int value) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.setInt(_resolveKey(key), value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(_resolveKey(key));
  }

  // ─── Remove ───
  static Future<bool> remove(String key) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.remove(_resolveKey(key));
  }

  // ─── Clear All ───
  static Future<bool> clear() {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.clear();
  }

  // ─── Contains ───
  static bool containsKey(String key) {
    return _prefs?.containsKey(_resolveKey(key)) ?? false;
  }

  // ─── Keys ───
  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? const <String>{};
  }

  // ─── Remove By Prefix ───
  static Future<void> removeByPrefix(String prefix) async {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return;

    final resolvedPrefix = _resolveKey(prefix);
    final keys = currentPrefs
        .getKeys()
        .where((key) => key.startsWith(resolvedPrefix))
        .toList();

    for (final key in keys) {
      await currentPrefs.remove(key);
    }
  }
}
