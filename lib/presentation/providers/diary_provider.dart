import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/shared_prefs_service.dart';
import '../../data/datasources/remote/diary_api.dart';
import '../../data/models/diary_model.dart';
import 'auth_provider.dart';

// ═══════════════════════════════════════════════════════════════
// DEPENDENCY
// ═══════════════════════════════════════════════════════════════

final diaryApiProvider = Provider<DiaryApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiaryApi(dioClient);
});

// ═══════════════════════════════════════════════════════════════
// DIARY WEEKLY PROVIDER (AsyncNotifier)
// ═══════════════════════════════════════════════════════════════

class DiaryData {
  final DiaryWeekResponseModel? weekResponse;
  final DateTime selectedWeekStart;

  DiaryData({
    this.weekResponse,
    DateTime? selectedWeekStart,
  }) : selectedWeekStart = selectedWeekStart ?? _currentMonday();

  List<DiaryDayModel> get days => weekResponse?.days ?? [];

  static DateTime _currentMonday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  DiaryData copyWith({
    DiaryWeekResponseModel? weekResponse,
    DateTime? selectedWeekStart,
  }) {
    return DiaryData(
      weekResponse: weekResponse ?? this.weekResponse,
      selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
    );
  }
}

class DiaryNotifier extends AutoDisposeAsyncNotifier<DiaryData> {
  @override
  FutureOr<DiaryData> build() {
    return DiaryData();
  }

  Future<void> loadWeekly(int childId, {DateTime? weekStart}) async {
    final monday = weekStart ?? DiaryData._currentMonday();
    final weekStartStr =
        '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

    // Try cache first
    final cached = _readCache(childId, weekStartStr);
    if (cached != null) {
      state = AsyncValue.data(DiaryData(
        weekResponse: cached,
        selectedWeekStart: monday,
      ));
    } else {
      state = const AsyncValue.loading();
    }

    final api = ref.read(diaryApiProvider);

    try {
      final response = await api.getWeekly(childId, weekStart: weekStartStr);
      final data = DiaryData(
        weekResponse: response,
        selectedWeekStart: monday,
      );
      state = AsyncValue.data(data);
      unawaited(_saveCache(childId, weekStartStr, response));
    } catch (e, st) {
      if (cached != null) {
        state = AsyncValue.data(DiaryData(
          weekResponse: cached,
          selectedWeekStart: monday,
        ));
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  void navigateWeek(int childId, int direction) {
    final current = state.valueOrNull?.selectedWeekStart ?? DateTime.now();
    final newWeekStart = current.add(Duration(days: 7 * direction));
    loadWeekly(childId, weekStart: newWeekStart);
  }

  // ─── Cache ───

  DiaryWeekResponseModel? _readCache(int childId, String weekStart) {
    final key = _cacheKey(childId, weekStart);
    final raw = SharedPrefsService.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return DiaryWeekResponseModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      unawaited(SharedPrefsService.remove(key));
      return null;
    }
  }

  Future<void> _saveCache(
    int childId,
    String weekStart,
    DiaryWeekResponseModel response,
  ) async {
    await SharedPrefsService.setString(
      _cacheKey(childId, weekStart),
      jsonEncode(response.toJson()),
    );
  }

  String _cacheKey(int childId, String weekStart) =>
      '${StorageKeys.diaryWeeklyCachePrefix}${childId}_$weekStart';
}

final diaryProvider =
    AsyncNotifierProvider.autoDispose<DiaryNotifier, DiaryData>(
  DiaryNotifier.new,
);
