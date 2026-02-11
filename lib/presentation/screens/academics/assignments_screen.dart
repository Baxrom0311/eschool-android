import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/academic_provider.dart';
import '../../providers/user_provider.dart';
import '../../../data/models/assignment_model.dart';
import '../../widgets/common/custom_button.dart';

/// Assignments Screen - Homework Assignments List
///
/// Design: List of assignments with urgency badges and submit buttons
class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  int _selectedTab = 0; // 0 = New, 1 = Weekly

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignments();
    });
  }

  void _loadAssignments() {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild != null) {
      final status = _selectedTab == 0 ? 'pending' : null;
      ref.read(assignmentsProvider.notifier).loadAssignments(
            selectedChild.id,
            status: status,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsState = ref.watch(assignmentsProvider);
    final assignments = assignmentsState.assignments;
    final isLoading = assignmentsState.isLoading;

    // Listen to tab changes or child changes if needed?
    // Changing child is global, so initState/build usually handles it if we watch userProvider?
    // But we need to reload. `selectedChild` comes from `userProvider`.
    // It's better to listen to selectedChild changes to reload.
    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadAssignments();
      }
    });

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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final user = ref.watch(userProvider).user;
                            final selectedChild =
                                ref.watch(selectedChildProvider);

                            return Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  backgroundImage: selectedChild?.avatarUrl != null
                                      ? NetworkImage(selectedChild!.avatarUrl!)
                                      : null,
                                  child: selectedChild?.avatarUrl == null
                                      ? const CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Color(0xFFE8F0FF),
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 32,
                                            color: AppColors.primaryBlue,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),

                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedChild != null
                                            ? selectedChild.fullName
                                            : (user?.fullName ?? 'Foydalanuvchi'),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedChild?.className ?? 'Sinf yo\'q',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
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
                          context.push(RouteNames.grades);
                        },
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Reyting',
                        isActive: false,
                        onTap: () {
                          context.push(RouteNames.rating);
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
                          if (_selectedTab != 0) {
                            setState(() => _selectedTab = 0);
                            _loadAssignments();
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Barchasi', // Haftalik -> Barchasi implies no status filter?
                        isActive: _selectedTab == 1,
                        onTap: () {
                          if (_selectedTab != 1) {
                            setState(() => _selectedTab = 1);
                            _loadAssignments();
                          }
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
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (assignments.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Vazifalar topilmadi')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final assignment = assignments[index];
                    // Logic to determine color based on subject or random
                    // For now, let's use a default or consistent hashing
                    final color = Colors.primaries[
                        assignment.subjectName.length % Colors.primaries.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          context.push(RouteNames.assignmentDetail,
                              extra: assignment);
                        },
                        child: _AssignmentCard(
                          subject: assignment.subjectName,
                          title: assignment.title,
                          description: assignment.description ?? '',
                          deadline:
                              assignment.dueDate.split('T')[0], // Simple format
                          isUrgent: assignment.isOverdue, // or logic?
                          status: assignment.status, // Pass enum directly
                          color: color,
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
                    color: AppColors.shadow.withValues(alpha: 0.1),
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
  final AssignmentStatus status;
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
      case AssignmentStatus.pending:
        return 'Jarayonda';
      case AssignmentStatus.submitted:
        return 'Topshirilgan';
      case AssignmentStatus.graded:
        return 'Baholangan';
      case AssignmentStatus.overdue:
        return 'Muddati o\'tgan';
    }
  }

  Color get statusColor {
    switch (status) {
      case AssignmentStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case AssignmentStatus.submitted:
        return const Color(0xFF2196F3); // Blue
      case AssignmentStatus.graded:
        return const Color(0xFF4CAF50); // Green
      case AssignmentStatus.overdue:
        return const Color(0xFFF44336); // Red
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
            color: AppColors.shadow.withValues(alpha: 0.08),
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
                    color: color.withValues(alpha: 0.1),
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
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadline,
                      style: const TextStyle(
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Submit Button
            if (status == AssignmentStatus.pending || status == AssignmentStatus.overdue)
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Yuborish',
                  onPressed: () {
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
