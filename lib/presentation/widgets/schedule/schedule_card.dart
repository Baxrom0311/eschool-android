import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Schedule Card - Displays a single lesson in the schedule
///
/// Sprint 5 - Task 1
class ScheduleCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String subjectName;
  final String room;
  final String teacherName;
  final bool isNow;
  final Color color;

  const ScheduleCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.room,
    required this.teacherName,
    this.isNow = false,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Time Section ───
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Text(
                  startTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isNow ? AppColors.primaryBlue : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 30,
                  color: AppColors.border,
                ),
                const SizedBox(height: 4),
                Text(
                  endTime,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ─── Content Card Section ───
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: color,
                    width: 4,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subjectName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isNow)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Hozir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Xona: $room',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          teacherName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
