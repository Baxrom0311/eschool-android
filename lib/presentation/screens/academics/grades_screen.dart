import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/grades/grade_card.dart';
import '../../widgets/grades/overall_grade_card.dart';

/// Grades Screen - Subject Grades List
///
/// Sprint 2 - Academics Module
/// Dev1 Responsibility
///
/// Design: Vertical list of subject cards with grades and progress
class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  // Mock data for subjects
  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Matematika',
      'teacher': 'Aziza Karimova',
      'grade': 5,
      'attendance': 100,
      'average': 98,
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFF4CAF50), // Green
    },
    {
      'name': 'Ingliz tili',
      'teacher': 'Dilnoza Rahimova',
      'grade': 5,
      'attendance': 95,
      'average': 92,
      'icon': Icons.language_rounded,
      'color': const Color(0xFF2196F3), // Blue
    },
    {
      'name': 'Fizika',
      'teacher': 'Sardor Aliyev',
      'grade': 4,
      'attendance': 98,
      'average': 88,
      'icon': Icons.science_rounded,
      'color': const Color(0xFFFF9800), // Orange
    },
    {
      'name': 'Kimyo',
      'teacher': 'Malika Tosheva',
      'grade': 5,
      'attendance': 100,
      'average': 95,
      'icon': Icons.biotech_rounded,
      'color': const Color(0xFF9C27B0), // Purple
    },
    {
      'name': 'Tarix',
      'teacher': 'Jamshid Umarov',
      'grade': 4,
      'attendance': 92,
      'average': 85,
      'icon': Icons.history_edu_rounded,
      'color': const Color(0xFF795548), // Brown
    },
    {
      'name': 'Adabiyot',
      'teacher': 'Nodira Yusupova',
      'grade': 5,
      'attendance': 100,
      'average': 96,
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFE91E63), // Pink
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
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
          ),

          // ─── Overall Stats ───
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: OverallGradeCard(
                gpa: 4.8,
                totalLessons: 124,
                attendanceRate: 98,
              ),
            ),
          ),

          // ─── Section Title ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                  final subject = subjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GradeCard(
                      name: subject['name'],
                      teacher: subject['teacher'],
                      grade: subject['grade'],
                      attendance: subject['attendance'],
                      average: subject['average'],
                      icon: subject['icon'],
                      color: subject['color'],
                    ),
                  );
                },
                childCount: subjects.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
