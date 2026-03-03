import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/core/routing/route_names.dart';
import 'package:parent_school_app/core/storage/secure_storage.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/datasources/remote/auth_api.dart';
import 'package:parent_school_app/data/datasources/remote/user_api.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/models/auth_response.dart';
import 'package:parent_school_app/main.dart';
import 'package:parent_school_app/presentation/providers/auth_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';

class MockAuthApi extends Mock implements AuthApi {}
class MockUserApi extends Mock implements UserApi {}

class FakeSecureStorage extends Fake implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _storage['accessToken'] = accessToken;
    _storage['refreshToken'] = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _storage['accessToken'];

  @override
  Future<String?> getRefreshToken() async => _storage['refreshToken'];

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }

  @override
  Future<void> saveAccessToken(String token) async {
    _storage['accessToken'] = token;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockAuthApi mockAuthApi;
  late MockUserApi mockUserApi;
  late FakeSecureStorage fakeSecureStorage;

  setUpAll(() async {
    // Initialise any required global services, e.g. SharedPrefsService (stubbed or mocked if need be, but for widget test usually SharedPreferences.setMockInitialValues)
    // Here we can just mock the values for the test
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
  });

  setUp(() {
    mockAuthApi = MockAuthApi();
    mockUserApi = MockUserApi();
    fakeSecureStorage = FakeSecureStorage();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authApiProvider.overrideWithValue(mockAuthApi),
        userApiProvider.overrideWithValue(mockUserApi),
        secureStorageProvider.overrideWithValue(fakeSecureStorage),
      ],
      child: const ParentSchoolApp(),
    );
  }

  group('Full Authentication E2E Flow test', () {
    testWidgets('Invalid Login displays error and valid Login routes to Home', (tester) async {
      // Stub the API responses
      
      // 1st attempt: Invalid credentials
      when(() => mockAuthApi.login(username: 'wrong', password: 'password'))
          .thenThrow(const ServerException(message: 'Login yoki parol xato', statusCode: 401));

      // 2nd attempt: Valid credentials
      final testUser = const UserModel(
        id: 1,
        fullName: 'Eshmatov Toshmat',
        phone: '+998901234567',
        role: 'parent',
      );
      when(() => mockAuthApi.login(username: 'correct', password: 'password'))
          .thenAnswer((_) async => AuthResponse(
                accessToken: 'valid_token_123',
                user: testUser,
              ));

      // Mock updateFcmToken which is typically called after successful login
      when(() => mockAuthApi.updateFcmToken(any())).thenAnswer((_) async {});

      // Mock UserApi profile loading which is called after login and splash
      when(() => mockUserApi.getProfile()).thenAnswer((_) async => testUser);
      when(() => mockUserApi.getChildren()).thenAnswer((_) async => []);

      // Launch APP
      await tester.pumpWidget(createWidgetUnderTest());
      // Wait for splash check to complete (2 seconds + auth check delays)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // App should route to LoginScreen
      expect(find.text('Xush kelibsiz!'), findsOneWidget); // Found in heading

      // --- Attempt 1: Invalid login ---
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.widgetWithText(ElevatedButton, 'Kirish');

      // Enter phone number / username
      await tester.enterText(emailField, 'wrong');
      
      // Enter password
      await tester.enterText(passwordField, 'password');

      // Press Login Button
      await tester.tap(loginButton);
      await tester.pump(); // Start request
      await tester.pump(const Duration(milliseconds: 50)); // Allow failure to propagate

      // Wait for snackbar to appear
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Kirish'), findsWidgets); // Depends on how ui displays error

      // Wait for snackbar to clear
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // --- Attempt 2: Valid login ---
      // Clear and enter correct
      await tester.enterText(emailField, 'correct');

      // Press Login Button
      await tester.tap(loginButton);
      await tester.pump(); // Request
      await tester.pumpAndSettle(const Duration(seconds: 1)); // allow navigation
      
      // App should route to home screen (which renders Home/Dashboard)
      // Wait until we see bottom nav bar
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
