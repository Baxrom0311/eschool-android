import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/attendance_model.dart';
import '../../providers/academic_provider.dart';
import '../../providers/user_provider.dart';

/// Attendance Screen - Monthly Attendance Calendar and Stats
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendance(_focusedDay);
    });
  }

  void _loadAttendance(DateTime date) {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild != null) {
      // Format month as "yyyy-MM"
      final monthStr = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      ref.read(attendanceProvider.notifier).loadAttendance(
            selectedChild.id,
            month: monthStr,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    final summary = attendanceState.summary;
    final records = attendanceState.records;
    final isLoading = attendanceState.isLoading;

    // Convert List<AttendanceModel> to Map<DateTime, AttendanceStatus> for calendar
    final Map<DateTime, AttendanceStatus> attendanceMap = {};
    for (var record in records) {
      try {
        final date = DateTime.parse(record.date);
        // Normalize to date only (year, month, day) to match TableCalendar
        final normalizedDate = DateTime(date.year, date.month, date.day);
        attendanceMap[normalizedDate] = record.status;
      } catch (e) {
        // Handle parse error
      }
    }
    
    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadAttendance(_focusedDay);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Davomat statistikasi'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Stats Row ───
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Jami darslar',
                      value: summary?.totalDays.toString() ?? '-',
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Qatnashdi',
                      value: summary?.presentDays.toString() ?? '-',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Sababsiz',
                      value: summary?.absentDays.toString() ?? '-',
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Calendar Card ───
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                   TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _focusedDay,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                    onPageChanged: (focusedDay) {
                      setState(() {
                         _focusedDay = focusedDay;
                      });
                      _loadAttendance(focusedDay);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        final status = attendanceMap[normalizedDay];
                        if (status != null) {
                          return _buildDayMarker(day, status);
                        }
                        return null;
                      },
                      todayBuilder: (context, day, focusedDay) {
                        // Check if today has a status, if so, show status, else show today marker
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        final status = attendanceMap[normalizedDay];
                         if (status != null) {
                          return _buildDayMarker(day, status);
                        }
                        return _buildDayMarker(day, null, isToday: true);
                      },
                    ),
                  ),
                  if (isLoading)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),

            // ─── Legend ───
            const Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendItem(label: 'Bor', color: AppColors.success),
                  _LegendItem(label: 'Yo\'q', color: AppColors.danger),
                  _LegendItem(label: 'Kechikkan', color: Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayMarker(DateTime day, AttendanceStatus? status, {bool isToday = false}) {
    Color color = Colors.transparent;
    Color textColor = AppColors.textPrimary;
    
    if (status != null) {
      switch (status) {
        case AttendanceStatus.present:
          color = AppColors.success;
          textColor = AppColors.success;
          break;
        case AttendanceStatus.absent:
          color = AppColors.danger;
          textColor = AppColors.danger;
          break;
        case AttendanceStatus.late_:
          color = Colors.amber;
          textColor = Colors.amber[800]!;
          break;
        case AttendanceStatus.excused:
           color = Colors.blueGrey;
           textColor = Colors.blueGrey;
          break;
      }
    } else if (isToday) {
       color = AppColors.primaryBlue;
       textColor = AppColors.primaryBlue;
    } else {
      return Center(child: Text(day.day.toString()));
    }

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        day.day.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
