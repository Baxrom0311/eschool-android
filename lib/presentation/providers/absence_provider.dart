import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/absence_excuse_api.dart';
import '../../data/models/absence_model.dart';
import 'auth_provider.dart';

final absenceApiProvider = Provider<AbsenceExcuseApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AbsenceExcuseApi(dioClient);
});

class AbsenceState {
  final List<AbsenceExcuseModel> excuses;
  final bool isLoading;
  final String? error;

  const AbsenceState({
    this.excuses = const [],
    this.isLoading = false,
    this.error,
  });

  AbsenceState copyWith({
    List<AbsenceExcuseModel>? excuses,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AbsenceState(
      excuses: excuses ?? this.excuses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AbsenceNotifier extends StateNotifier<AbsenceState> {
  final AbsenceExcuseApi _api;

  AbsenceNotifier(this._api) : super(const AbsenceState());

  Future<void> loadExcuses(int childId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final excuses = await _api.getExcuses(childId);
      state = state.copyWith(excuses: excuses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submitExcuse({
    required int childId,
    required String dateFrom,
    required String dateTo,
    required String reason,
    String? attachmentPath,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.submitExcuse(
        childId: childId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        reason: reason,
        attachmentPath: attachmentPath,
      );
      await loadExcuses(childId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final absenceProvider = StateNotifierProvider<AbsenceNotifier, AbsenceState>((ref) {
  return AbsenceNotifier(ref.watch(absenceApiProvider));
});
