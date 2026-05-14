import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import 'package:parent_school_app/core/theme/app_theme.dart';
import 'common/liquid_glass.dart';

/// Asosiy pastki navigatsiya paneli
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final glass = LiquidGlassTheme.of(context);
    final reduceTransparency = LiquidGlass.shouldReduceTransparency(context);
    final effectiveBlurSigma = reduceTransparency ? 0.0 : glass.blurSigma;

    final navigationBar = DecoratedBox(
      decoration: BoxDecoration(
        color: LiquidGlass.surfaceColor(
          context,
          tint:
              theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: glass.borderColor),
        boxShadow: [
          BoxShadow(
            color: glass.shadowColor.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: l10n.home,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                label: l10n.academics,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.restaurant_outlined,
                label: l10n.menu,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: l10n.paymentShort,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: l10n.profile,
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: effectiveBlurSigma <= 0
            ? navigationBar
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlurSigma,
                  sigmaY: effectiveBlurSigma,
                ),
                child: navigationBar,
              ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isActive
        ? colorScheme.primary
        : theme.bottomNavigationBarTheme.unselectedItemColor ??
              colorScheme.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: Tooltip(
          message: label,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: isActive
                      ? colorScheme.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  border: isActive
                      ? Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.22),
                        )
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
