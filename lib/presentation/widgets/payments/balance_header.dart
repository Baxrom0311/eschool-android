import 'package:flutter/material.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../common/liquid_glass.dart';

/// Balance Header - Visual display of account balance with Bento 2.0 aesthetic
class BalanceHeader extends StatelessWidget {
  final String balance;
  final String lastUpdated;

  const BalanceHeader({
    super.key,
    required this.balance,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? AppColors.liquidIndigo
              : AppColors.skyGradientLight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.liquidIndigo.first : AppColors.skyBlue400).withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background abstraction: Liquid Glass Orb Glow
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : AppColors.slate900).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: (isDark ? Colors.white : AppColors.slate900).withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      l10n.accountBalanceTitle.toUpperCase(),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.slate900,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.contactless_rounded,
                    color: isDark ? Colors.white54 : AppColors.slate500,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 36),
              FittedBox(
                child: Text(
                  balance,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.slate900,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2.0,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              LiquidGlassPanel(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                backgroundColor: (isDark ? Colors.black : Colors.white)
                    .withValues(alpha: 0.15),
                borderColor: (isDark ? Colors.white : AppColors.slate900)
                    .withValues(alpha: 0.05),
                boxShadow: const [],
                blurSigma: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: isDark ? Colors.white70 : AppColors.slate600,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lastUpdated.toUpperCase(),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppColors.slate600,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
