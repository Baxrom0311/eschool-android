import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/academic_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/schedule/schedule_card.dart';

/// Schedule Screen - Weekly Lesson Schedule
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });
  }

  void _loadSchedule() {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild != null) {
      // Select the current weekday in the provider (1-based) first to avoid overwriting AsyncLoading state!
      ref.read(scheduleProvider.notifier).selectDay(_selectedDate.weekday);
      ref.read(scheduleProvider.notifier).loadSchedule(selectedChild.id);
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    ref.read(scheduleProvider.notifier).selectDay(date.weekday);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scheduleAsync = ref.watch(scheduleProvider);

    // Extract data if available
    final scheduleData = scheduleAsync.valueOrNull;
    final schedule = scheduleData?.todaySchedule ?? [];
    final isLoading = scheduleAsync.isLoading;
    final hasError = scheduleAsync.hasError;

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadSchedule();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ─── Premium Header ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l10n.scheduleTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // ─── Date Strip ───
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(7, (index) {
                        // Current week starting from Monday
                        final now = DateTime.now();
                        final firstDayOfWeek = now.subtract(
                          Duration(days: now.weekday - 1),
                        );
                        final day = firstDayOfWeek.add(Duration(days: index));
                        final isSelected =
                            day.day == _selectedDate.day &&
                            day.month == _selectedDate.month;
                        final isToday =
                            day.day == now.day && day.month == now.month;

                        return GestureDetector(
                          onTap: () => _onDateSelected(day),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.white 
                                    : (isToday ? Colors.white.withValues(alpha: 0.4) : Colors.transparent),
                                width: 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat(
                                    'E',
                                    l10n.appLocale.name,
                                  ).format(day).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Schedule List ───
          if (isLoading && schedule.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (hasError && schedule.isEmpty)
            Expanded(child: Center(child: Text('${scheduleAsync.error}')))
          else if (schedule.isEmpty)
            Expanded(child: Center(child: Text(l10n.noScheduleAvailable)))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                itemCount: schedule.length,
                itemBuilder: (context, index) {
                  final item = schedule[index];
                  final isToday =
                      _selectedDate.day == DateTime.now().day &&
                      _selectedDate.month == DateTime.now().month &&
                      _selectedDate.year == DateTime.now().year;
                  final isNow = isToday && item.isActive;

                  return ScheduleCard(
                    startTime: item.startTime,
                    endTime: item.endTime,
                    subjectName: item.subjectName,
                    room: item.roomNumber ?? '',
                    teacherName: item.teacherName,
                    markText: item.markText,
                    isNow: isNow,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
