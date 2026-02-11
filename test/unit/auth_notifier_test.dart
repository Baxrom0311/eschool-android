import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/auth_provider.dart';
import 'package:parent_school_app/data/repositories/auth_repository.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    // username is treated as phone in this app context often, or just map it to phone/fullName
    return Right(UserModel(id: 1, phone: username, fullName: 'Test User', role: 'parent', email: 'test@example.com'));
  }

  @override
  Future<bool> hasValidToken() async => _hasToken;

  @override
  Future<Either<Failure, void>> logout() async {
    _hasToken = false;
    return const Right(null);
  }

  // Unused methods for this test
  @override
  Future<Either<Failure, void>> forgotPassword({required String phone}) async => const Right(null);
  
  @override
  Future<Either<Failure, UserModel>> register({required String fullName, required String phone, required String password, String? email}) async => Right(UserModel(id: 2, phone: phone, fullName: fullName, role: 'parent', email: email));

  @override
  Future<Either<Failure, UserModel>> googleSignIn({required String idToken}) async => const Right(UserModel(id: 3, phone: '+998901234567', fullName: 'Google User', role: 'parent'));

  @override
  Future<Either<Failure, void>> updateFCMToken(String token) async => const Right(null);
}

// Fake GoogleSignIn (minimal implementation)
class FakeGoogleSignIn implements GoogleSignIn {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AuthNotifier authNotifier;
  late MockAuthRepository mockRepository;
  late FakeGoogleSignIn fakeGoogleSignIn;

  setUp(() {
    mockRepository = MockAuthRepository();
    fakeGoogleSignIn = FakeGoogleSignIn();
    authNotifier = AuthNotifier(
      repository: mockRepository,
      googleSignIn: fakeGoogleSignIn,
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
