import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

/// Schedule Card - Displays a single lesson in the schedule
class ScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String subjectName;
  final String room;
  final String teacherName;
  final String? markText;
  final bool isNow;
  final Color? color;

  const ScheduleCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.room,
    required this.teacherName,
    this.markText,
    this.isNow = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Time Indicator ───
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Text(
                  startTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isNow ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isNow ? theme.colorScheme.primary : theme.dividerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (isNow ? theme.colorScheme.primary : AppColors.slate400).withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isNow ? theme.colorScheme.primary : theme.dividerColor),
                          theme.dividerColor.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ─── Content Card Section ───
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: (isNow ? theme.colorScheme.primary : colorScheme.outline).withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subjectName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (markText != null && markText!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            markText!,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      if (isNow)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryBlue, AppColors.blue400],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            l10n.currentLessonBadge.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoItem(
                        icon: Icons.location_on_rounded,
                        label: l10n.roomLabelText(room),
                        color: AppColors.slate500,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.person_rounded,
                          label: teacherName,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
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
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
