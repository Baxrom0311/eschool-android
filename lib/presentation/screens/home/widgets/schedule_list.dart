import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../providers/academic_provider.dart';

class ScheduleList extends ConsumerWidget {
  const ScheduleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final scheduleAsync = ref.watch(scheduleProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.todayLessonsSectionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push(RouteNames.schedule);
                },
                child: Text(l10n.viewAllAction),
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
                return Center(
                  child: Text(
                    l10n.noLessonsTodayShort,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
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
            error: (err, stack) =>
                Center(child: Text(ApiErrorHandler.readableMessage(err))),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final time = '${classItem.startTime} - ${classItem.endTime}';
    final isActive = classItem.isActive;
    final markText = classItem.markText;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
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
                color: isActive
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? colorScheme.onPrimary.withValues(alpha: 0.9)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  classItem.subjectName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (markText != null && markText.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.onPrimary.withValues(alpha: 0.2)
                        : AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    markText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? colorScheme.onPrimary
                          : AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.room_rounded,
                size: 14,
                color: isActive
                    ? colorScheme.onPrimary.withValues(alpha: 0.9)
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                classItem.roomNumber ?? '-',
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? colorScheme.onPrimary.withValues(alpha: 0.9)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
