import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// A static localization holder to bridger the gap for Notifiers and tests
/// where BuildContext is not available.
class AppLocalizationsRegistry {
  static AppLocalizations? _instance;

  static AppLocalizations get instance {
    if (_instance == null) {
      throw StateError('AppLocalizations instance not initialized. Call AppLocalizationsRegistry.update(instance) first.');
    }
    return _instance!;
  }

  static void update(AppLocalizations instance) {
    _instance = instance;
  }
}
