import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/shared_prefs_service.dart';
import '../../data/datasources/remote/menu_api.dart';
import '../../data/models/menu_model.dart';
import '../../data/repositories/menu_repository.dart';
import 'auth_provider.dart';

// ─── Dependency Providers ───

final menuApiProvider = Provider<MenuApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MenuApi(dioClient);
});

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final api = ref.watch(menuApiProvider);
  return MenuRepository(menuApi: api);
});

// ─── Menu State ───

class MenuState {
  final List<MenuModel> dailyMenu;
  final List<MenuModel> weeklyMenu;
  final bool isLoading;
  final String? error;
  final String? selectedDate;

  const MenuState({
    this.dailyMenu = const [],
    this.weeklyMenu = const [],
    this.isLoading = false,
    this.error,
    this.selectedDate,
  });

  const MenuState.initial()
    : dailyMenu = const [],
      weeklyMenu = const [],
      isLoading = false,
      error = null,
      selectedDate = null;

  MenuState copyWith({
    List<MenuModel>? dailyMenu,
    List<MenuModel>? weeklyMenu,
    bool? isLoading,
    String? error,
    String? selectedDate,
  }) {
    return MenuState(
      dailyMenu: dailyMenu ?? this.dailyMenu,
      weeklyMenu: weeklyMenu ?? this.weeklyMenu,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  final MenuRepository _repository;

  MenuNotifier({required MenuRepository repository})
    : _repository = repository,
      super(const MenuState.initial());

  Future<void> loadDailyMenu({String? date, int? studentId}) async {
    final cacheKey = _dailyCacheKey(date, studentId);
    final cached = _readMenuCache(cacheKey);
    if (cached != null) {
      state = state.copyWith(
        dailyMenu: cached,
        isLoading: true,
        error: null,
        selectedDate: date,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null, selectedDate: date);
    }

    final result = await _repository.getDailyMenu(
      date: date,
      studentId: studentId,
    );

    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        error: cached == null ? f.message : null,
      ),
      (menu) {
        state = state.copyWith(dailyMenu: menu, isLoading: false);
        unawaited(_saveMenuCache(cacheKey, menu));
      },
    );
  }

  Future<void> loadWeeklyMenu({String? weekStart, int? studentId}) async {
    final cacheKey = _weeklyCacheKey(weekStart, studentId);
    final cached = _readMenuCache(cacheKey);
    if (cached != null) {
      state = state.copyWith(weeklyMenu: cached, isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _repository.getWeeklyMenu(
      weekStart: weekStart,
      studentId: studentId,
    );

    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        error: cached == null ? f.message : null,
      ),
      (menu) {
        state = state.copyWith(weeklyMenu: menu, isLoading: false);
        unawaited(_saveMenuCache(cacheKey, menu));
      },
    );
  }

  List<MenuModel>? _readMenuCache(String key) {
    final raw = SharedPrefsService.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => MenuModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      unawaited(SharedPrefsService.remove(key));
      return null;
    }
  }

  Future<void> _saveMenuCache(String key, List<MenuModel> menu) async {
    await SharedPrefsService.setString(
      key,
      jsonEncode(menu.map((e) => e.toJson()).toList()),
    );
  }

  String _dailyCacheKey(String? date, int? studentId) =>
      '${StorageKeys.dailyMenuCachePrefix}${studentId ?? 0}_${date ?? 'today'}';

  String _weeklyCacheKey(String? weekStart, int? studentId) =>
      '${StorageKeys.weeklyMenuCachePrefix}${studentId ?? 0}_${weekStart ?? 'current'}';
}

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return MenuNotifier(repository: repository);
});
