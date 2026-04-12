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
    final gradesAsync = ref.watch(gradesProvider);
    final userState = ref.watch(userProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadGradesForSelectedChild();
      }
    });

    return gradesAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      error: (err, stack) => _GradesErrorView(
        message: err.toString(),
        onRetry: _loadGradesForSelectedChild,
      ),
      data: (gradesData) {
        final grades = gradesData.grades;
        final summary = gradesData.summary;

        if (grades.isEmpty && summary.isEmpty) {
          return Center(
            child: Text(
              l10n.noGradesAvailable,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        final double gpaFromSummary = summary.isNotEmpty
            ? summary.fold<double>(0.0, (sum, item) => sum + item.averageGrade) / summary.length
            : 0.0;
        final double gpaFromGrades = grades.isNotEmpty
            ? grades.fold<double>(0.0, (sum, item) => sum + item.grade) / grades.length
            : 0.0;
        
        final double gpa = (gpaFromSummary > 0 ? gpaFromSummary : (gpaFromGrades > 0 ? gpaFromGrades : (userState.selectedChild?.averageGrade ?? 0.0)))
            .clamp(0.0, 5.0).toDouble();

        final attendanceRate = (() {
          final attData = attendanceAsync.valueOrNull;
          if (attData?.summary != null && attData!.summary!.totalDays > 0) {
            return attData.summary!.attendancePercentage.round().clamp(0, 100);
          }
          return (userState.selectedChild?.attendancePercentage ?? 0).toInt().clamp(0, 100);
        })();

        final summaryBySubject = <String, SubjectGradeSummary>{
          for (final item in summary) item.subjectName.toLowerCase(): item,
        };

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // Overall Results Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: OverallGradeCard(
                  gpa: gpa,
                  totalLessons: summary.length,
                  attendanceRate: attendanceRate,
                  className: userState.selectedChild?.className ?? '-',
                ),
              ),
            ),

            // Section Header
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  l10n.gradesBySubjectTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),

            // Grades List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final grade = grades[index];
                    final summaryItem = summaryBySubject[grade.subjectName.toLowerCase()];
                    final averagePercent = summaryItem != null
                        ? ((summaryItem.averageGrade / 5) * 100).round()
                        : ((grade.grade / 5) * 100).round();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                  },
                  childCount: grades.length,
                ),
              ),
            ),
          ],
        );
      },
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.backendErrorTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
