import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Profil va farzandlarni yuklash (ilovaga kirganda chaqiriladi)
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getProfile();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        final children = user.children;
        // Auto-select first child if none selected
        final selectedChild = children.isNotEmpty ? children.first : null;

        state = state.copyWith(
          user: user,
          children: children,
          selectedChild: selectedChild,
          isLoading: false,
        );
      },
    );
  }

  /// Farzandni tanlash (dropdown yoki ro'yxatdan)
  void selectChild(ChildModel? child) {
    state = state.copyWith(selectedChild: child);
  }

  /// Farzandni ID bo'yicha tanlash
  void selectChildById(int childId) {
    if (state.children.isEmpty) return;

    final child = state.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => state.children.first,
    );
    state = state.copyWith(selectedChild: child);
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
      (user) => state = state.copyWith(
        user: user,
        children: user.children,
        isLoading: false,
      ),
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
  }

  /// Xatolikni tozalash
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Tizimdan chiqqanda state ni tozalash
  void clear() {
    state = const UserState.initial();
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
