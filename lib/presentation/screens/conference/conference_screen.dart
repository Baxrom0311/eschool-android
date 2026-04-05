import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/conference_provider.dart';
import '../../providers/user_provider.dart';

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
      final child = ref.read(selectedChildProvider);
      if (child != null) {
        ref.read(conferenceProvider.notifier).loadBookings(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conferenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ota-onalar majlisi'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = state.bookings[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.people_alt, color: AppColors.primaryBlue),
                        title: Text('${booking.teacherName} bilan uchrashuv'),
                        subtitle: Text('${booking.date} | ${booking.time}\nHolat: ${booking.status}'),
                        isThreeLine: true,
                        trailing: booking.zoomLink != null
                            ? IconButton(
                                icon: const Icon(Icons.video_call, color: Colors.green),
                                onPressed: () {
                                  // Open zoomLink logic
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          // Show bottom sheet to book a teacher from state.availableSlots
        },
        icon: const Icon(Icons.add),
        label: const Text('Majlis belgilash'),
      ),
    );
  }
}
