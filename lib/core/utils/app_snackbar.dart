import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum AppSnackBarType { success, error, info }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    showOnMessenger(messenger, message, type: type);
  }

  static void showOnMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _backgroundColor(type)),
    );
  }

  static Color _backgroundColor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return AppColors.success;
      case AppSnackBarType.error:
        return AppColors.danger;
      case AppSnackBarType.info:
        return AppColors.info;
    }
  }
}
