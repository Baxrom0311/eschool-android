import 'package:flutter/material.dart';

/// A utility widget that provides a fluid layout system based on screen width.
/// Supports Compact (Mobile), Medium (Foldable/Tablet), and Expanded (Large Tablet) breakpoints.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A helper class to get fluid values based on screen width.
class FluidLayout {
  static double space(BuildContext context, double value) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 400) return value * 0.8;
    if (width > 800) return value * 1.2;
    return value;
  }

  static double fontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.sizeOf(context).width;
    // Scale text between 0.9x and 1.1x based on width
    double scale = (width / 400).clamp(0.9, 1.1);
    return baseSize * scale;
  }
}
