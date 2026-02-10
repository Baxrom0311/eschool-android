import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Rating Screen - Class and School student rankings
///
/// Sprint 7 - Task 1
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedTab = 0; // 0: Sinfda, 1: Maktabda

  // Hardcoded Mock Data inside build/state
  final List<Map<String, dynamic>> _topStudents = [
    {'name': 'Rahimov Aziz', 'points': 1200, 'rank': 1, 'isMe': true},
    {'name': 'Karimov Jamshid', 'points': 1050, 'rank': 2},
    {'name': 'Salimova Dilnoza', 'points': 980, 'rank': 3},
  ];

  final List<Map<String, dynamic>> _otherStudents = [
    {'name': 'Umarov Bekzod', 'points': 950, 'rank': 4},
    {'name': 'Tosheva Nodira', 'points': 920, 'rank': 5},
    {'name': 'Aliyev Sardor', 'points': 890, 'rank': 6},
    {'name': 'Qodirova Malika', 'points': 860, 'rank': 7},
    {'name': 'Yusupova Gulnora', 'points': 830, 'rank': 8},
    {'name': 'Sardorbek Aliyev', 'points': 820, 'rank': 9},
    {'name': 'Malika Ergasheva', 'points': 815, 'rank': 10},
    {'name': 'Dilnozaxon Rahmonova', 'points': 810, 'rank': 11},
    {
      'name': 'Azizbek Rahimov',
      'points': 805,
      'rank': 12,
      'isMe': true
    }, // My Rank
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Blue Header with Podium ───
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
              ),
              borderRadius: const BorderRadius.only(
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 2nd Place
                        _PodiumItem(
                          name: _topStudents[1]['name'],
                          score: _topStudents[1]['points'],
                          rank: 2,
                          avatarSize: 65,
                          color: const Color(0xFFC0C0C0), // Silver
                        ),
                        // 1st Place
                        _PodiumItem(
                          name: _topStudents[0]['name'],
                          score: _topStudents[0]['points'],
                          rank: 1,
                          avatarSize: 85,
                          color: const Color(0xFFFFD700), // Gold
                          isFirst: true,
                        ),
                        // 3rd Place
                        _PodiumItem(
                          name: _topStudents[2]['name'],
                          score: _topStudents[2]['points'],
                          rank: 3,
                          avatarSize: 65,
                          color: const Color(0xFFCD7F32), // Bronze
                        ),
                      ],
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
              itemCount: _otherStudents.length,
              itemBuilder: (context, index) {
                final student = _otherStudents[index];

                if (student['isMe'] == true) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.3)),
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
        onTap: () => setState(() => _selectedTab = index),
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

  Widget _buildStudentTile(Map<String, dynamic> student) {
    return ListTile(
      leading: SizedBox(
        width: 70,
        child: Row(
          children: [
            Text(
              '${student['rank']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: student['isMe'] == true
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Text(
                student['name'][0],
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        student['name'],
        style: TextStyle(
          fontSize: 15,
          fontWeight:
              student['isMe'] == true ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Text(
        '${student['points']} ball',
        style: TextStyle(
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
  final int score;
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
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.white.withOpacity(0.2),
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
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
