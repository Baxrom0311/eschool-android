import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'liquid_glass.dart';

/// Shared frosted-glass app bar used by Liquid Glass screens.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = kToolbarHeight + 8,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final glass = LiquidGlassTheme.of(context);
    final reduceTransparency = LiquidGlass.shouldReduceTransparency(context);
    final effectiveBlurSigma = reduceTransparency ? 0.0 : glass.blurSigma;

    final appBar = AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      leading: leading,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: LiquidGlass.surfaceColor(
        context,
        tint: glass.surfaceTint.withValues(alpha: LiquidGlass.opacity(context)),
      ),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );

    return ClipRect(
      child: effectiveBlurSigma <= 0
          ? appBar
          : BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: effectiveBlurSigma,
                sigmaY: effectiveBlurSigma,
              ),
              child: appBar,
            ),
    );
  }
}
