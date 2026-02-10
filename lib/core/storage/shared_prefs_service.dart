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
      throw StateError(
          'SharedPrefsService.init() ni main.dart da chaqiring!');
    }
    return _prefs!;
  }

  // ─── String ───
  static Future<bool> setString(String key, String value) {
    return prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  // ─── Bool ───
  static Future<bool> setBool(String key, bool value) {
    return prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  // ─── Int ───
  static Future<bool> setInt(String key, int value) {
    return prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  // ─── Remove ───
  static Future<bool> remove(String key) {
    return prefs.remove(key);
  }

  // ─── Clear All ───
  static Future<bool> clear() {
    return prefs.clear();
  }

  // ─── Contains ───
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }
}
