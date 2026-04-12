import 'package:flutter/material.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'animated_pressable.dart';

/// Premium Custom Button - Liquid Glass Standard
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final List<Color>? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 62,
    this.borderRadius = 32, // Bento 2.0 Standard
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isOutlined) {
      final outlineColor = backgroundColor ?? colorScheme.primary;
      final outlineTextColor = textColor ?? outlineColor;

      return AnimatedPressable(
        onTap: isLoading ? null : onPressed,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: outlineColor.withValues(alpha: 0.5), width: 1.5),
          ),
          alignment: Alignment.center,
          child: _buildChild(outlineTextColor),
        ),
      );
    }

    // Default Gradient (Liquid Indigo) if no background color is provided
    final buttonGradient = gradient ?? (backgroundColor == null ? AppColors.liquidIndigo : null);
    final filledColor = backgroundColor ?? colorScheme.primary;
    final filledTextColor = textColor ?? Colors.white;

    return AnimatedPressable(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: buttonGradient == null ? filledColor : null,
          gradient: buttonGradient != null ? LinearGradient(
            colors: buttonGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (buttonGradient?.first ?? filledColor).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _buildChild(filledTextColor),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
