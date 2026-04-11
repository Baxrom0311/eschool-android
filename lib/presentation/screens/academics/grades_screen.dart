import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/grade_model.dart';
import '../../providers/academic_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/grades/grade_card.dart';
import '../../widgets/grades/overall_grade_card.dart';

/// Grades Screen - Subject Grades List
///
/// Design: Vertical list of subject cards with grades and progress
class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int? _lastLoadedChildId;

  void _loadGradesForSelectedChild({bool force = false}) {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    final gradesState = ref.read(gradesProvider);
    final currentData = gradesState.valueOrNull;
    final quarter = currentData?.selectedQuarter ?? 1;

    final hasAnyData =
        currentData != null &&
        (currentData.grades.isNotEmpty || currentData.summary.isNotEmpty);
    if (!force &&
        _lastLoadedChildId == selectedChild.id &&
        (gradesState.isLoading || (hasAnyData && !gradesState.hasError))) {
      return;
    }

    _lastLoadedChildId = selectedChild.id;
    ref
        .read(gradesProvider.notifier)
        .loadGrades(selectedChild.id, quarter: quarter);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGradesForSelectedChild();
    });
  }

  IconData _subjectIcon(String subjectName) {
    final value = subjectName.toLowerCase();
    if (value.contains('matemat') || value.contains('algebra')) {
      return Icons.calculate_rounded;
    }
    if (value.contains('ingliz') || value.contains('english')) {
      return Icons.translate_rounded;
    }
    if (value.contains('fizik') || value.contains('kimyo')) {
      return Icons.science_rounded;
    }
    if (value.contains('ona tili') || value.contains('adabiyot')) {
      return Icons.menu_book_rounded;
    }
    return Icons.book_rounded;
  }

  Color _gradeColor(int grade) {
    if (grade >= 5) return AppColors.success;
    if (grade >= 4) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradesAsync = ref.watch(gradesProvider);
    final userState = ref.watch(userProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadGradesForSelectedChild();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: gradesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _GradesErrorView(
          message: err.toString(),
          onRetry: _loadGradesForSelectedChild,
        ),
        data: (gradesData) {
          final grades = gradesData.grades;
          final summary = gradesData.summary;

          if (grades.isEmpty && summary.isEmpty) {
            return Center(child: Text(l10n.noGradesAvailable));
          }

          final double gpaFromSummary = summary.isNotEmpty
              ? summary.fold<double>(
                      0.0,
                      (sum, item) => sum + item.averageGrade,
                    ) /
                    summary.length
              : 0.0;
          final double gpaFromGrades = grades.isNotEmpty
              ? grades.fold<double>(0.0, (sum, item) => sum + item.grade) /
                    grades.length
              : 0.0;
          final fallbackGpa = userState.selectedChild?.averageGrade ?? 0.0;
          final double gpa =
              (gpaFromSummary > 0
                      ? gpaFromSummary
                      : (gpaFromGrades > 0 ? gpaFromGrades : fallbackGpa))
                  .clamp(0.0, 5.0);

          final attendanceRate = (() {
            final attData = attendanceAsync.valueOrNull;
            final summary = attData?.summary;
            if (summary != null && summary.totalDays > 0) {
              return summary.attendancePercentage.round().clamp(0, 100);
            }
            return (userState.selectedChild?.attendancePercentage ?? 0).clamp(0, 100);
          })();

          final summaryBySubject = <String, SubjectGradeSummary>{
            for (final item in summary) item.subjectName.toLowerCase(): item,
          };

          return CustomScrollView(
            slivers: [
              // ─── Premium Header ───
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: AppColors.slate900,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkBlue,
                          AppColors.primaryBlue,
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    l10n.myPerformanceTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  if (userState.selectedChild != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            backgroundImage: userState.selectedChild!.avatarUrl != null
                                ? NetworkImage(userState.selectedChild!.avatarUrl!)
                                : null,
                            child: userState.selectedChild!.avatarUrl == null
                                ? Text(
                                    userState.selectedChild!.fullName[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ─── Overall Stats ───
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: OverallGradeCard(
                    gpa: gpa,
                    totalLessons: summary.length,
                    attendanceRate: attendanceRate,
                    className: userState.selectedChild?.className ?? '-',
                  ),
                ),
              ),

              // ─── Section Title ───
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.gradesBySubjectTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),

              // ─── Subject Cards List ───
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final grade = grades[index];
                    final summaryItem = summaryBySubject[grade.subjectName.toLowerCase()];

                    final averagePercent = summaryItem != null
                        ? ((summaryItem.averageGrade / 5) * 100).round()
                        : ((grade.grade / 5) * 100).round();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GradeCard(
                        name: grade.subjectName,
                        teacher: grade.teacherName ?? summaryItem?.teacherName ?? l10n.teacherLabel,
                        grade: grade.grade,
                        attendance: attendanceRate,
                        average: averagePercent.clamp(0, 100),
                        icon: _subjectIcon(grade.subjectName),
                        color: _gradeColor(grade.grade),
                      ),
                    );
                  }, childCount: grades.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GradesErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _GradesErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.backendErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
