import 'package:flutter/material.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/common/liquid_glass.dart';

class AcademicStats extends StatelessWidget {
  final double gpa;
  final int? rank;

  const AcademicStats({super.key, required this.gpa, this.rank});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPA Card - Larger Bento piece
          Expanded(
            flex: 3,
            child: _BentoStatCard(
              title: l10n.averageGradeTitle,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: AppColors.liquidEmerald,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: (gpa / 5.0).clamp(0.1, 1.0),
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.05,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gpa.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Rank Card - Asymmetrical smaller piece
          Expanded(
            flex: 2,
            child: _BentoStatCard(
              title: l10n.classRankingTitle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiquidGlassPanel(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(100),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.liquidAmber.first.withValues(alpha: 0.15),
                        AppColors.liquidAmber.last.withValues(alpha: 0.05),
                      ],
                    ),
                    borderColor: AppColors.liquidAmber.first.withValues(
                      alpha: 0.14,
                    ),
                    boxShadow: const [],
                    blurSigma: 10,
                    child: const Icon(
                      Icons.military_tech_rounded,
                      size: 36,
                      color: AppColors.amber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rank != null ? '#$rank' : '-',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    l10n.placeSuffix.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoStatCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _BentoStatCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(20),
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
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
