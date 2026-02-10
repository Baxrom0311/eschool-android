import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../widgets/common/custom_button.dart';

/// Assignments Screen - Homework Assignments List
///
/// Sprint 2 - Academics Module
/// Dev1 Responsibility
///
/// Design: List of assignments with urgency badges and submit buttons
class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  int _selectedTab = 0; // 0 = New, 1 = Weekly

  // Mock data for new assignments
  final List<Map<String, dynamic>> newAssignments = [
    {
      'subject': 'Matematika',
      'title': '15-20 mashqlar',
      'description': 'Kvadrat tenglamalar mavzusidan barcha mashqlarni yechish',
      'deadline': 'Ertaga 09:00',
      'isUrgent': true,
      'status': 'urgent',
      'color': const Color(0xFF4CAF50),
    },
    {
      'subject': 'Ingliz tili',
      'title': 'Essay yozish',
      'description': '"My Future Career" mavzusida 200 so\'zli insho',
      'deadline': '2 kun ichida',
      'isUrgent': false,
      'status': 'in_progress',
      'color': const Color(0xFF2196F3),
    },
    {
      'subject': 'Fizika',
      'title': 'Laboratoriya ishi',
      'description': 'Nyuton qonunlari bo\'yicha tajriba hisoboti',
      'deadline': '3 kun ichida',
      'isUrgent': false,
      'status': 'new',
      'color': const Color(0xFFFF9800),
    },
  ];

  // Mock data for weekly assignments
  final List<Map<String, dynamic>> weeklyAssignments = [
    {
      'subject': 'Kimyo',
      'title': 'Davriy jadval',
      'description': 'Elementlarning xossalarini o\'rganish',
      'deadline': '5 kun ichida',
      'isUrgent': false,
      'status': 'new',
      'color': const Color(0xFF9C27B0),
    },
    {
      'subject': 'Tarix',
      'title': 'Prezentatsiya',
      'description': 'O\'zbekiston tarixi mavzusida slayd tayyorlash',
      'deadline': '1 hafta ichida',
      'isUrgent': false,
      'status': 'in_progress',
      'color': const Color(0xFF795548),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final assignments = _selectedTab == 0 ? newAssignments : weeklyAssignments;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════════════════
          // Blue Header with User Info
          // ═══════════════════════════════════════════════════════
          SliverAppBar(
            expandedHeight: 180,
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFFE8F0FF),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 32,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Azizbek Rahimov',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '8-A sinf',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Baholar',
                        isActive: false,
                        onTap: () {
                          // TODO: Navigate to grades screen
                        },
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Reyting',
                        isActive: false,
                        onTap: () {
                          // TODO: Navigate to rating screen
                        },
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Vazifalar',
                        isActive: true,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════
          // Sub-Tabs (New / Weekly)
          // ═══════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: 'Yangi vazifalar',
                        isActive: _selectedTab == 0,
                        onTap: () {
                          setState(() => _selectedTab = 0);
                        },
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Haftalik',
                        isActive: _selectedTab == 1,
                        onTap: () {
                          setState(() => _selectedTab = 1);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════
          // Assignment Cards List
          // ═══════════════════════════════════════════════════════
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final assignment = assignments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        context.push(RouteNames.assignmentDetail,
                            extra: assignment);
                      },
                      child: _AssignmentCard(
                        subject: assignment['subject'],
                        title: assignment['title'],
                        description: assignment['description'],
                        deadline: assignment['deadline'],
                        isUrgent: assignment['isUrgent'],
                        status: assignment['status'],
                        color: assignment['color'],
                      ),
                    ),
                  );
                },
                childCount: assignments.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Tab Button Widget
// ═══════════════════════════════════════════════════════

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primaryBlue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Segment Button Widget
// ═══════════════════════════════════════════════════════

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Assignment Card Widget
// ═══════════════════════════════════════════════════════

class _AssignmentCard extends StatelessWidget {
  final String subject;
  final String title;
  final String description;
  final String deadline;
  final bool isUrgent;
  final String status;
  final Color color;

  const _AssignmentCard({
    required this.subject,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isUrgent,
    required this.status,
    required this.color,
  });

  String get statusLabel {
    switch (status) {
      case 'urgent':
        return 'Shoshilinch';
      case 'in_progress':
        return 'Jarayonda';
      default:
        return 'Yangi';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'urgent':
        return const Color(0xFFF44336); // Red
      case 'in_progress':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF4CAF50); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isUrgent ? const Color(0xFFF44336) : color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Subject Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                // Deadline
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadline,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Yuborish',
                onPressed: () {
                  // TODO: Submit assignment
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vazifa yuborish funksiyasi tez orada...'),
                    ),
                  );
                },
                height: 44,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
