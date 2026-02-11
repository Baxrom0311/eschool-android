import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/rating_api.dart';
import '../../data/models/rating_model.dart';
import '../../core/error/exceptions.dart';
import 'auth_provider.dart';

// ─── Dependency Providers ───

final ratingApiProvider = Provider<RatingApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RatingApi(dioClient);
});

// ─── Rating State ───

// Sentinel value for null-aware copyWith
const _undefined = Object();

class RatingState {
  final List<RatingModel> classRating;
  final List<RatingModel> schoolRating;
  final RatingModel? childRating;
  final bool isLoading;
  final String? error;

  const RatingState({
    this.classRating = const [],
    this.schoolRating = const [],
    this.childRating,
    this.isLoading = false,
    this.error,
  });

  const RatingState.initial()
      : classRating = const [],
        schoolRating = const [],
        childRating = null,
        isLoading = false,
        error = null;

  RatingState copyWith({
    List<RatingModel>? classRating,
    List<RatingModel>? schoolRating,
    Object? childRating = _undefined,
    bool? isLoading,
    String? error,
  }) {
    return RatingState(
      classRating: classRating ?? this.classRating,
      schoolRating: schoolRating ?? this.schoolRating,
      childRating: childRating == _undefined ? this.childRating : childRating as RatingModel?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RatingNotifier extends StateNotifier<RatingState> {
  final RatingApi _api;

  RatingNotifier({required RatingApi api})
      : _api = api,
        super(const RatingState.initial());

  /// Sinf reytingini yuklash
  Future<void> loadClassRating(int classId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rating = await _api.getClassRating(classId);
      state = state.copyWith(classRating: rating, isLoading: false);
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Reytingni yuklashda xatolik: ${e.toString()}',
      );
    }
  }

  /// Maktab reytingini yuklash
  Future<void> loadSchoolRating() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rating = await _api.getSchoolRating();
      state = state.copyWith(schoolRating: rating, isLoading: false);
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Xatolik: ${e.toString()}',
      );
    }
  }

  /// Farzand reytingini yuklash
  Future<void> loadChildRating(int childId) async {
    try {
      final rating = await _api.getChildRating(childId);
      state = state.copyWith(childRating: rating);
    } catch (_) {
      // Silent — asosiy reyting jadvaldan ko'rsa bo'ladi
    }
  }
}

final ratingProvider =
    StateNotifierProvider<RatingNotifier, RatingState>((ref) {
  final api = ref.watch(ratingApiProvider);
  return RatingNotifier(api: api);
});
