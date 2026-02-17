import 'package:shared_preferences/shared_preferences.dart';

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

  static bool get isInitialized => _prefs != null;

  // ─── String ───
  static Future<bool> setString(String key, String value) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // ─── Bool ───
  static Future<bool> setBool(String key, bool value) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // ─── Int ───
  static Future<bool> setInt(String key, int value) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // ─── Remove ───
  static Future<bool> remove(String key) {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.remove(key);
  }

  // ─── Clear All ───
  static Future<bool> clear() {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return Future.value(false);
    return currentPrefs.clear();
  }

  // ─── Contains ───
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // ─── Keys ───
  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? const <String>{};
  }

  // ─── Remove By Prefix ───
  static Future<void> removeByPrefix(String prefix) async {
    final currentPrefs = _prefs;
    if (currentPrefs == null) return;

    final keys = currentPrefs
        .getKeys()
        .where((key) => key.startsWith(prefix))
        .toList();

    for (final key in keys) {
      await currentPrefs.remove(key);
    }
  }
}
