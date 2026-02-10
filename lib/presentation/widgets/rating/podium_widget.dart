import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Podium Widget - Displays the top 3 students in the rating
///
/// Sprint 7 - Rating Module
class PodiumWidget extends StatelessWidget {
  final Map<String, dynamic> first;
  final Map<String, dynamic> second;
  final Map<String, dynamic> third;

  const PodiumWidget({
    super.key,
    required this.first,
    required this.second,
    required this.third,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ─── 2nd Place ───
          _buildPodiumItem(
            data: second,
            rank: 2,
            avatarSize: 65,
            borderColor: const Color(0xFFC0C0C0), // Silver
          ),

          // ─── 1st Place ───
          Transform.translate(
            offset: const Offset(0, -20),
            child: _buildPodiumItem(
              data: first,
              rank: 1,
              avatarSize: 85,
              borderColor: const Color(0xFFFFD700), // Gold
              hasCrown: true,
            ),
          ),

          // ─── 3rd Place ───
          _buildPodiumItem(
            data: third,
            rank: 3,
            avatarSize: 65,
            borderColor: const Color(0xFFCD7F32), // Bronze
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required Map<String, dynamic> data,
    required int rank,
    required double avatarSize,
    required Color borderColor,
    bool hasCrown = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasCrown)
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
                gradient: LinearGradient(
                  colors: [borderColor, borderColor.withOpacity(0.5)],
                ),
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                child: Text(
                  data['name'][0],
                  style: TextStyle(
                    fontSize: avatarSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: borderColor,
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
          data['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          '${data['points']} ball',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
