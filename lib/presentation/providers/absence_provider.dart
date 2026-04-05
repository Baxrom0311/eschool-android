import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_error_handler.dart';
import '../../data/datasources/remote/absence_excuse_api.dart';
import '../../data/models/absence_model.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _undefined = Object();

final absenceApiProvider = Provider<AbsenceExcuseApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AbsenceExcuseApi(dioClient);
});

class AbsenceState {
  final List<AbsenceExcuseModel> excuses;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final int? childId;

  const AbsenceState({
    this.excuses = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.childId,
  });

  AbsenceState copyWith({
    List<AbsenceExcuseModel>? excuses,
    bool? isLoading,
    bool? isSubmitting,
    Object? error = _undefined,
    Object? childId = _undefined,
  }) {
    return AbsenceState(
      excuses: excuses ?? this.excuses,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error == _undefined ? this.error : error as String?,
      childId: childId == _undefined ? this.childId : childId as int?,
    );
  }
}

class AbsenceNotifier extends StateNotifier<AbsenceState> {
  AbsenceNotifier(this._api, this._ref) : super(const AbsenceState());

  final AbsenceExcuseApi _api;
  final Ref _ref;

  Future<void> loadExcuses(int childId) async {
    state = state.copyWith(isLoading: true, error: null, childId: childId);
    try {
      final excuses = await _api.getExcuses(childId);
      state = state.copyWith(
        excuses: excuses,
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

  Future<bool> submitExcuse({
    required int childId,
    required String dateFrom,
    String? dateTo,
    required String reason,
    String? attachmentPath,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, childId: childId);
    try {
      await _api.submitExcuse(
        childId: childId,
        dateFrom: dateFrom,
        dateTo: dateTo ?? dateFrom,
        reason: reason,
        attachmentPath: attachmentPath,
      );
      _ref.invalidate(myAbsenceExcusesProvider);
      await loadExcuses(childId);
      state = state.copyWith(isSubmitting: false, error: null);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        error: ApiErrorHandler.readableMessage(error),
      );
      return false;
    }
  }

  Future<bool> submit({
    required int studentId,
    required String date,
    String? dateTo,
    required String reason,
    String? attachmentPath,
  }) {
    return submitExcuse(
      childId: studentId,
      dateFrom: date,
      dateTo: dateTo,
      reason: reason,
      attachmentPath: attachmentPath,
    );
  }
}

final absenceProvider = StateNotifierProvider<AbsenceNotifier, AbsenceState>((
  ref,
) {
  return AbsenceNotifier(ref.watch(absenceApiProvider), ref);
});

final myAbsenceExcusesProvider = FutureProvider<List<AbsenceExcuseModel>>((
  ref,
) async {
  final child = ref.watch(selectedChildProvider);
  if (child == null) return const [];
  return ref.watch(absenceApiProvider).getExcuses(child.id);
});

final absenceExcuseControllerProvider = absenceProvider;
