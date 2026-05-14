import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// A premium wrapper widget that provides a dynamic "Liquid Glass" background.
/// Adapts its gradient and surface handling based on the active theme.
class PageBackground extends StatelessWidget {
  final Widget child;

  const PageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (_PageBackgroundScope.isActive(context)) {
      return child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _PageBackgroundScope(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.24, 0.58, 1.0],
            colors: isDark
                ? const [
                    AppColors.slate950,
                    Color(0xFF071827),
                    Color(0xFF0B2840),
                    AppColors.slate900,
                  ]
                : const [
                    AppColors.aqua50,
                    Color(0xFFF8FDFF),
                    Color(0xFFEFF7FF),
                    Color(0xFFF7F3FF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            const _LiquidAuroraLayer(),
            const _GlassNoiseOverlay(),
            child,
          ],
        ),
      ),
    );
  }
}

class _PageBackgroundScope extends InheritedWidget {
  const _PageBackgroundScope({required super.child});

  static bool isActive(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_PageBackgroundScope>() !=
        null;
  }

  @override
  bool updateShouldNotify(_PageBackgroundScope oldWidget) => false;
}

class _LiquidAuroraLayer extends StatelessWidget {
  const _LiquidAuroraLayer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IgnorePointer(
      child: Stack(
        children: [
          _LiquidBlob(
            alignment: Alignment.topRight,
            offset: const Offset(110, -140),
            size: 430,
            colors: [
              theme.colorScheme.primary.withValues(alpha: isDark ? 0.28 : 0.30),
              AppColors.aqua200.withValues(alpha: isDark ? 0.06 : 0.20),
              Colors.transparent,
            ],
          ),
          _LiquidBlob(
            alignment: Alignment.centerLeft,
            offset: const Offset(-210, -20),
            size: 520,
            colors: [
              theme.colorScheme.secondary.withValues(alpha: isDark ? 0.18 : 0.20),
              AppColors.pink500.withValues(alpha: isDark ? 0.05 : 0.10),
              Colors.transparent,
            ],
          ),
          _LiquidBlob(
            alignment: Alignment.bottomRight,
            offset: const Offset(160, 170),
            size: 560,
            colors: [
              theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.15 : 0.16),
              AppColors.aqua300.withValues(alpha: isDark ? 0.05 : 0.14),
              Colors.transparent,
            ],
          ),
        ],
      ),
    );
  }
}

class _LiquidBlob extends StatelessWidget {
  const _LiquidBlob({
    required this.alignment,
    required this.offset,
    required this.size,
    required this.colors,
  });

  final Alignment alignment;
  final Offset offset;
  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: colors),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNoiseOverlay extends StatelessWidget {
  const _GlassNoiseOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: isDark ? 0.03 : 0.22),
              Colors.white.withValues(alpha: isDark ? 0.00 : 0.03),
              Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
