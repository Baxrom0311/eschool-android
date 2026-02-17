import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/error/failures.dart';
import '../../core/storage/shared_prefs_service.dart';
import '../../data/datasources/remote/user_api.dart';
import '../../data/models/child_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart';

// ═══════════════════════════════════════════════════════════════
// DEPENDENCY PROVIDERS
// ═══════════════════════════════════════════════════════════════

final userApiProvider = Provider<UserApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UserApi(dioClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final userApi = ref.watch(userApiProvider);
  return UserRepository(userApi: userApi);
});

// ═══════════════════════════════════════════════════════════════
// USER STATE
// ═══════════════════════════════════════════════════════════════

/// Sentinel value for null-aware copyWith
const _undefined = Object();

/// Foydalanuvchi holati — profil + tanlangan farzand
class UserState {
  final UserModel? user;
  final ChildModel? selectedChild;
  final List<ChildModel> children;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.selectedChild,
    this.children = const [],
    this.isLoading = false,
    this.error,
  });

  const UserState.initial()
    : user = null,
      selectedChild = null,
      children = const [],
      isLoading = false,
      error = null;

  UserState copyWith({
    Object? user = _undefined,
    Object? selectedChild = _undefined,
    List<ChildModel>? children,
    bool? isLoading,
    Object? error = _undefined,
  }) {
    return UserState(
      user: user == _undefined ? this.user : user as UserModel?,
      selectedChild: selectedChild == _undefined
          ? this.selectedChild
          : selectedChild as ChildModel?,
      children: children ?? this.children,
      isLoading: isLoading ?? this.isLoading,
      error: error == _undefined ? this.error : error as String?,
    );
  }

  @override
  String toString() =>
      'UserState(user: ${user?.id}, selectedChild: ${selectedChild?.id}, '
      'children: ${children.length}, loading: $isLoading)';
}

// ═══════════════════════════════════════════════════════════════
// USER NOTIFIER
// ═══════════════════════════════════════════════════════════════

/// Foydalanuvchi state boshqaruvchisi
class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier({required UserRepository repository})
    : _repository = repository,
      super(const UserState.initial());

  Future<void> restoreCachedProfile() async {
    final cachedUser = _readCachedUser();
    if (cachedUser == null) return;

    final selectedChild = _resolveSelectedChild(cachedUser.children);
    state = state.copyWith(
      user: cachedUser,
      children: cachedUser.children,
      selectedChild: selectedChild,
      isLoading: false,
      error: null,
    );
  }

  /// Profil va farzandlarni yuklash (ilovaga kirganda chaqiriladi)
  Future<void> loadProfile() async {
    final cachedUser = _readCachedUser();
    if (cachedUser != null && state.user == null) {
      state = state.copyWith(
        user: cachedUser,
        children: cachedUser.children,
        selectedChild: _resolveSelectedChild(cachedUser.children),
      );
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getProfile();

    result.fold(
      (failure) {
        if (failure is AuthFailure) {
          unawaited(_clearCachedProfile());
          state = const UserState.initial().copyWith(error: failure.message);
          return;
        }

        if (state.user != null) {
          state = state.copyWith(isLoading: false, error: failure.message);
          return;
        }

        state = state.copyWith(
          user: null,
          children: const [],
          selectedChild: null,
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        final selectedChild = _resolveSelectedChild(user.children);

        state = state.copyWith(
          user: user,
          children: user.children,
          selectedChild: selectedChild,
          isLoading: false,
          error: null,
        );
        unawaited(_saveCachedProfile(user, selectedChild?.id));
      },
    );
  }

  /// Farzandni tanlash (dropdown yoki ro'yxatdan)
  void selectChild(ChildModel? child) {
    state = state.copyWith(selectedChild: child);
    unawaited(_saveSelectedChildId(child?.id));
  }

  /// Farzandni ID bo'yicha tanlash
  void selectChildById(int childId) {
    if (state.children.isEmpty) return;

    final child = state.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => state.children.first,
    );
    state = state.copyWith(selectedChild: child);
    unawaited(_saveSelectedChildId(child.id));
  }

  /// Profilni yangilash
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    bool? notificationsEnabled,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.updateProfile(
      fullName: fullName,
      email: email,
      phone: phone,
      notificationsEnabled: notificationsEnabled,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        final selectedChild = _resolveSelectedChild(user.children);
        state = state.copyWith(
          user: user,
          children: user.children,
          selectedChild: selectedChild,
          isLoading: false,
        );
        unawaited(_saveCachedProfile(user, selectedChild?.id));
      },
    );
  }

  /// Avatar yuklash va profilni yangilash
  Future<void> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.uploadAvatar(filePath);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (avatarUrl) {
        if (state.user != null) {
          final updatedUser = state.user!.copyWith(avatarUrl: avatarUrl);
          state = state.copyWith(user: updatedUser, isLoading: false);
          unawaited(_saveCachedProfile(updatedUser, state.selectedChild?.id));
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  /// Auth dan kelgan user ni set qilish
  void setUser(UserModel user) {
    final children = user.children;
    final selectedChild = children.isNotEmpty ? children.first : null;

    state = state.copyWith(
      user: user,
      children: children,
      selectedChild: selectedChild,
    );
    unawaited(_saveCachedProfile(user, selectedChild?.id));
  }

  /// Xatolikni tozalash
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Tizimdan chiqqanda state ni tozalash
  void clear() {
    state = const UserState.initial();
    unawaited(_clearCachedProfile());
  }

  ChildModel? _resolveSelectedChild(List<ChildModel> children) {
    if (children.isEmpty) return null;

    final preferredId =
        SharedPrefsService.getInt(StorageKeys.selectedChildId) ??
        state.selectedChild?.id;
    if (preferredId != null) {
      for (final child in children) {
        if (child.id == preferredId) {
          return child;
        }
      }
    }
    return children.first;
  }

  UserModel? _readCachedUser() {
    final raw = SharedPrefsService.getString(StorageKeys.userProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
      if (decoded is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      unawaited(SharedPrefsService.remove(StorageKeys.userProfile));
    }
    return null;
  }

  Future<void> _saveCachedProfile(UserModel user, int? selectedChildId) async {
    await SharedPrefsService.setString(
      StorageKeys.userProfile,
      jsonEncode(user.toJson()),
    );
    await _saveSelectedChildId(selectedChildId);
  }

  Future<void> _saveSelectedChildId(int? selectedChildId) async {
    if (selectedChildId == null) {
      await SharedPrefsService.remove(StorageKeys.selectedChildId);
      return;
    }
    await SharedPrefsService.setInt(
      StorageKeys.selectedChildId,
      selectedChildId,
    );
  }

  Future<void> _clearCachedProfile() async {
    await SharedPrefsService.remove(StorageKeys.userProfile);
    await SharedPrefsService.remove(StorageKeys.selectedChildId);
    await _clearOfflineCaches();
  }

  Future<void> _clearOfflineCaches() async {
    await SharedPrefsService.remove(StorageKeys.notificationsCache);
    await SharedPrefsService.remove(StorageKeys.schoolRatingCache);
    await SharedPrefsService.remove(StorageKeys.conversationsCache);

    await SharedPrefsService.removeByPrefix(StorageKeys.gradesCachePrefix);
    await SharedPrefsService.removeByPrefix(
      StorageKeys.gradeSummaryCachePrefix,
    );
    await SharedPrefsService.removeByPrefix(StorageKeys.scheduleCachePrefix);
    await SharedPrefsService.removeByPrefix(StorageKeys.attendanceCachePrefix);
    await SharedPrefsService.removeByPrefix(
      StorageKeys.attendanceSummaryCachePrefix,
    );
    await SharedPrefsService.removeByPrefix(StorageKeys.weeklyMenuCachePrefix);
    await SharedPrefsService.removeByPrefix(StorageKeys.dailyMenuCachePrefix);
    await SharedPrefsService.removeByPrefix(
      StorageKeys.paymentStateCachePrefix,
    );
    await SharedPrefsService.removeByPrefix(StorageKeys.assignmentsCachePrefix);
    await SharedPrefsService.removeByPrefix(
      StorageKeys.assignmentDetailCachePrefix,
    );
    await SharedPrefsService.removeByPrefix(StorageKeys.classRatingCachePrefix);
    await SharedPrefsService.removeByPrefix(StorageKeys.childRatingCachePrefix);
    await SharedPrefsService.removeByPrefix(
      StorageKeys.chatMessagesCachePrefix,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GLOBAL USER PROVIDER
// ═══════════════════════════════════════════════════════════════

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository: repository);
});

final selectedChildProvider = Provider<ChildModel?>((ref) {
  return ref.watch(userProvider).selectedChild;
});
