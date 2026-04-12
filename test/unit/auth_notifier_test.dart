import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/data/repositories/notification_repository.dart';
import 'package:parent_school_app/presentation/providers/auth_provider.dart';
import 'package:parent_school_app/data/repositories/auth_repository.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/core/error/exceptions.dart';

// Mock Classes
class MockAuthRepository implements AuthRepository {
  bool _hasToken = false;
  bool _shouldFail = false;

  void setHasToken(bool value) => _hasToken = value;
  void setShouldFail(bool value) => _shouldFail = value;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    if (_shouldFail) {
      throw const ServerException(message: 'Login failed');
    }
    return const UserModel(
      id: 1,
      phone: '+998901234567',
      fullName: 'Test User',
    );
  }

  @override
  Future<bool> hasValidToken() async => _hasToken;

  @override
  Future<void> logout() async {
    _hasToken = false;
  }

  @override
  Future<void> forgotPassword({required String phone}) async {}

  @override
  Future<void> updateFCMToken(String token) async {}

  @override
  Future<String?> getAccessToken() async => _hasToken ? 'fake_token' : null;

  @override
  Future<UserModel> qrLogin({required String qrToken}) async =>
      const UserModel(id: 4, phone: '+998900000000', fullName: 'QR User');

  @override
  Future<String?> getFCMToken() async => null;

  @override
  Future<T> safeCall<T>(dynamic call, dynamic mapper) async =>
      throw UnimplementedError();
  @override
  Future<List<T>> safeCallList<T>(
    dynamic call,
    dynamic mapper, {
    String? listKey,
  }) async => throw UnimplementedError();
  @override
  Future<T> safeExecute<T>(dynamic call) async => throw UnimplementedError();
}

class MockNotificationRepository implements NotificationRepository {
  @override
  Future<void> saveFcmToken(String token) async {}

  @override
  // ignore: override_on_non_overriding_member
  Future<T> safeCall<T>(dynamic call, dynamic mapper) async =>
      throw UnimplementedError();
  @override
  // ignore: override_on_non_overriding_member
  Future<List<T>> safeCallList<T>(
    dynamic call,
    dynamic mapper, {
    String? listKey,
  }) async => throw UnimplementedError();

  @override
  // ignore: override_on_non_overriding_member
  Future<T> safeExecute<T>(dynamic call) async => throw UnimplementedError();
}

void main() {
  late AuthNotifier authNotifier;
  late MockAuthRepository mockRepository;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockNotificationRepository = MockNotificationRepository();
    authNotifier = AuthNotifier(
      repository: mockRepository,
      notificationRepository: mockNotificationRepository,
    );
  });

  group('AuthNotifier Tests', () {
    test('Initial state should be correct', () {
      expect(authNotifier.state, const AuthState.initial());
    });

    test('checkAuthStatus should return true when token exists', () async {
      mockRepository.setHasToken(true);

      final result = await authNotifier.checkAuthStatus();

      expect(result, true);
      expect(authNotifier.state.isAuthenticated, true);
    });

    test('login success should update state with user', () async {
      await authNotifier.login(username: '+998901234567', password: 'password');

      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.user?.phone, '+998901234567');
      expect(authNotifier.state.error, null);
    });

    test('login failure should update state with error', () async {
      mockRepository.setShouldFail(true);

      await authNotifier.login(username: 'test', password: 'password');

      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.error, 'Login failed');
    });

    test('logout should reset state', () async {
      // First login
      await authNotifier.login(username: 'test', password: 'password');
      expect(authNotifier.state.isAuthenticated, true);

      // Then logout
      await authNotifier.logout();
      expect(authNotifier.state, const AuthState.initial());
    });
  });
}
