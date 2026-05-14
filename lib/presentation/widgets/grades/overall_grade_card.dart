import 'package:flutter/material.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../common/liquid_glass.dart';

/// Overall Grade Card - Displays GPA and summary info with Bento 2.0 aesthetic
class OverallGradeCard extends StatelessWidget {
  final double gpa;
  final int totalLessons;
  final int attendanceRate;
  final String className;

  const OverallGradeCard({
    super.key,
    required this.gpa,
    required this.totalLessons,
    required this.attendanceRate,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.20 : 0.04,
          ),
          blurRadius: 26,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              // GPA Circle with Primary Glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      value: gpa / 5,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gpa.toStringAsFixed(1),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        l10n.averageShortLabel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Message Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.overallPerformanceTitle,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.overallPerformanceSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Statistics Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CompactStat(
                label: l10n.lessonsStatLabel,
                value: totalLessons.toString(),
                icon: Icons.auto_stories_rounded,
                color: theme.colorScheme.primary,
              ),
              _CompactStat(
                label: l10n.attendanceStatLabel,
                value: '$attendanceRate%',
                icon: Icons.event_available_rounded,
                color: AppColors.success,
              ),
              _CompactStat(
                label: l10n.classLabel,
                value: className,
                icon: Icons.hub_rounded,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CompactStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        LiquidGlassPanel(
          padding: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(100),
          backgroundColor: color.withValues(alpha: 0.10),
          borderColor: color.withValues(alpha: 0.14),
          boxShadow: const [],
          blurSigma: 10,
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
