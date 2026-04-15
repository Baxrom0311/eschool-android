import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/absence_model.dart';
import '../../providers/absence_provider.dart';
import '../../providers/user_provider.dart';

class AbsenceExcuseScreen extends ConsumerStatefulWidget {
  const AbsenceExcuseScreen({super.key});

  @override
  ConsumerState<AbsenceExcuseScreen> createState() =>
      _AbsenceExcuseScreenState();
}

class _AbsenceExcuseScreenState extends ConsumerState<AbsenceExcuseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExcuses();
    });
  }

  void _loadExcuses() {
    final child = ref.read(selectedChildProvider);
    if (child != null) {
      ref.read(absenceProvider.notifier).loadExcuses(child.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(absenceProvider);
    final child = ref.watch(selectedChildProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        ref.read(absenceProvider.notifier).loadExcuses(next.id);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.absenceTitle),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        elevation: 0,
      ),
      body: child == null
          ? _buildPlaceholder(message: l10n.absenceNeedChild)
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(absenceProvider.notifier).loadExcuses(child.id);
              },
              child: _buildBody(state),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: child == null ? null : () => _showSubmitDialog(context),
        label: Text(l10n.submitRequestAction),
        icon: const Icon(Icons.add),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildBody(AbsenceState state) {
    if (state.isLoading && state.excuses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.excuses.isEmpty) {
      return _buildPlaceholder(
        message: state.error!,
        actionLabel: AppLocalizations.current.retry,
        onAction: _loadExcuses,
      );
    }

    if (state.excuses.isEmpty) {
      return _buildPlaceholder(
        message: AppLocalizations.current.noRequestsYet,
        caption: AppLocalizations.current.requestStatusCaption,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.excuses.length,
      itemBuilder: (context, index) {
        final excuse = state.excuses[index];
        return _buildExcuseCard(excuse);
      },
    );
  }

  Widget _buildPlaceholder({
    required String message,
    String? caption,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 64),
        Icon(Icons.fact_check_outlined, size: 72, color: AppColors.slate400),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 8),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExcuseCard(AbsenceExcuseModel excuse) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final period = excuse.dateFrom == excuse.dateTo
        ? excuse.dateFrom
        : '${excuse.dateFrom} - ${excuse.dateTo}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    excuse.reason.isEmpty
                        ? AppLocalizations.current.noReasonProvided
                        : excuse.reason,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildStatusBadge(excuse.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  period,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (excuse.attachmentUrl != null &&
                excuse.attachmentUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.current.fileAttached,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.slate400;
    String label = status;
    if (status == 'approved') {
      color = AppColors.success;
      label = AppLocalizations.current.absenceStatusLabel(status);
    } else if (status == 'rejected') {
      color = AppColors.danger;
      label = AppLocalizations.current.absenceStatusLabel(status);
    } else if (status == 'pending') {
      color = AppColors.warning;
      label = AppLocalizations.current.absenceStatusLabel(status);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSubmitDialog(BuildContext context) {
    final l10n = context.l10n;
    final student = ref.read(selectedChildProvider);
    if (student == null) return;

    final reasonController = TextEditingController();
    DateTime dateFrom = DateTime.now();
    DateTime dateTo = DateTime.now();
    String? attachmentPath;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).bottomSheetTheme.backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(width: 48, child: Divider(thickness: 4)),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.absenceRequestTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: l10n.startDateLabel,
                      value: DateFormat('yyyy-MM-dd').format(dateFrom),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dateFrom,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked == null) return;
                        setModalState(() {
                          dateFrom = picked;
                          if (dateTo.isBefore(picked)) {
                            dateTo = picked;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateButton(
                      label: l10n.endDateLabel,
                      value: DateFormat('yyyy-MM-dd').format(dateTo),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dateTo,
                          firstDate: dateFrom,
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => dateTo = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.reasonLabel,
                  hintText: l10n.reasonHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles();
                  if (result == null || result.files.single.path == null) {
                    return;
                  }
                  setModalState(() {
                    attachmentPath = result.files.single.path;
                  });
                },
                icon: const Icon(Icons.attach_file),
                label: Text(
                  attachmentPath == null ? l10n.attachFile : l10n.fileReady,
                ),
              ),
              if (attachmentPath != null) ...[
                const SizedBox(height: 8),
                Text(
                  attachmentPath!.split('/').last,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);
                          final reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            setModalState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.reasonRequired)),
                            );
                            return;
                          }

                          final success = await ref
                              .read(absenceProvider.notifier)
                              .submitExcuse(
                                childId: student.id,
                                dateFrom: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(dateFrom),
                                dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
                                reason: reason,
                                attachmentPath: attachmentPath,
                              );

                          if (context.mounted) {
                            setModalState(() => isSubmitting = false);
                          }
                          if (!mounted || !context.mounted) return;

                          if (success) {
                            Navigator.of(bottomSheetContext).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(l10n.requestSubmitted)),
                            );
                          } else {
                            final error =
                                ref.read(absenceProvider).error ??
                                l10n.requestSubmitFailed;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Text(l10n.sendAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
