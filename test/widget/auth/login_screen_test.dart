import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/presentation/screens/auth/login_screen.dart';
import 'package:parent_school_app/presentation/providers/auth_provider.dart';

import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';

// Mock Notifier
class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier() : super(const AuthState.initial());

  @override
  Future<bool> checkAuthStatus() async => false;

  @override
  Future<void> login({required String username, required String password}) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network
    state = state.copyWith(
      isLoading: false, 
      isAuthenticated: true,
      user: const UserModel(id: 1, fullName: 'Test', phone: '+998901234567', role: 'parent'),
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword({required String phone, required String code, required String password, required String passwordConfirmation}) async {}
  
  @override
  Future<void> forgotPassword({required String phone}) async {}

  @override
  Future<void> updateFCMToken() async {}

  @override
  Future<void> qrLogin({required String qrToken}) async {}

  @override
  void clearError() {}

  @override
  void clearLocalSession() {}
}

class MockUserNotifier extends StateNotifier<UserState> implements UserNotifier {
  MockUserNotifier() : super(const UserState.initial());

  @override
  void setUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  @override
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: false);
  }

  // Define other necessary methods as empty/no-ops
  @override
  void selectChild(child) {}
  @override
  void selectChildById(int childId) {}
  @override
  void clear() {}
  @override
  void clearError() {}
  @override
  Future<void> updateProfile({String? fullName, String? email, String? phone, bool? notificationsEnabled}) async {}
  @override
  Future<void> restoreCachedProfile() async {}
  @override
  Future<String?> changePassword({required String currentPassword, required String newPassword, required String confirmPassword}) async => null;
  @override
  Future<void> uploadAvatar(String filePath) async {}
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('Renders properly and identifies validation errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify the screen renders
      expect(find.text('Xush kelibsiz!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      
      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);

      // Attempt login with empty fields to trigger validation
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Ensure validation error is produced explicitly
      expect(find.text('Email kiriting'), findsOneWidget);
      expect(find.text('Parol kiriting'), findsOneWidget);
    });

    testWidgets('Permits login submission when validation succeeds', (tester) async {
      final mockAuth = MockAuthNotifier();
      final mockUser = MockUserNotifier();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => mockAuth),
            userProvider.overrideWith((ref) => mockUser),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123456');
      
      // Tap login
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump(); // Start animation
      
      // Loading indicator should appear momentarily inside ElevatedButton
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle(); // Settle network simulator
      
      // Wait, there's a problem here because `_completeAuthFlow` calls `userProvider.notifier` but we mocked authProvider. 
      // UserProvider might error out if it tries to fetch, but the button press logic will execute successfully.
    });
  });
}
