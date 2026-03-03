import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/auth_provider.dart';
import 'package:parent_school_app/data/repositories/auth_repository.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Mock Classes
class MockAuthRepository implements AuthRepository {
  bool _hasToken = false;
  bool _shouldFail = false;

  void setHasToken(bool value) => _hasToken = value;
  void setShouldFail(bool value) => _shouldFail = value;

  @override
  Future<Either<Failure, UserModel>> login({required String username, required String password}) async {
    if (_shouldFail) {
      return const Left(ServerFailure('Login failed'));
    }
    return const Right(UserModel(id: 1, phone: '+998901234567', fullName: 'Test User', role: 'parent'));
  }

  @override
  Future<bool> hasValidToken() async => _hasToken;

  @override
  Future<Either<Failure, void>> logout() async {
    _hasToken = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String phone}) async => const Right(null);

  @override
  Future<Either<Failure, void>> resetPassword({required String phone, required String code, required String password, required String passwordConfirmation}) async => const Right(null);

  @override
  Future<Either<Failure, void>> updateFCMToken(String token) async => const Right(null);

  @override
  Future<Either<Failure, UserModel>> qrLogin({required String qrToken}) async => 
    const Right(UserModel(id: 4, phone: '+998900000000', fullName: 'QR User', role: 'parent'));
}



void main() {
  late AuthNotifier authNotifier;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    authNotifier = AuthNotifier(
      repository: mockRepository,
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
