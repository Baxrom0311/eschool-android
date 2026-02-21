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

  @override
  Widget build(BuildContext context) {
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
                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
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
                              borderRadius: BorderRadius.circular(16),
                              border: isToday && !isSelected
                                  ? Border.all(color: Colors.white, width: 1)
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat(
                                    'E',
                                    'uz',
                                  ).format(day).toUpperCase(),
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
          if (isLoading && schedule.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (hasError && schedule.isEmpty)
            Expanded(
              child: Center(child: Text('Xatolik: ${scheduleAsync.error}')),
            )
          else if (schedule.isEmpty)
            const Expanded(child: Center(child: Text('Darslar mavjud emas')))
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
