import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/academic_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/grade_model.dart';
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
  void _loadGradesForSelectedChild() {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    final quarter = ref.read(gradesProvider).selectedQuarter;
    ref.read(gradesProvider.notifier).loadGrades(
          selectedChild.id,
          quarter: quarter,
        );
  }

  void _loadAttendanceForSelectedChild() {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    ref.read(attendanceProvider.notifier).loadAttendance(
          selectedChild.id,
          month: month,
        );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadGradesForSelectedChild();
      _loadAttendanceForSelectedChild();
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
    if (grade >= 5) return Colors.green;
    if (grade >= 4) return Colors.blue;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gradesProvider);
    final userState = ref.watch(userProvider);
    final attendanceState = ref.watch(attendanceProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadGradesForSelectedChild();
        _loadAttendanceForSelectedChild();
      }
    });

    if (state.isLoading && state.grades.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.grades.isEmpty) {
      return Center(child: Text(state.error!));
    }
    
    final double gpaFromSummary = state.summary.isNotEmpty
        ? state.summary.fold(0.0, (sum, item) => sum + item.averageGrade) /
            state.summary.length
        : 0.0;
    final double gpaFromGrades = state.grades.isNotEmpty
        ? state.grades.fold(0.0, (sum, item) => sum + item.grade) /
            state.grades.length
        : 0.0;
    final fallbackGpa = userState.selectedChild?.averageGrade ?? 0.0;
    final double gpa = (gpaFromSummary > 0
            ? gpaFromSummary
            : (gpaFromGrades > 0 ? gpaFromGrades : fallbackGpa))
        .clamp(0.0, 5.0);

    final attendanceRate = (() {
      final summary = attendanceState.summary;
      if (summary != null && summary.totalDays > 0) {
        return summary.attendancePercentage.round().clamp(0, 100);
      }
      return (userState.selectedChild?.attendancePercentage ?? 0).clamp(0, 100);
    })();

    final summaryBySubject = <String, SubjectGradeSummary>{
      for (final item in state.summary) item.subjectName.toLowerCase(): item,
    };
    final int totalSubjects = state.summary.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Blue Header ───
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.secondaryBlue,
                    ],
                  ),
                ),
              ),
              title: const Text(
                'Mening ko\'rsatkichlarim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
               if (userState.selectedChild != null)
                 Padding(
                   padding: const EdgeInsets.only(right: 16),
                   child: Center(
                     child: CircleAvatar(
                       radius: 16,
                       backgroundImage: userState.selectedChild!.avatarUrl != null 
                           ? NetworkImage(userState.selectedChild!.avatarUrl!) 
                           : null,
                       child: userState.selectedChild!.avatarUrl == null
                           ? Text(userState.selectedChild!.fullName[0]) 
                           : null,
                     ),
                   ),
                 )
            ],
          ),

          // ─── Overall Stats ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: OverallGradeCard(
                gpa: gpa,
                totalLessons: totalSubjects,
                attendanceRate: attendanceRate,
              ),
            ),
          ),

          // ─── Section Title ───
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Fanlar bo\'yicha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // ─── Subject Cards List ───
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final grade = state.grades[index];
                  final summary =
                      summaryBySubject[grade.subjectName.toLowerCase()];
                  final averagePercent = summary != null
                      ? ((summary.averageGrade / 5) * 100).round()
                      : ((grade.grade / 5) * 100).round();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GradeCard(
                      name: grade.subjectName,
                      teacher:
                          grade.teacherName ??
                          summary?.teacherName ??
                          'O\'qituvchi',
                      grade: grade.grade,
                      attendance: attendanceRate,
                      average: averagePercent.clamp(0, 100),
                      icon: _subjectIcon(grade.subjectName),
                      color: _gradeColor(grade.grade),
                    ),
                  );
                },
                childCount: state.grades.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
