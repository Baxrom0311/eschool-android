import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/firebase_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/error/exceptions.dart';
import '../../data/datasources/remote/auth_api.dart';
import '../../data/models/user_model.dart';
import '../../data/models/parent_login_response.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_provider.dart';

// ═══════════════════════════════════════════════════════════════
// DEPENDENCY PROVIDERS — bu providerlar dependency injection
// zanjirini tashkil qiladi (yuqoridan pastga)
// ═══════════════════════════════════════════════════════════════

/// Sentinel value for null-aware copyWith
const _undefined = Object();

/// SecureStorage instance — tokenlar saqlash uchun
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// DioClient instance — HTTP so'rovlar uchun
final Provider<DioClient> dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(
    secureStorage,
    onUnauthorized: () {
      // 401 Unauthorized sodir bo'lganda AuthNotifier holatini yangilash
      Future.microtask(() {
        try {
          ref.read(authProvider.notifier).clearLocalSession();
        } catch (_) {}
      });
    },
  );
});

/// AuthApi instance — auth endpointlari uchun
final authApiProvider = Provider<AuthApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthApi(dioClient);
});

/// AuthRepository instance — biznes logika
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(authApi: authApi, secureStorage: secureStorage);
});

/// NotificationRepository instance
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.watch(notificationApiProvider);
  return NotificationRepository(notificationApi: api);
});

// ═══════════════════════════════════════════════════════════════
// AUTH STATE — immutable state klassi
// ═══════════════════════════════════════════════════════════════

/// Auth holati — barcha auth bilan bog'liq ma'lumotlar
class AuthState extends Equatable {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final List<ChildMappingModel> children;
  final bool needsChildSelection;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.children = const [],
    this.needsChildSelection = false,
  });

  /// Boshlang'ich holat — hech narsa yuklanmagan
  const AuthState.initial()
    : user = null,
      token = null,
      isLoading = false,
      error = null,
      isAuthenticated = false,
      children = const [],
      needsChildSelection = false;

  /// Loading holati
  AuthState copyWithLoading() {
    return AuthState(
      user: user,
      isLoading: true,
      error: null,
      isAuthenticated: isAuthenticated,
    );
  }

  /// Muvaffaqiyatli auth holati
  AuthState copyWithSuccess(UserModel user, String? token) {
    return AuthState(
      user: user,
      token: token,
      isLoading: false,
      error: null,
      isAuthenticated: true,
    );
  }

  /// Xatolik holati
  AuthState copyWithError(String error) {
    return AuthState(
      user: user,
      isLoading: false,
      error: error,
      isAuthenticated: isAuthenticated,
    );
  }

  /// Logout holati — boshlang'ichga qaytish
  AuthState copyWithLogout() {
    return const AuthState.initial();
  }

  /// CopyWith method for generic updates
  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    Object? error = _undefined,
    bool? isAuthenticated,
    List<ChildMappingModel>? children,
    bool? needsChildSelection,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error == _undefined ? this.error : error as String?,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      children: children ?? this.children,
      needsChildSelection: needsChildSelection ?? this.needsChildSelection,
    );
  }

  @override
  List<Object?> get props => [
    user, 
    token, 
    isLoading, 
    error, 
    isAuthenticated,
    children,
    needsChildSelection,
  ];

  @override
  String toString() =>
      'AuthState(isAuth: $isAuthenticated, loading: $isLoading, user: ${user?.id})';
}

// ═══════════════════════════════════════════════════════════════
// AUTH NOTIFIER — state boshqarish logikasi
// ═══════════════════════════════════════════════════════════════

/// Auth state boshqaruvchisi
///
/// Login, register, logout, Google sign-in operatsiyalarini
/// boshqaradi va [AuthState] ni yangilaydi.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final NotificationRepository _notificationRepository;
  StreamSubscription<String>? _tokenRefreshSub;

  AuthNotifier({
    required AuthRepository repository,
    required NotificationRepository notificationRepository,
  }) : _repository = repository,
       _notificationRepository = notificationRepository,
       super(const AuthState.initial());

  String _readErrorMessage(Object error) {
    return switch (error) {
      ServerException() => error.message,
      NetworkException() => error.message,
      AuthException() => error.message,
      ValidationException() => error.message,
      _ => error.toString(),
    };
  }

  /// Ilova boshlanganda token mavjudligini tekshirish
  ///
  /// Splash screen dan chaqiriladi.
  /// Token mavjud → isAuthenticated = true
  Future<bool> checkAuthStatus() async {
    final hasToken = await _repository.hasValidToken();
    if (hasToken) {
      final token = await _repository
          .getAccessToken(); // Bu metodni qo'shishimiz kerak repository'ga
      state = AuthState(isAuthenticated: true, token: token);
      updateFCMToken();
    } else {
      state = state.copyWithLogout();
    }
    return hasToken;
  }

  /// Login — tizimga kirish
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.login(
        username: username,
        password: password,
      );
      
      if (response.autoTenant != null) {
        // Only 1 child, session already saved in repository
        final token = await _repository.getAccessToken();
        state = state.copyWith(
          user: response.user,
          token: token,
          isAuthenticated: true,
          isLoading: false,
        );
        updateFCMToken();
      } else {
        // Multiple children or needs selection
        state = state.copyWith(
          user: response.user,
          children: response.children,
          needsChildSelection: true,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _readErrorMessage(e));
    }
  }

  /// Select specific child/tenant
  Future<void> selectChild(ChildMappingModel mapping) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.issueTenantToken(
        studentId: mapping.studentId,
        tenantId: mapping.tenantId,
        host: mapping.host,
      );
      
      final token = await _repository.getAccessToken();
      state = state.copyWith(
        token: token,
        isAuthenticated: true,
        needsChildSelection: false,
        isLoading: false,
      );
      updateFCMToken();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _readErrorMessage(e));
    }
  }

  /// Logout — tizimdan chiqish
  Future<void> logout() async {
    state = state.copyWithLoading();
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore API errors on logout since we're clearing local session anyway
    }
    state = state.copyWithLogout();
  }

  /// Maxalliy sessiyani tozalash (masalan 401 xatolikda chaqiriladi)
  void clearLocalSession() {
    state = state.copyWithLogout();
  }

  /// Parolni tiklash
  Future<void> forgotPassword({required String phone}) async {
    state = state.copyWithLoading();

    try {
      await _repository.forgotPassword(phone: phone);
      state = AuthState(
        user: state.user,
        isLoading: false,
        error: null,
        isAuthenticated: state.isAuthenticated,
      );
    } catch (e) {
      state = state.copyWithError(_readErrorMessage(e));
    }
  }

  /// Xatolik xabarini tozalash
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
  }

  /// QR Kod orqali login
  Future<void> qrLogin({required String qrToken}) async {
    state = state.copyWithLoading();
    try {
      final user = await _repository.qrLogin(qrToken: qrToken);
      final token = await _repository.getAccessToken();
      state = state.copyWithSuccess(user, token);
      updateFCMToken();
    } catch (e) {
      state = state.copyWithError(_readErrorMessage(e));
    }
  }

  /// FCM Tokenni yangilash
  Future<void> updateFCMToken() async {
    try {
      final token = await FirebaseService.getFCMToken();
      if (token != null) {
        await _notificationRepository.saveFcmToken(token);
        if (kDebugMode) {
          log('FCM token synced to backend via NotificationRepository');
        }
      }

      // Listen to future token rotations
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = FirebaseService.onTokenRefresh.listen((
        newToken,
      ) async {
        await _notificationRepository.saveFcmToken(newToken);
        if (kDebugMode) {
          log('Rotated FCM token synced to backend');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        log('FCM token update error: $e');
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// GLOBAL AUTH PROVIDER — butun ilovada ishlatiladi
// ═══════════════════════════════════════════════════════════════

/// Auth provider — `ref.watch(authProvider)` orqali ishlatiladi
///
/// Misol (screen da):
/// ```dart
/// final authState = ref.watch(authProvider);
/// if (authState.isAuthenticated) { ... }
///
/// ref.read(authProvider.notifier).login(
///   username: 'user',
///   password: 'pass',
/// );
/// ```
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return AuthNotifier(
    repository: repository,
    notificationRepository: notificationRepository,
  );
});
