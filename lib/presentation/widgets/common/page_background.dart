import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A wrapper widget that provides a premium subtle background gradient.
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  theme.scaffoldBackgroundColor,
                  AppColors.slate800.withValues(alpha: 0.5),
                ]
              : [
                  theme.scaffoldBackgroundColor,
                  AppColors.skyBlue50.withValues(alpha: 0.3),
                ],
        ),
      ),
      child: child,
    );
  }
}
