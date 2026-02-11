import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../providers/academic_provider.dart';

class ScheduleList extends ConsumerWidget {
  const ScheduleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bugungi Darslar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push(RouteNames.schedule);
                },
                child: const Text('Barchasi'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: scheduleAsync.when(
            data: (data) {
              final todaySchedule = data.todaySchedule;
              if (todaySchedule.isEmpty) {
                return const Center(
                  child: Text(
                    'Bugun darslar topilmadi',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: todaySchedule.length,
                itemBuilder: (context, index) {
                  return _ScheduleItem(classItem: todaySchedule[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Xatolik: $err')),
          ),
        ),
      ],
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final ScheduleModel classItem;

  const _ScheduleItem({required this.classItem});

  @override
  Widget build(BuildContext context) {
    final time = '${classItem.startTime} - ${classItem.endTime}';
    final isActive = classItem.isActive;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            classItem.subjectName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.room_rounded,
                size: 14,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                classItem.roomNumber ?? '-',
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
