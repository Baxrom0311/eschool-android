import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/routing/route_names.dart';
import '../../../data/models/assignment_model.dart';
import '../../providers/academic_provider.dart';
import '../../providers/user_provider.dart';
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
      ref
          .read(assignmentsProvider.notifier)
          .loadAssignments(selectedChild.id, status: status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentsAsync = ref.watch(assignmentsProvider);

    final assignments = assignmentsAsync.valueOrNull?.assignments ?? [];
    final isLoading = assignmentsAsync.isLoading;
    final hasError = assignmentsAsync.hasError;

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadAssignments();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── Premium Header ───
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final user = ref.watch(userProvider).user;
                        final selectedChild = ref.watch(selectedChildProvider);

                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 34,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                backgroundImage: selectedChild?.avatarUrl != null
                                    ? NetworkImage(selectedChild!.avatarUrl!)
                                    : null,
                                child: selectedChild?.avatarUrl == null
                                    ? Text(
                                        (selectedChild?.fullName ?? user?.fullName ?? "U")[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedChild != null ? selectedChild.fullName : (user?.fullName ?? l10n.userFallbackName),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    selectedChild?.className ?? l10n.noClassLabel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: l10n.gradesTab,
                        isActive: false,
                        onTap: () => context.push(RouteNames.grades),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: l10n.ratingTab,
                        isActive: false,
                        onTap: () => context.push(RouteNames.rating),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: l10n.assignmentsTab,
                        isActive: true,
                        onTap: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Sub-Tabs (New / All) (Premium Segment) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: l10n.newAssignmentsTab,
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
                        label: l10n.allAssignmentsTab,
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

          // ─── Assignments List ───
          if (isLoading && assignments.isEmpty)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (hasError && assignments.isEmpty)
            SliverFillRemaining(child: Center(child: Text('${assignmentsAsync.error}')))
          else if (assignments.isEmpty)
            SliverFillRemaining(child: Center(child: Text(l10n.assignmentsEmpty)))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final assignment = assignments[index];
                  final List<Color> palette = [
                    AppColors.primaryBlue,
                    const Color(0xFF8B5CF6), // Purple
                    const Color(0xFFF59E0B), // Amber
                    const Color(0xFF10B981), // Emerald
                    const Color(0xFFEC4899), // Pink
                  ];
                  final color = palette[index % palette.length];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _AssignmentCard(
                      assignment: assignment,
                      color: color,
                      onTap: () => context.push(RouteNames.assignmentDetail, extra: assignment),
                    ),
                  );
                }, childCount: assignments.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isActive ? AppColors.slate900 : AppColors.slate500,
          ),
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final Color color;
  final VoidCallback onTap;

  const _AssignmentCard({required this.assignment, required this.color, required this.onTap});

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.pending: return const Color(0xFFF59E0B);
      case AssignmentStatus.submitted: return const Color(0xFF3B82F6);
      case AssignmentStatus.graded: return const Color(0xFF10B981);
      case AssignmentStatus.overdue: return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(assignment.status);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          assignment.subjectName.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(color: theme.colorScheme.outline, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule_rounded, size: 14, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(
                        assignment.dueDate.split('T')[0],
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    assignment.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.description ?? '',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.assignmentStatusLabel(assignment.status).toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (assignment.status == AssignmentStatus.pending || assignment.status == AssignmentStatus.overdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            l10n.assignmentSubmitAction,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
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
    );
  }
}
