import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/transport_api.dart';
import '../../data/models/transport_model.dart';
import 'auth_provider.dart';

// ─── Dependency ───

final transportApiProvider = Provider<TransportApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TransportApi(dioClient);
});

// ─── State ───

class TransportState {
  final bool isLoading;
  final String? error;
  final BusRouteInfoModel? data;

  const TransportState({this.isLoading = false, this.error, this.data});

  TransportState copyWith({
    bool? isLoading,
    String? error,
    BusRouteInfoModel? data,
  }) {
    return TransportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

// ─── Notifier ───

class TransportNotifier extends StateNotifier<TransportState> {
  final TransportApi _api;
  Timer? _refreshTimer;

  TransportNotifier(this._api) : super(const TransportState());

  Future<void> loadLocation(int studentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getStudentLocation(studentId);
      state = TransportState(data: data);
    } catch (e) {
      state = TransportState(error: e.toString());
    }
  }

  void startAutoRefresh(int studentId,
      {Duration interval = const Duration(seconds: 15)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) async {
      try {
        final data = await _api.getStudentLocation(studentId);
        state = TransportState(data: data);
      } catch (_) {}
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// ─── Provider ───

final transportProvider =
    StateNotifierProvider.autoDispose<TransportNotifier, TransportState>(
  (ref) {
    final api = ref.watch(transportApiProvider);
    return TransportNotifier(api);
  },
);
