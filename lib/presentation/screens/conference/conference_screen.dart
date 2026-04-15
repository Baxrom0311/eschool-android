import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/conference_model.dart';
import '../../providers/conference_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/app_state_view.dart';

class ConferenceScreen extends ConsumerStatefulWidget {
  const ConferenceScreen({super.key});

  @override
  ConsumerState<ConferenceScreen> createState() => _ConferenceScreenState();
}

class _ConferenceScreenState extends ConsumerState<ConferenceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConferenceData();
    });
  }

  void _loadConferenceData() {
    final child = ref.read(selectedChildProvider);
    if (child != null) {
      ref.read(conferenceProvider.notifier).loadBookings(child.id);
    }
  }

  Future<void> _showBookingSheet() async {
    final l10n = context.l10n;
    final child = ref.read(selectedChildProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (child == null) {
      AppSnackBar.showOnMessenger(
        messenger,
        l10n.selectChildFirst,
        type: AppSnackBarType.error,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).bottomSheetTheme.backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final slots = ref.read(conferenceProvider).availableSlots;
        return _ConferenceBookingSheet(
          slots: slots,
          onBook: (slot, note) async {
            final success = await ref
                .read(conferenceProvider.notifier)
                .bookConference(
                  childId: child.id,
                  conferenceSlotId: slot.slotId,
                  note: note,
                );
            if (!mounted) return false;

            AppSnackBar.showOnMessenger(
              messenger,
              success
                  ? l10n.conferenceBookedSuccess
                  : (ref.read(conferenceProvider).error ??
                        l10n.conferenceBookFailed),
              type: success ? AppSnackBarType.success : AppSnackBarType.error,
            );
            return success;
          },
        );
      },
    );
  }

  Future<void> _openMeetingLink(String url) async {
    final l10n = context.l10n;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      AppSnackBar.show(
        context,
        l10n.invalidMeetingLink,
        type: AppSnackBarType.error,
      );
      return;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        l10n.openMeetingLinkFailed,
        type: AppSnackBarType.error,
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'booked':
      case 'approved':
        return AppColors.success;
      case 'cancelled':
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(conferenceProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadConferenceData();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.conferenceTitle),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        elevation: 1,
      ),
      body: AppStateView(
        isLoading: state.isLoading && state.bookings.isEmpty,
        errorMessage: state.bookings.isEmpty ? state.error : null,
        isEmpty: state.bookings.isEmpty && !state.isLoading,
        emptyMessage: l10n.conferenceEmpty,
        onRetry: _loadConferenceData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.bookings.length,
          itemBuilder: (context, index) {
            final booking = state.bookings[index];
            final statusColor = _statusColor(booking.status);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outline),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.people_alt,
                  color: AppColors.primaryBlue,
                ),
                title: Text(l10n.meetingWithTeacher(booking.teacherName)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${booking.date} | ${booking.time}'),
                    if (booking.location != null &&
                        booking.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          booking.location!,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Chip(
                        label: Text(l10n.conferenceStatusLabel(booking.status)),
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        side: BorderSide(
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                        labelStyle: TextStyle(color: statusColor),
                      ),
                    ),
                  ],
                ),
                isThreeLine: booking.location != null,
                trailing:
                    booking.zoomLink != null && booking.zoomLink!.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.video_call,
                          color: _statusColor(booking.status),
                        ),
                        onPressed: () => _openMeetingLink(booking.zoomLink!),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: state.isLoading ? null : _showBookingSheet,
        icon: const Icon(Icons.add),
        label: Text(
          state.availableSlots.isEmpty
              ? l10n.scheduleConferenceAction
              : l10n.availableSlotsCount(state.availableSlots.length),
        ),
      ),
    );
  }
}

class _ConferenceBookingSheet extends StatefulWidget {
  const _ConferenceBookingSheet({required this.slots, required this.onBook});

  final List<ConferenceModel> slots;
  final Future<bool> Function(ConferenceModel slot, String note) onBook;

  @override
  State<_ConferenceBookingSheet> createState() =>
      _ConferenceBookingSheetState();
}

class _ConferenceBookingSheetState extends State<_ConferenceBookingSheet> {
  final _noteController = TextEditingController();
  int? _selectedSlotId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleBook() async {
    if (_isSubmitting) return;
    final slot = widget.slots.cast<ConferenceModel?>().firstWhere(
      (item) => item?.slotId == _selectedSlotId,
      orElse: () => null,
    );

    if (slot == null) return;

    setState(() => _isSubmitting = true);
    final success = await widget.onBook(slot, _noteController.text.trim());
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SizedBox(width: 48, child: Divider(thickness: 4)),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.availableSlotsTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.slots.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: Text(l10n.noAvailableSlots),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.slots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final slot = widget.slots[index];
                  final isSelected = _selectedSlotId == slot.slotId;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedSlotId = slot.slotId);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: isSelected ? 1.5 : 1,
                        ),
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.06)
                            : theme.cardColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.teacherName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('${slot.date} | ${slot.time}'),
                                if (slot.location != null &&
                                    slot.location!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      slot.location!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.noteOptional,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  widget.slots.isEmpty ||
                      _selectedSlotId == null ||
                      _isSubmitting
                  ? null
                  : _handleBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(l10n.bookConferenceAction),
            ),
          ),
        ],
      ),
    );
  }
}
