import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../common/liquid_glass.dart';

/// Grade Card - Displays subject information, grade, and progress with Bento 2.0 design
class GradeCard extends StatelessWidget {
  final String name;
  final String teacher;
  final int grade;
  final int attendance;
  final int average;
  final IconData icon;
  final Color color;

  const GradeCard({
    super.key,
    required this.name,
    required this.teacher,
    required this.grade,
    required this.attendance,
    required this.average,
    required this.icon,
    required this.color,
  });

  Color get gradeColor {
    if (grade >= 5) return AppColors.success;
    if (grade >= 4) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(22),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.20 : 0.04,
          ),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              // Subject Icon Container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),

              // Subject Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      teacher,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Grade Badge
              LiquidGlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                borderRadius: BorderRadius.circular(14),
                backgroundColor: gradeColor.withValues(alpha: 0.10),
                borderColor: gradeColor.withValues(alpha: 0.16),
                boxShadow: const [],
                blurSigma: 10,
                child: Text(
                  grade.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: gradeColor,
                    fontSize: 22,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Double Progress Row
          Row(
            children: [
              Expanded(
                child: _buildAdaptiveProgress(
                  context,
                  l10n.attendanceStatLabel.toUpperCase(),
                  attendance,
                  attendance >= 95 ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildAdaptiveProgress(
                  context,
                  l10n.averageShortLabel.toUpperCase(),
                  average,
                  average >= 90 ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveProgress(BuildContext context, String label, int value, Color progressColor) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
