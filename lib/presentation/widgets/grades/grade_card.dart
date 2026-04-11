import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

/// Grade Card - Displays subject information, grade, and progress
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
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Container with soft gradient background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),

              // Subject Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Grade Badge - Premium Design
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: gradeColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    grade.toString(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: gradeColor,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Row
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  l10n.attendanceStatLabel.toUpperCase(),
                  attendance,
                  attendance >= 95 ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildProgressItem(
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

  Widget _buildProgressItem(String label, int value, Color progressColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Colors.grey,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: AppColors.slate200.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
