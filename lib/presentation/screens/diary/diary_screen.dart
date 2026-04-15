import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../data/models/diary_model.dart';
import '../../providers/diary_provider.dart';
import '../../providers/user_provider.dart';

/// Elektron Kundalik — haftalik ko'rinish, kunlik tafsilot
class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  int? _expandedDayIndex;
  DateTime _currentWeekStart = _mondayOfThisWeek();

  static DateTime _mondayOfThisWeek() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiary();
    });
  }

  void _loadDiary() {
    final child = ref.read(selectedChildProvider);
    if (child != null) {
      final weekStr = _formatDate(_currentWeekStart);
      ref.read(diaryProvider.notifier).loadWeeklyDiary(child.id, weekStart: weekStr);
    }
  }

  void _navigateWeek(int direction) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * direction));
      _expandedDayIndex = null;
    });
    _loadDiary();
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(diaryProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        final weekStr = _formatDate(_currentWeekStart);
        ref.read(diaryProvider.notifier).loadWeeklyDiary(next.id, weekStart: weekStr);
      }
    });

    final days = state.weeklyDiary?.days ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // ─── Header ───
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    Text(
                      l10n.diaryTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeekNavigator(context),
                  ],
                ),
              ),
            ),
          ),

          // ─── Days List ───
          Expanded(
            child: _buildBody(state, days, l10n, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    DiaryState state,
    List<DiaryDayModel> days,
    dynamic l10n,
    ColorScheme colorScheme,
  ) {
    if (state.isLoading && state.weeklyDiary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.weeklyDiary == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            Text(l10n.diaryLoadFailed,
                style: TextStyle(color: colorScheme.onSurface)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadDiary,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (days.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded,
                size: 64,
                color: colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(l10n.diaryNoData,
                style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: days.length,
      itemBuilder: (context, index) {
        return _DayCard(
          day: days[index],
          isExpanded: _expandedDayIndex == index,
          onToggle: () {
            setState(() {
              _expandedDayIndex = _expandedDayIndex == index ? null : index;
            });
          },
        );
      },
    );
  }

  Widget _buildWeekNavigator(BuildContext context) {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('dd.MM', context.l10n.intlLocaleTag);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _navigateWeek(-1),
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '${dateFormat.format(_currentWeekStart)} — ${dateFormat.format(weekEnd)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          IconButton(
            onPressed: () => _navigateWeek(1),
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Day Card — expandable card for each day
// ═══════════════════════════════════════════════════════════════

class _DayCard extends StatelessWidget {
  final DiaryDayModel day;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DayCard({
    required this.day,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = _isToday(day.date);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isToday
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.4), width: 2)
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day Header
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Day indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayNumber(day.date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isToday ? Colors.white : colorScheme.primary,
                          ),
                        ),
                        Text(
                          day.dayName.length > 3
                              ? day.dayName.substring(0, 3)
                              : day.dayName,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isToday
                                ? Colors.white.withValues(alpha: 0.8)
                                : colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.dayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.book_outlined,
                              text: l10n.diaryLessonsCount(day.lessonCount),
                              color: colorScheme.primary,
                            ),
                            if (day.avgGrade != null) ...[
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.star_rounded,
                                text: l10n.diaryAvgGrade(
                                    day.avgGrade!.toStringAsFixed(1)),
                                color: _gradeColor(day.avgGrade!),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: day.presentCount == day.lessonCount
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${day.presentCount}/${day.lessonCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: day.presentCount == day.lessonCount
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Lessons
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: day.lessons.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.diaryNoLessons,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        ...day.lessons
                            .map((lesson) => _LessonTile(lesson: lesson)),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  bool _isToday(String date) {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return false;
    return parsed.year == now.year &&
        parsed.month == now.month &&
        parsed.day == now.day;
  }

  String _dayNumber(String date) {
    final parsed = DateTime.tryParse(date);
    return parsed != null ? parsed.day.toString() : '';
  }

  Color _gradeColor(double grade) {
    if (grade >= 4.5) return AppColors.grade5;
    if (grade >= 3.5) return AppColors.grade4;
    if (grade >= 2.5) return AppColors.grade3;
    return AppColors.grade1;
  }
}

// ═══════════════════════════════════════════════════════════════
// Lesson Tile
// ═══════════════════════════════════════════════════════════════

class _LessonTile extends StatelessWidget {
  final DiaryLessonModel lesson;

  const _LessonTile({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: colorScheme.outline.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.menu_book_rounded,
                    size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.subject,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(lesson.teacher,
                        style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.5))),
                  ],
                ),
              ),
              if (lesson.attStatus != null)
                _AttendanceBadge(status: lesson.attStatus!),
              if (lesson.grade != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        _gradeColor(lesson.grade!).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      lesson.grade!.toInt().toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: _gradeColor(lesson.grade!),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (lesson.topic != null && lesson.topic!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.topic_outlined,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(lesson.topic!,
                      style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.7))),
                ),
              ],
            ),
          ],
          if (lesson.homeworkNote != null &&
              lesson.homeworkNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.amber.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 15, color: AppColors.amber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(lesson.homeworkNote!,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.7))),
                  ),
                ],
              ),
            ),
          ],
          if (lesson.teacherComment != null &&
              lesson.teacherComment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.comment_outlined,
                      size: 15, color: AppColors.info),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(lesson.teacherComment!,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.7))),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _gradeColor(double grade) {
    if (grade >= 4.5) return AppColors.grade5;
    if (grade >= 3.5) return AppColors.grade4;
    if (grade >= 2.5) return AppColors.grade3;
    return AppColors.grade1;
  }
}

class _AttendanceBadge extends StatelessWidget {
  final String status;
  const _AttendanceBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      'P' => (AppColors.success, Icons.check_circle_outline_rounded),
      'A' => (AppColors.danger, Icons.cancel_outlined),
      'L' => (AppColors.amber, Icons.access_time_rounded),
      'E' => (AppColors.info, Icons.verified_outlined),
      _ => (AppColors.slate400, Icons.help_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
