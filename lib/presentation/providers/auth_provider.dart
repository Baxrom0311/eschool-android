import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/services/firebase_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/datasources/remote/auth_api.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

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
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage);
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
  return AuthRepository(
    authApi: authApi,
    secureStorage: secureStorage,
  );
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web uchun clientId talab qilinadi.
    // TODO: 'YOUR_WEB_CLIENT_ID' ni Google Cloud Console dan olgan haqiqiy ID ga almashtiring.
    clientId: kIsWeb ? 'YOUR_WEB_CLIENT_ID' : null,
  );
});

// ═══════════════════════════════════════════════════════════════
// AUTH STATE — immutable state klassi
// ═══════════════════════════════════════════════════════════════

/// Auth holati — barcha auth bilan bog'liq ma'lumotlar
class AuthState extends Equatable {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  /// Boshlang'ich holat — hech narsa yuklanmagan
  const AuthState.initial()
      : user = null,
        isLoading = false,
        error = null,
        isAuthenticated = false;

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
  AuthState copyWithSuccess(UserModel user) {
    return AuthState(
      user: user,
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
    bool? isLoading,
    Object? error = _undefined,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error == _undefined ? this.error : error as String?,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, error, isAuthenticated];

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
  final GoogleSignIn _googleSignIn;

  AuthNotifier({
    required AuthRepository repository,
    required GoogleSignIn googleSignIn,
  })  : _repository = repository,
        _googleSignIn = googleSignIn,
        super(const AuthState.initial());

  /// Ilova boshlanganda token mavjudligini tekshirish
  ///
  /// Splash screen dan chaqiriladi.
  /// Token mavjud → isAuthenticated = true
  Future<bool> checkAuthStatus() async {
    final hasToken = await _repository.hasValidToken();
    if (hasToken) {
      state = const AuthState(
        isAuthenticated: true,
        // User ma'lumotlari keyingi API chaqiruvda yuklanadi
      );
      updateFCMToken();
    }
    return hasToken;
  }

  /// Login — tizimga kirish
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWithLoading();

    final result = await _repository.login(
      username: username,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWithError(failure.message),
      (user) {
        state = state.copyWithSuccess(user);
        updateFCMToken();
      },
    );
  }

  /// Register — yangi hisob yaratish
  Future<void> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    state = state.copyWithLoading();

    final result = await _repository.register(
      fullName: fullName,
      phone: phone,
      password: password,
      email: email,
    );

    result.fold(
      (failure) => state = state.copyWithError(failure.message),
      (user) => state = state.copyWithSuccess(user),
    );
  }

  /// Google Sign In
  Future<void> signInWithGoogle() async {
    state = state.copyWithLoading();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Foydalanuvchi oynani yopdi
        state = state.copyWithError('Google kirish bekor qilindi');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWithError('Google tokenni olishda xatolik');
        return;
      }

      final result = await _repository.googleSignIn(idToken: idToken);

      result.fold(
        (failure) => state = state.copyWithError(failure.message),
        (user) => state = state.copyWithSuccess(user),
      );
    } catch (e) {
      state = state.copyWithError('Google kirish xatoligi: ${e.toString()}');
    }
  }

  /// Logout — tizimdan chiqish
  Future<void> logout() async {
    state = state.copyWithLoading();

    // Google dan ham chiqish (agar Google orqali kirgan bo'lsa)
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google signout xatoligi logout ni to'xtatmaydi
    }

    await _repository.logout();
    state = state.copyWithLogout();
  }

  /// Parolni tiklash
  Future<void> forgotPassword({required String phone}) async {
    state = state.copyWithLoading();

    final result = await _repository.forgotPassword(phone: phone);

    result.fold(
      (failure) => state = state.copyWithError(failure.message),
      (_) => state = AuthState(
        user: state.user,
        isLoading: false,
        error: null,
        isAuthenticated: state.isAuthenticated,
      ),
    );
  }

  /// Xatolik xabarini tozalash
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// FCM Tokenni yangilash
  Future<void> updateFCMToken() async {
    try {
      final token = await FirebaseService.getFCMToken();
      if (token != null) {
        await _repository.updateFCMToken(token);
        if (kDebugMode) {
          log('FCM token synced to backend');
        }
      }
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
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthNotifier(
    repository: repository,
    googleSignIn: googleSignIn,
  );
});
