import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../data/models/assignment_model.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/common/custom_button.dart';

/// Assignment Detail Screen - real API detail + submit flow
class AssignmentDetailScreen extends ConsumerStatefulWidget {
  final AssignmentModel? assignment;

  const AssignmentDetailScreen({super.key, this.assignment});

  @override
  ConsumerState<AssignmentDetailScreen> createState() =>
      _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState
    extends ConsumerState<AssignmentDetailScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isSubmitting = false;

  int get _assignmentId => widget.assignment?.id ?? 0;

  @override
  void initState() {
    super.initState();
    if (_assignmentId > 0) {
      Future.microtask(
        () => ref
            .read(assignmentsProvider.notifier)
            .loadAssignmentDetails(_assignmentId),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null || file.path!.isEmpty) return;

    setState(() {
      _selectedFilePath = file.path;
      _selectedFileName = file.name;
    });
  }

  Future<void> _submitAssignment() async {
    final l10n = context.l10n;

    if (_assignmentId <= 0) return;
    if (_selectedFilePath == null || _selectedFilePath!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.assignmentSelectFileFirst)));
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref
        .read(assignmentsProvider.notifier)
        .submitAssignment(_assignmentId, filePath: _selectedFilePath);
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.assignmentSubmittedSuccess)));
      setState(() {
        _selectedFilePath = null;
        _selectedFileName = null;
      });
      await ref
          .read(assignmentsProvider.notifier)
          .loadAssignmentDetails(_assignmentId);
    } else {
      final error =
          ref.read(assignmentsProvider).error?.toString() ??
          l10n.assignmentSubmitFailed;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final loaded = assignmentsAsync.valueOrNull?.selectedAssignment;
    final assignment = loaded != null && loaded.id == _assignmentId
        ? loaded
        : widget.assignment;

    if (assignment == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.assignmentDetailsTitle),
          backgroundColor:
              theme.appBarTheme.backgroundColor ?? colorScheme.surface,
          foregroundColor:
              theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        ),
        body: Center(child: Text(l10n.assignmentNotFound)),
      );
    }

    final isPending = assignment.isPending || assignment.isOverdue;
    final submittedFiles = assignment.submittedFiles;
    final teacherFiles = assignment.attachments;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── Premium Header ───
          SliverAppBar(
            expandedHeight: 120,
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
              ),
              title: Text(
                l10n.assignmentDetailsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    assignment.subjectName.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 0.5),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (assignment.isOverdue ? AppColors.danger : AppColors.warning).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.assignmentStatusText(assignment.status).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: assignment.isOverdue ? AppColors.danger : AppColors.warning,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              assignment.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.danger),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.assignmentDueDateText(assignment.dueDate),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (assignment.description != null &&
                                assignment.description!.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(height: 1),
                              ),
                              Text(
                                assignment.description!,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        title: l10n.assignmentTeacherFilesTitle,
                        icon: Icons.folder_open_rounded,
                        isEmpty: teacherFiles.isEmpty,
                        emptyText: l10n.assignmentNoTeacherFiles,
                        children: teacherFiles.map(
                          (file) => _FileListItem(name: file.name, icon: Icons.insert_drive_file_rounded),
                        ).toList(),
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        title: l10n.assignmentSubmittedFilesTitle,
                        icon: Icons.cloud_upload_outlined,
                        isEmpty: submittedFiles.isEmpty,
                        emptyText: l10n.assignmentNotSubmittedYet,
                        children: submittedFiles.map(
                          (file) => _FileListItem(
                            name: file.name,
                            subtitle: file.formattedSize,
                            icon: Icons.file_copy_rounded,
                          ),
                        ).toList(),
                      ),
                      if (_selectedFileName != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file_rounded, color: AppColors.primaryBlue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("FILING ATTACHED", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                                    Text(
                                      _selectedFileName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedFilePath = null;
                                    _selectedFileName = null;
                                  });
                                },
                                icon: const Icon(Icons.close_rounded, color: AppColors.slate400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isPending
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: _selectedFileName == null
                          ? l10n.chooseFileAction.toUpperCase()
                          : l10n.chooseAnotherFileAction.toUpperCase(),
                      onPressed: _isSubmitting ? null : _pickFile,
                      isOutlined: true,
                      height: 62,
                      borderRadius: 32,
                      icon: Icons.upload_file_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: l10n.assignmentSubmitAction.toUpperCase(),
                      onPressed: (_isSubmitting || assignmentsAsync.isLoading)
                          ? null
                          : _submitAssignment,
                      isLoading: _isSubmitting || assignmentsAsync.isLoading,
                      height: 62,
                      borderRadius: 32,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String emptyText;
  final bool isEmpty;
  final List<Widget> children;
  final IconData icon;

  const _DetailCard({
    required this.title,
    required this.isEmpty,
    required this.emptyText,
    required this.children,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isEmpty)
            Text(emptyText, style: TextStyle(color: AppColors.slate400, fontSize: 13, fontWeight: FontWeight.w600))
          else
            ...children,
        ],
      ),
    );
  }
}

class _FileListItem extends StatelessWidget {
  final String name;
  final String? subtitle;
  final IconData icon;

  const _FileListItem({required this.name, this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.slate50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.slate500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
