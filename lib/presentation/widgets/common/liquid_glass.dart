import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Shared helper values for the Liquid Glass visual treatment.
class LiquidGlass {
  const LiquidGlass._();

  static const double blur = 28.0;

  static double opacity(BuildContext context) {
    if (shouldReduceTransparency(context)) return 1;

    return Theme.of(context).brightness == Brightness.dark ? 0.34 : 0.72;
  }

  /// Returns an opaque color when reduced transparency is requested, because
  /// theme glass surfaces intentionally contain alpha and cannot be made solid
  /// by calling [Color.withValues] with a larger alpha value.
  static Color surfaceColor(BuildContext context, {Color? tint}) {
    final glassTint = tint ?? LiquidGlassTheme.of(context).surfaceTint;
    if (!shouldReduceTransparency(context)) return glassTint;

    return Color.alphaBlend(glassTint, Theme.of(context).colorScheme.surface);
  }

  /// Avoid expensive transparent blur layers when the user asks for stronger
  /// contrast or reduced accessible motion. The UI keeps its glass silhouette,
  /// but becomes more opaque and easier to read.
  static bool shouldReduceTransparency(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return false;

    return mediaQuery.highContrast || mediaQuery.accessibleNavigation;
  }
}

/// Reusable frosted-glass panel for custom surfaces that need the same
/// Liquid Glass material as the global theme.
class LiquidGlassPanel extends StatelessWidget {
  const LiquidGlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.boxShadow,
    this.blurSigma,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final glass = LiquidGlassTheme.of(context);
    final reduceTransparency = LiquidGlass.shouldReduceTransparency(context);
    final effectiveBlurSigma =
        reduceTransparency ? 0.0 : (blurSigma ?? glass.blurSigma);
    final baseBackgroundColor = backgroundColor ?? glass.surfaceTint;
    final effectiveBackgroundColor = LiquidGlass.surfaceColor(
      context,
      tint: baseBackgroundColor,
    );

    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? glass.borderColor),
        gradient: gradient ??
            (!reduceTransparency && backgroundColor == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      glass.highlightColor,
                      effectiveBackgroundColor,
                      effectiveBackgroundColor.withValues(alpha: 0.72),
                    ],
                  )
                : null),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: glass.shadowColor.withValues(alpha: 0.20),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: glass.glowColor,
                blurRadius: 36,
                spreadRadius: -22,
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: effectiveBlurSigma <= 0
            ? panel
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlurSigma,
                  sigmaY: effectiveBlurSigma,
                ),
                child: panel,
              ),
      ),
    );
  }
}
