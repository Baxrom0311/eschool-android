import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
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

class _AssignmentDetailScreenState extends ConsumerState<AssignmentDetailScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isSubmitting = false;

  int get _assignmentId => widget.assignment?.id ?? 0;

  @override
  void initState() {
    super.initState();
    if (_assignmentId > 0) {
      Future.microtask(
        () => ref.read(assignmentsProvider.notifier).loadAssignmentDetails(
              _assignmentId,
            ),
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
    if (_assignmentId <= 0) return;
    if (_selectedFilePath == null || _selectedFilePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avval fayl tanlang')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref.read(assignmentsProvider.notifier).submitAssignment(
          _assignmentId,
          filePath: _selectedFilePath,
        );
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vazifa muvaffaqiyatli yuborildi')),
      );
      setState(() {
        _selectedFilePath = null;
        _selectedFileName = null;
      });
      await ref
          .read(assignmentsProvider.notifier)
          .loadAssignmentDetails(_assignmentId);
    } else {
      final error = ref.read(assignmentsProvider).error?.toString() ?? 'Yuborishda xatolik';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final loaded = assignmentsAsync.valueOrNull?.selectedAssignment;
    final assignment = loaded != null && loaded.id == _assignmentId
        ? loaded
        : widget.assignment;

    if (assignment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vazifa tafsilotlari'),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Vazifa topilmadi')),
      );
    }

    final isPending = assignment.isPending || assignment.isOverdue;
    final submittedFiles = assignment.submittedFiles;
    final teacherFiles = assignment.attachments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vazifa tafsilotlari'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.subjectName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Muddat: ${assignment.dueDate}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${assignment.statusText}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (assignment.description != null &&
                            assignment.description!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            assignment.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'O\'qituvchi fayllari',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (teacherFiles.isEmpty)
                          const Text(
                            'Biriktirilgan fayl yo\'q',
                            style: TextStyle(color: AppColors.textSecondary),
                          )
                        else
                          ...teacherFiles.map(
                            (file) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.insert_drive_file_rounded),
                              title: Text(file.name),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yuborilgan fayllar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (submittedFiles.isEmpty)
                          const Text(
                            'Hali yuborilmagan',
                            style: TextStyle(color: AppColors.textSecondary),
                          )
                        else
                          ...submittedFiles.map(
                            (file) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.file_copy_rounded),
                              title: Text(file.name),
                              subtitle: Text(file.formattedSize),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_selectedFileName != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file_rounded),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilePath = null;
                                _selectedFileName = null;
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isPending)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _pickFile,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(
                        _selectedFileName == null
                            ? 'Fayl tanlash'
                            : 'Boshqa fayl tanlash',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Vazifani yuborish',
                      onPressed: (_isSubmitting || assignmentsAsync.isLoading)
                          ? null
                          : _submitAssignment,
                      isLoading: _isSubmitting || assignmentsAsync.isLoading,
                      height: 52,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
