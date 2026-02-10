import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/schedule/schedule_card.dart';

/// Schedule Screen - Weekly Lesson Schedule
///
/// Sprint 5 - Task 1
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Mock schedule data inside build method
    final Map<int, List<Map<String, dynamic>>> mockSchedule = {
      1: [
        {
          'startTime': '08:00',
          'endTime': '08:45',
          'subject': 'Matematika',
          'room': '302',
          'teacher': 'Azizova Malika',
          'isNow': false,
        },
        {
          'startTime': '08:55',
          'endTime': '09:40',
          'subject': 'Ona tili',
          'room': '104',
          'teacher': 'Karimov Jamshid',
          'isNow': true,
        },
        {
          'startTime': '10:00',
          'endTime': '10:45',
          'subject': 'Ingliz tili',
          'room': '405',
          'teacher': 'Dilnoza Salimova',
          'isNow': false,
        },
      ],
      2: [
        {
          'startTime': '08:00',
          'endTime': '08:45',
          'subject': 'Tarix',
          'room': '201',
          'teacher': 'Umarov Bekzod',
          'isNow': false,
        },
      ],
      // ... same for other days
    };

    final schedule = mockSchedule[_selectedDate.weekday] ?? mockSchedule[1]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Blue Header ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue,
                  AppColors.secondaryBlue,
                ],
              ),
              borderRadius: const BorderRadius.only(
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
                          onTap: () => setState(() => _selectedDate = day),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.1),
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final item = schedule[index];
                return ScheduleCard(
                  startTime: item['startTime'],
                  endTime: item['endTime'],
                  subjectName: item['subject'],
                  room: item['room'],
                  teacherName: item['teacher'],
                  isNow: item['isNow'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
