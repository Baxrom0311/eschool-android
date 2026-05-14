import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'custom_button.dart';
import 'liquid_glass.dart';

/// Xatolik va bo'sh holatlarni Liquid Glass uslubida ko'rsatish widgeti.
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LiquidGlassPanel(
          borderRadius: BorderRadius.circular(34),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.18),
                        colorScheme.primary.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(icon, size: 38, color: colorScheme.primary),
                ),
                const SizedBox(height: 18),
                Text(
                  message ?? AppStrings.errorGeneric,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.72),
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  CustomButton(
                    text: AppStrings.retry,
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                    height: 52,
                  ),
                ],
              ],
            ),
          ),
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
