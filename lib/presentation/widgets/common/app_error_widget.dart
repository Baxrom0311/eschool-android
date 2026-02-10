import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Xatolik ko'rsatish widgeti
class AppErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? AppStrings.errorGeneric,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Bo'sh holat uchun (ma'lumot yo'q)
  factory AppErrorWidget.empty({String? message}) {
    return AppErrorWidget(
      message: message ?? AppStrings.noData,
      icon: Icons.inbox_outlined,
    );
  }

  /// Internet yo'q holati
  factory AppErrorWidget.noInternet({VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: AppStrings.noInternet,
      icon: Icons.wifi_off_outlined,
      onRetry: onRetry,
    );
  }
}
