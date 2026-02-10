import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';

/// Attendance Screen - Monthly Attendance Calendar and Stats
///
/// Sprint 5 - Task 3
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();

  // Mock data for attendance
  final Map<DateTime, String> _attendanceData = {
    // Current month
    DateTime(DateTime.now().year, DateTime.now().month, 1): 'present',
    DateTime(DateTime.now().year, DateTime.now().month, 2): 'present',
    DateTime(DateTime.now().year, DateTime.now().month, 3): 'absent',
    DateTime(DateTime.now().year, DateTime.now().month, 4): 'late',
    DateTime(DateTime.now().year, DateTime.now().month, 5): 'present',
    DateTime(DateTime.now().year, DateTime.now().month, 8): 'present',
    DateTime(DateTime.now().year, DateTime.now().month, 9): 'present',
    DateTime(DateTime.now().year, DateTime.now().month, 10): 'late',
  };

  @override
  Widget build(BuildContext context) {
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
                      value: '124',
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Qatnashdi',
                      value: '118',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Sababsiz',
                      value: '2',
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
                    color: AppColors.shadow.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TableCalendar(
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
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final status =
                        _attendanceData[DateTime(day.year, day.month, day.day)];
                    if (status != null) {
                      return _buildDayMarker(day, status);
                    }
                    return null;
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildDayMarker(day, 'today');
                  },
                ),
              ),
            ),

            // ─── Legend ───
            Padding(
              padding: const EdgeInsets.all(24),
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

  Widget _buildDayMarker(DateTime day, String status) {
    Color color;
    switch (status) {
      case 'present':
        color = AppColors.success;
        break;
      case 'absent':
        color = AppColors.danger;
        break;
      case 'late':
        color = Colors.amber;
        break;
      case 'today':
        color = AppColors.primaryBlue.withOpacity(0.2);
        break;
      default:
        return Center(child: Text(day.day.toString()));
    }

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        day.day.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: status == 'today' ? AppColors.primaryBlue : color,
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
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
              color: color.withOpacity(0.8),
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
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
