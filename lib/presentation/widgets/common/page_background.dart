import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A premium wrapper widget that provides a dynamic "Liquid Glass" background.
/// Adapts its gradient and surface handling based on the active theme.
class PageBackground extends StatelessWidget {
  final Widget child;

  const PageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: isDark
              ? [
                  AppColors.slate900,
                  AppColors.slate950,
                  AppColors.slate900.withValues(alpha: 0.8),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ]
              : [
                  AppColors.skyBlue50,
                  AppColors.white,
                  AppColors.slate50,
                  AppColors.slate100.withValues(alpha: 0.3),
                ],
        ),
      ),
      child: Stack(
        children: [
          // ─── Liquid Atmosphere Glows ───
          if (isDark) ...[
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      theme.colorScheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -200,
              left: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.tertiary.withValues(alpha: 0.03),
                      theme.colorScheme.tertiary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

/// A standard configuration for frosted glass effects (Sigma value consistent with 2026 trends)
class LiquidGlass {
  static const double blur = 15.0;
  static double opacity(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? 0.75 : 0.85;
}
