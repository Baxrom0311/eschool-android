import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/datasources/remote/rating_api.dart';
import '../../data/models/rating_model.dart';
import '../../core/error/exceptions.dart';
import '../../core/storage/shared_prefs_service.dart';
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
      childRating: childRating == _undefined
          ? this.childRating
          : childRating as RatingModel?,
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
    final cacheKey = _classCacheKey(classId);
    final cached = _readRatingListCache(cacheKey);
    if (cached != null) {
      state = state.copyWith(classRating: cached, isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final rating = await _api.getClassRating(classId);
      state = state.copyWith(classRating: rating, isLoading: false);
      unawaited(_saveRatingListCache(cacheKey, rating));
    } on NetworkException catch (e) {
      if (cached != null) {
        state = state.copyWith(
          classRating: cached,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.message);
      }
    } on ServerException catch (e) {
      if (cached != null) {
        state = state.copyWith(
          classRating: cached,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.message);
      }
    } catch (e) {
      if (cached != null) {
        state = state.copyWith(
          classRating: cached,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Reytingni yuklashda xatolik: ${e.toString()}',
        );
      }
    }
  }

  /// Maktab reytingini yuklash
  Future<void> loadSchoolRating() async {
    final cached = _readRatingListCache(StorageKeys.schoolRatingCache);
    if (cached != null) {
      state = state.copyWith(
        schoolRating: cached,
        isLoading: true,
        error: null,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final rating = await _api.getSchoolRating();
      state = state.copyWith(schoolRating: rating, isLoading: false);
      unawaited(_saveRatingListCache(StorageKeys.schoolRatingCache, rating));
    } on NetworkException catch (e) {
      if (cached != null) {
        state = state.copyWith(
          schoolRating: cached,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.message);
      }
    } on ServerException catch (e) {
      if (cached != null) {
        state = state.copyWith(
          schoolRating: cached,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: e.message);
      }
    } catch (e) {
      if (cached != null) {
        state = state.copyWith(
          schoolRating: cached,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Xatolik: ${e.toString()}',
        );
      }
    }
  }

  /// Farzand reytingini yuklash
  Future<void> loadChildRating(int childId) async {
    final cacheKey = _childCacheKey(childId);
    final cached = _readSingleRatingCache(cacheKey);
    if (cached != null) {
      state = state.copyWith(childRating: cached);
    }

    try {
      final rating = await _api.getChildRating(childId);
      state = state.copyWith(childRating: rating);
      unawaited(_saveSingleRatingCache(cacheKey, rating));
    } catch (_) {
      if (cached != null) {
        state = state.copyWith(childRating: cached);
      }
    }
  }

  List<RatingModel>? _readRatingListCache(String key) {
    final raw = SharedPrefsService.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => RatingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      unawaited(SharedPrefsService.remove(key));
      return null;
    }
  }

  Future<void> _saveRatingListCache(
    String key,
    List<RatingModel> rating,
  ) async {
    await SharedPrefsService.setString(
      key,
      jsonEncode(rating.map((e) => e.toJson()).toList()),
    );
  }

  RatingModel? _readSingleRatingCache(String key) {
    final raw = SharedPrefsService.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return RatingModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      unawaited(SharedPrefsService.remove(key));
      return null;
    }
  }

  Future<void> _saveSingleRatingCache(String key, RatingModel rating) async {
    await SharedPrefsService.setString(key, jsonEncode(rating.toJson()));
  }

  String _classCacheKey(int classId) =>
      '${StorageKeys.classRatingCachePrefix}$classId';

  String _childCacheKey(int childId) =>
      '${StorageKeys.childRatingCachePrefix}$childId';
}

final ratingProvider = StateNotifierProvider<RatingNotifier, RatingState>((
  ref,
) {
  final api = ref.watch(ratingApiProvider);
  return RatingNotifier(api: api);
});
