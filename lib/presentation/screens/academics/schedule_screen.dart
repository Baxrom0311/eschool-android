import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
      ref.read(scheduleProvider.notifier).loadSchedule(selectedChild.id);
      // Select the current weekday in the provider (1-based)
      ref.read(scheduleProvider.notifier).selectDay(_selectedDate.weekday);
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    ref.read(scheduleProvider.notifier).selectDay(date.weekday);
  }

  bool _isLessonNow(String start, String end, DateTime date) {
    final today = DateTime.now();
    if (today.year != date.year ||
        today.month != date.month ||
        today.day != date.day) {
      return false;
    }

    final startParts = start.split(':');
    final endParts = end.split(':');
    if (startParts.length < 2 || endParts.length < 2) return false;

    final startHour = int.tryParse(startParts[0]) ?? -1;
    final startMinute = int.tryParse(startParts[1]) ?? -1;
    final endHour = int.tryParse(endParts[0]) ?? -1;
    final endMinute = int.tryParse(endParts[1]) ?? -1;
    if (startHour < 0 || startMinute < 0 || endHour < 0 || endMinute < 0) {
      return false;
    }

    final nowMinutes = today.hour * 60 + today.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider);
    final schedule = scheduleState.todaySchedule;
    final isLoading = scheduleState.isLoading;

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadSchedule();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Blue Header ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue,
                  AppColors.secondaryBlue,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Dars jadvali',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                        final firstDayOfWeek =
                            now.subtract(Duration(days: now.weekday - 1));
                        final day = firstDayOfWeek.add(Duration(days: index));
                        final isSelected = day.day == _selectedDate.day &&
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
                              borderRadius: BorderRadius.circular(16),
                              border: isToday && !isSelected
                                  ? Border.all(color: Colors.white, width: 1)
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('E', 'uz')
                                      .format(day)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (schedule.isEmpty)
             const Expanded(child: Center(child: Text('Darslar mavjud emas')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                itemCount: schedule.length,
                itemBuilder: (context, index) {
                  final item = schedule[index];
                  final isNow =
                      _isLessonNow(item.startTime, item.endTime, _selectedDate);

                  return ScheduleCard(
                    startTime: item.startTime,
                    endTime: item.endTime,
                    subjectName: item.subjectName,
                    room: item.roomNumber ?? '',
                    teacherName: item.teacherName,
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
