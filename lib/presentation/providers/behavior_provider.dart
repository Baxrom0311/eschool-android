import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/behavior_api.dart';
import '../../data/models/behavior_model.dart';
import 'auth_provider.dart';

final behaviorApiProvider = Provider<BehaviorApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BehaviorApi(dioClient);
});

class BehaviorState {
  final bool isLoading;
  final String? error;
  final BehaviorSummaryModel? summary;

  const BehaviorState({this.isLoading = false, this.error, this.summary});
}

class BehaviorNotifier extends StateNotifier<BehaviorState> {
  final BehaviorApi _api;

  BehaviorNotifier(this._api) : super(const BehaviorState());

  Future<void> loadBehavior(int studentId) async {
    state = const BehaviorState(isLoading: true);
    try {
      final summary = await _api.getStudentBehavior(studentId);
      state = BehaviorState(summary: summary);
    } catch (e) {
      state = BehaviorState(error: e.toString());
    }
  }
}

final behaviorProvider =
    StateNotifierProvider.autoDispose<BehaviorNotifier, BehaviorState>(
  (ref) {
    final api = ref.watch(behaviorApiProvider);
    return BehaviorNotifier(api);
  },
);
