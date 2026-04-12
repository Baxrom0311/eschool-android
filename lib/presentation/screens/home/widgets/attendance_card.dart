import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../widgets/common/animated_pressable.dart';

class AttendanceCard extends StatelessWidget {
  final double attendanceRate;
  final int score;
  final int level;

  const AttendanceCard({
    super.key,
    required this.attendanceRate,
    required this.score,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card with Mash Gradient / Abstract Pattern
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                    : AppColors.liquidIndigo,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.liquidIndigo.first).withValues(alpha: isDark ? 0.4 : 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background icon abstraction for depth
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: 140,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStat(
                        l10n.attendanceStatLabel,
                        '${attendanceRate.toStringAsFixed(0)}%',
                        Icons.calendar_today_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildCompactStat(
                        l10n.coinsStatLabel,
                        '$score',
                        Icons.stars_rounded,
                        isEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Level Badge (Integrated Floating Liquid Glass Style with actual blur)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.military_tech_rounded, color: theme.colorScheme.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          l10n.levelBadge(level).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, IconData icon, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEnd) Icon(icon, color: Colors.white70, size: 14),
            if (!isEnd) const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white60,
                letterSpacing: 1.5,
              ),
            ),
            if (isEnd) const SizedBox(width: 8),
            if (isEnd) Icon(icon, color: Colors.white70, size: 14),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.5,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
