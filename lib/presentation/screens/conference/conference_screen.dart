import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
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
    final child = ref.read(selectedChildProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (child == null) {
      AppSnackBar.showOnMessenger(
        messenger,
        'Avval farzandni tanlang',
        type: AppSnackBarType.error,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                  ? 'Uchrashuv muvaffaqiyatli belgilandi'
                  : (ref.read(conferenceProvider).error ??
                        'Majlisni belgilab bo\'lmadi'),
              type: success ? AppSnackBarType.success : AppSnackBarType.error,
            );
            return success;
          },
        );
      },
    );
  }

  Future<void> _openMeetingLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      AppSnackBar.show(
        context,
        'Majlis havolasi noto\'g\'ri',
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
        'Majlis havolasini ochib bo\'lmadi',
        type: AppSnackBarType.error,
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'booked':
      case 'approved':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conferenceProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadConferenceData();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ota-onalar majlisi'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: AppStateView(
        isLoading: state.isLoading && state.bookings.isEmpty,
        errorMessage: state.bookings.isEmpty ? state.error : null,
        isEmpty: state.bookings.isEmpty && !state.isLoading,
        emptyMessage: 'Hali majlis bron qilinmagan',
        onRetry: _loadConferenceData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.bookings.length,
          itemBuilder: (context, index) {
            final booking = state.bookings[index];
            final statusColor = _statusColor(booking.status);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(
                  Icons.people_alt,
                  color: AppColors.primaryBlue,
                ),
                title: Text('${booking.teacherName} bilan uchrashuv'),
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
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Chip(
                        label: Text(booking.status),
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
                        icon: const Icon(Icons.video_call, color: Colors.green),
                        onPressed: () => _openMeetingLink(booking.zoomLink!),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        onPressed: state.isLoading ? null : _showBookingSheet,
        icon: const Icon(Icons.add),
        label: Text(
          state.availableSlots.isEmpty
              ? 'Majlis belgilash'
              : 'Bo\'sh slotlar (${state.availableSlots.length})',
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SizedBox(
              width: 48,
              child: Divider(thickness: 4, color: AppColors.border),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bo\'sh uchrashuv slotlari',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (widget.slots.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 16),
              child: Text('Hozircha bo\'sh slotlar topilmadi'),
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
                              ? AppColors.primaryBlue
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        color: isSelected
                            ? AppColors.primaryBlue.withValues(alpha: 0.06)
                            : Colors.white,
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
                                    ? AppColors.primaryBlue
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBlue,
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
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
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
              labelText: 'Izoh (ixtiyoriy)',
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
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Majlisni belgilash'),
            ),
          ),
        ],
      ),
    );
  }
}
