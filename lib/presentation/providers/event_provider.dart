import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/event_api.dart';
import '../../data/models/event_model.dart';
import 'auth_provider.dart';

final eventApiProvider = Provider<EventApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return EventApi(dioClient);
});

class EventListState {
  final bool isLoading;
  final String? error;
  final List<SchoolEventModel> events;
  final String? selectedType;

  const EventListState({
    this.isLoading = false,
    this.error,
    this.events = const [],
    this.selectedType,
  });

  EventListState copyWith({
    bool? isLoading,
    String? error,
    List<SchoolEventModel>? events,
    String? selectedType,
  }) {
    return EventListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      events: events ?? this.events,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class EventListNotifier extends StateNotifier<EventListState> {
  final EventApi _api;

  EventListNotifier(this._api) : super(const EventListState());

  Future<void> loadEvents({String? type}) async {
    state = state.copyWith(isLoading: true, error: null, selectedType: type);
    try {
      final events = await _api.getEvents(type: type);
      state = EventListState(events: events, selectedType: type);
    } catch (e) {
      state = EventListState(error: e.toString(), selectedType: type);
    }
  }
}

final eventListProvider =
    StateNotifierProvider.autoDispose<EventListNotifier, EventListState>(
  (ref) {
    final api = ref.watch(eventApiProvider);
    return EventListNotifier(api);
  },
);
