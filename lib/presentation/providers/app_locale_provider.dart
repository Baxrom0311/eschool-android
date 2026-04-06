import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/localization/app_locale.dart';
import '../../core/storage/shared_prefs_service.dart';

class AppLocaleNotifier extends StateNotifier<AppLocale> {
  AppLocaleNotifier()
    : super(
        appLocaleFromCode(SharedPrefsService.getString(StorageKeys.language)),
      );

  Future<void> setLocale(AppLocale locale) async {
    if (state == locale) return;
    state = locale;
    await SharedPrefsService.setString(StorageKeys.language, locale.code);
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, AppLocale>((
  ref,
) {
  return AppLocaleNotifier();
});
