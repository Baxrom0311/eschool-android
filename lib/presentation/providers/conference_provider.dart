import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_error_handler.dart';
import '../../data/datasources/remote/conference_api.dart';
import '../../data/models/conference_model.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _undefined = Object();

final conferenceApiProvider = Provider<ConferenceApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ConferenceApi(dioClient);
});

class ConferenceState {
  final List<ConferenceModel> availableSlots;
  final List<ConferenceModel> bookings;
  final bool isLoading;
  final bool isBooking;
  final String? error;
  final int? childId;

  const ConferenceState({
    this.availableSlots = const [],
    this.bookings = const [],
    this.isLoading = false,
    this.isBooking = false,
    this.error,
    this.childId,
  });

  ConferenceState copyWith({
    List<ConferenceModel>? availableSlots,
    List<ConferenceModel>? bookings,
    bool? isLoading,
    bool? isBooking,
    Object? error = _undefined,
    Object? childId = _undefined,
  }) {
    return ConferenceState(
      availableSlots: availableSlots ?? this.availableSlots,
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      isBooking: isBooking ?? this.isBooking,
      error: error == _undefined ? this.error : error as String?,
      childId: childId == _undefined ? this.childId : childId as int?,
    );
  }
}

class ConferenceNotifier extends StateNotifier<ConferenceState> {
  ConferenceNotifier(this._api, this._ref) : super(const ConferenceState());

  final ConferenceApi _api;
  final Ref _ref;

  Future<void> loadBookings(int childId) async {
    state = state.copyWith(isLoading: true, error: null, childId: childId);
    try {
      final availableSlots = await _api.getAvailableSlots(childId);
      final bookings = await _api.getMyBookings(childId);

      state = state.copyWith(
        availableSlots: availableSlots,
        bookings: bookings,
        isLoading: false,
        error: null,
        childId: childId,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: ApiErrorHandler.readableMessage(error),
        childId: childId,
      );
    }
  }

  Future<bool> bookConference({
    required int childId,
    required int conferenceSlotId,
    String? note,
  }) async {
    state = state.copyWith(isBooking: true, error: null, childId: childId);
    try {
      await _api.bookConference(
        childId: childId,
        conferenceSlotId: conferenceSlotId,
        note: note,
      );
      _ref.invalidate(availableConferencesProvider);
      _ref.invalidate(myBookingsProvider);
      await loadBookings(childId);
      state = state.copyWith(isBooking: false, error: null);
      return true;
    } catch (error) {
      state = state.copyWith(
        isBooking: false,
        error: ApiErrorHandler.readableMessage(error),
      );
      return false;
    }
  }

  Future<bool> book(int slotId, int studentId, String? note) {
    return bookConference(
      childId: studentId,
      conferenceSlotId: slotId,
      note: note,
    );
  }
}

final conferenceProvider =
    StateNotifierProvider<ConferenceNotifier, ConferenceState>((ref) {
      return ConferenceNotifier(ref.watch(conferenceApiProvider), ref);
    });

final availableConferencesProvider = FutureProvider<List<ConferenceModel>>((
  ref,
) async {
  final child = ref.watch(selectedChildProvider);
  if (child == null) return const [];
  return ref.watch(conferenceApiProvider).getAvailableSlots(child.id);
});

final myBookingsProvider = FutureProvider<List<ConferenceModel>>((ref) async {
  final child = ref.watch(selectedChildProvider);
  if (child == null) return const [];
  return ref.watch(conferenceApiProvider).getMyBookings(child.id);
});

final conferenceBookingControllerProvider = conferenceProvider;
