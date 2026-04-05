import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/conference_api.dart';
import '../../data/models/conference_model.dart';
import 'auth_provider.dart';

final conferenceApiProvider = Provider<ConferenceApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ConferenceApi(dioClient);
});

class ConferenceState {
  final List<ConferenceModel> bookings;
  final List<Map<String, dynamic>> availableSlots;
  final bool isLoading;
  final String? error;

  const ConferenceState({
    this.bookings = const [],
    this.availableSlots = const [],
    this.isLoading = false,
    this.error,
  });

  ConferenceState copyWith({
    List<ConferenceModel>? bookings,
    List<Map<String, dynamic>>? availableSlots,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ConferenceState(
      bookings: bookings ?? this.bookings,
      availableSlots: availableSlots ?? this.availableSlots,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ConferenceNotifier extends StateNotifier<ConferenceState> {
  final ConferenceApi _api;

  ConferenceNotifier(this._api) : super(const ConferenceState());

  Future<void> loadBookings(int childId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await _api.getMyBookings(childId);
      final availableSlots = await _api.getAvailableSlots(childId);
      state = state.copyWith(
        bookings: bookings,
        availableSlots: availableSlots,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> bookConference({
    required int childId,
    required int teacherId,
    required String date,
    required String timeSlot,
    String? medium,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.bookConference(
        childId: childId,
        teacherId: teacherId,
        date: date,
        timeSlot: timeSlot,
        medium: medium,
      );
      await loadBookings(childId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final conferenceProvider = StateNotifierProvider<ConferenceNotifier, ConferenceState>((ref) {
  return ConferenceNotifier(ref.watch(conferenceApiProvider));
});
