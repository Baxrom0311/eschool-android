import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../common/animated_pressable.dart';
import '../common/liquid_glass.dart';

/// Payment Method Card - Represents a payment provider (Click, PayMe, etc.)
class PaymentMethodCard extends StatelessWidget {
  final String name;
  final String logoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.name,
    required this.logoUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedPressable(
      onTap: onTap,
      child: LiquidGlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        borderRadius: BorderRadius.circular(32),
        borderColor: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.58)
            : theme.colorScheme.outline.withValues(alpha: 0.20),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 24 : 14,
            offset: const Offset(0, 8),
          ),
        ],
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate100),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.slate300,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSelected ? 'SELECTED METHOD' : 'AVAILABLE METHOD',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : AppColors.slate400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
