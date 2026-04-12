import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../data/models/attendance_model.dart';
import '../../providers/academic_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/services/socket_service.dart';
import '../../providers/auth_provider.dart';

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
      _setupSocketListener();
    });
  }

  void _setupSocketListener() {
    final auth = ref.read(authProvider);
    final socket = ref.read(socketServiceProvider);
    
    if (socket != null && auth.user != null) {
      socket.listenPrivate(
        'parent.${auth.user!.id}',
        'attendance.marked',
        (data) {
          // Ma'lumot kelganda barcha davomatni qayta yuklash
          _loadAttendance(_focusedDay);
        },
      );
    }
  }

  @override
  void dispose() {
    final auth = ref.read(authProvider);
    final socket = ref.read(socketServiceProvider);
    if (socket != null && auth.user != null) {
      socket.leaveChannel('parent.${auth.user!.id}');
    }
    super.dispose();
  }

  void _loadAttendance(DateTime date) {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild != null) {
      final monthStr = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      ref
          .read(attendanceProvider.notifier)
          .loadAttendance(selectedChild.id, month: monthStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final attendanceAsync = ref.watch(attendanceProvider);
    final attendanceData = attendanceAsync.valueOrNull;
    final hasError = attendanceAsync.hasError;
    final errorMessage = attendanceAsync.error?.toString();
    final summary = attendanceData?.summary;
    final records = attendanceData?.records ?? [];
    final isLoading = attendanceAsync.isLoading;

    final Map<DateTime, AttendanceStatus> attendanceMap = {};
    for (var record in records) {
      try {
        final date = DateTime.parse(record.date);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        attendanceMap[normalizedDate] = record.status;
      } catch (_) {
        // Skip records with unparseable dates
      }
    }

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadAttendance(_focusedDay);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── Premium Header ───
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
              ),
              title: Text(
                l10n.attendanceTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  if (hasError && errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _InlineErrorBanner(message: errorMessage),
                    ),
                  
                  // ─── Stats Row (Premium Design) ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: l10n.attendanceTotalLessonsLabel.toUpperCase(),
                            value: summary?.totalDays.toString() ?? '-',
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            label: l10n.attendancePresentLabel.toUpperCase(),
                            value: summary?.presentDays.toString() ?? '-',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            label: l10n.attendanceAbsentLabel.toUpperCase(),
                            value: summary?.absentDays.toString() ?? '-',
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Calendar Card ───
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        TableCalendar(
                          locale: Localizations.localeOf(context).languageCode,
                          firstDay: DateTime.now().subtract(const Duration(days: 365)),
                          lastDay: DateTime.now().add(const Duration(days: 30)),
                          focusedDay: _focusedDay,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                            leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryBlue),
                            rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                            weekendStyle: TextStyle(
                              color: AppColors.danger.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600),
                            weekendTextStyle: TextStyle(
                              color: AppColors.danger.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                            todayDecoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w900,
                            ),
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
                          ),
                        ),
                        if (isLoading)
                          const Positioned.fill(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),

                  // ─── Legend ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LegendItem(label: l10n.attendancePresentLegend, color: AppColors.success),
                        _LegendItem(label: l10n.attendanceAbsentLegend, color: AppColors.danger),
                        _LegendItem(label: l10n.attendanceLateLegend, color: Colors.amber),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMarker(DateTime day, AttendanceStatus status) {
    Color color;
    switch (status) {
      case AttendanceStatus.present:
        color = AppColors.success;
        break;
      case AttendanceStatus.absent:
        color = AppColors.danger;
        break;
      case AttendanceStatus.late_:
        color = Colors.amber;
        break;
      case AttendanceStatus.excused:
        color = Colors.blueGrey;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Text(
        day.day.toString(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: color.withValues(alpha: 0.9),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  final String message;
  const _InlineErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 12, color: colorScheme.onErrorContainer, height: 1.4, fontWeight: FontWeight.w600),
      ),
    );
  }
}
