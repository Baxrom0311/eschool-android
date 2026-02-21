import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rating_provider.dart';
import '../../providers/user_provider.dart';
import '../../../data/models/rating_model.dart';
import '../../../data/models/child_model.dart';
import '../../../core/constants/app_colors.dart';

/// Rating Screen - Class and School student rankings
class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _selectedTab = 0; // 0: Sinfda, 1: Maktabda

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSelectedTabData();
    });
  }

  void _loadSelectedTabData({ChildModel? selectedChild}) {
    final child = selectedChild ?? ref.read(selectedChildProvider);
    if (_selectedTab == 0 && child?.classId != null) {
      ref.read(ratingProvider.notifier).loadClassRating(child!.classId!);
      return;
    }
    ref.read(ratingProvider.notifier).loadSchoolRating();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ratingProvider);
    ref.listen(selectedChildProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _loadSelectedTabData(selectedChild: next);
      }
    });

    final currentList = _selectedTab == 0
        ? state.classRating
        : state.schoolRating;

    // Sort to be sure
    final sortedList = List<RatingModel>.from(currentList)
      ..sort((a, b) => a.rank.compareTo(b.rank));

    // Top 3
    final top3 = sortedList.take(3).toList();
    // Others
    final others = sortedList.length > 3
        ? sortedList.sublist(3)
        : <RatingModel>[];

    if (state.isLoading && currentList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Blue Header with Podium ───
          Container(
            width: double.infinity,
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
              bottom: false,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Reyting',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // ─── Segmented Toggle ───
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildToggleButton('Sinfda', 0),
                        _buildToggleButton('Maktabda', 1),
                      ],
                    ),
                  ),

                  // ─── Podium Content ───
                  if (top3.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 2nd Place
                          if (top3.length > 1)
                            _PodiumItem(
                              name: top3[1].studentName,
                              score: top3[1].totalScore,
                              rank: 2,
                              avatarSize: 65,
                              color: const Color(0xFFC0C0C0), // Silver
                            ),
                          // 1st Place
                          if (top3.isNotEmpty)
                            _PodiumItem(
                              name: top3[0].studentName,
                              score: top3[0].totalScore,
                              rank: 1,
                              avatarSize: 85,
                              color: const Color(0xFFFFD700), // Gold
                              isFirst: true,
                            ),
                          // 3rd Place
                          if (top3.length > 2)
                            _PodiumItem(
                              name: top3[2].studentName,
                              score: top3[2].totalScore,
                              rank: 3,
                              avatarSize: 65,
                              color: const Color(0xFFCD7F32), // Bronze
                            ),
                        ],
                      ),
                    ),
                  if (top3.isEmpty && !state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        "Ma'lumot yo'q",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Rankings List ───
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: others.length,
              itemBuilder: (context, index) {
                final student = others[index];

                if (student.isCurrent) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: _buildStudentTile(student),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildStudentTile(student),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          _loadSelectedTabData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryBlue : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentTile(RatingModel student) {
    return ListTile(
      leading: SizedBox(
        width: 70,
        child: Row(
          children: [
            Text(
              '${student.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: student.isCurrent
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Text(
                student.studentName.isNotEmpty ? student.studentName[0] : 'U',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        student.studentName,
        style: TextStyle(
          fontSize: 15,
          fontWeight: student.isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Text(
        '${student.totalScore} ball',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Internal Podium Item Widget
class _PodiumItem extends StatelessWidget {
  final String name;
  final num score; // Changed from int to num to handle double
  final int rank;
  final double avatarSize;
  final Color color;
  final bool isFirst;

  const _PodiumItem({
    required this.name,
    required this.score,
    required this.rank,
    required this.avatarSize,
    required this.color,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFFFD700),
            size: 32,
          ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontSize: avatarSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name.split(' ')[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          '$score',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
