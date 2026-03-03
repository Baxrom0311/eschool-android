import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/profile/change_password_screen.dart';

class MockUserNotifier extends StateNotifier<UserState> with Mock implements UserNotifier {
  MockUserNotifier() : super(const UserState());
}

void main() {
  late MockUserNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockUserNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        userProvider.overrideWith((ref) => mockNotifier),
      ],
      child: const MaterialApp(
        home: ChangePasswordScreen(),
      ),
    );
  }

  group('ChangePasswordScreen Widget Tests', () {
    testWidgets('renders all input fields properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Parolni o\'zgartirish'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Joriy parol'), findsOneWidget);
      expect(find.text('Yangi parol'), findsOneWidget);
      expect(find.text('Parolni tasdiqlang'), findsOneWidget);
      expect(find.text('Saqlash'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final submitBtn = find.text('Saqlash');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Kiritish shart'), findsOneWidget);
      expect(find.text('Eng kamida 8 ta belgi'), findsOneWidget);
      verifyNever(() => mockNotifier.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
            confirmPassword: any(named: 'confirmPassword'),
          ));
    });

    testWidgets('shows validation error when passwords do not match', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final inputs = find.byType(TextFormField);
      await tester.enterText(inputs.at(0), 'old_pass');
      await tester.enterText(inputs.at(1), 'new_pass8');
      await tester.enterText(inputs.at(2), 'wrong_pass8');

      final submitBtn = find.text('Saqlash');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Parollar mos kelmadi'), findsOneWidget);
      verifyNever(() => mockNotifier.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
            confirmPassword: any(named: 'confirmPassword'),
          ));
    });

    testWidgets('submits data and shows success snackbar', (tester) async {
      final completer = Completer<String?>();
      when(() => mockNotifier.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
            confirmPassword: any(named: 'confirmPassword'),
          )).thenAnswer((_) => completer.future); 

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final inputs = find.byType(TextFormField);
      await tester.enterText(inputs.at(0), 'old_pwd123');
      await tester.enterText(inputs.at(1), 'new_pwd123');
      await tester.enterText(inputs.at(2), 'new_pwd123');

      final submitBtn = find.text('Saqlash');
      await tester.tap(submitBtn);
      
      await tester.pump(); 
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      completer.complete(null);
      await tester.pump(const Duration(milliseconds: 100)); // Render snackbar

      verify(() => mockNotifier.changePassword(
            currentPassword: 'old_pwd123',
            newPassword: 'new_pwd123',
            confirmPassword: 'new_pwd123',
          )).called(1);

      expect(find.text("Parol muvaffaqiyatli o'zgartirildi!"), findsOneWidget);
    });

    testWidgets('submits data and shows error snackbar on failure', (tester) async {
      when(() => mockNotifier.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
            confirmPassword: any(named: 'confirmPassword'),
          )).thenAnswer((_) async => 'Noto\'g\'ri joriy parol'); 

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final inputs = find.byType(TextFormField);
      await tester.enterText(inputs.at(0), 'wrong_old');
      await tester.enterText(inputs.at(1), 'new_pwd123');
      await tester.enterText(inputs.at(2), 'new_pwd123');

      final submitBtn = find.text('Saqlash');
      await tester.tap(submitBtn);

      await tester.pump(const Duration(milliseconds: 100)); // Render snackbar

      verify(() => mockNotifier.changePassword(
            currentPassword: 'wrong_old',
            newPassword: 'new_pwd123',
            confirmPassword: 'new_pwd123',
          )).called(1);

      expect(find.text('Noto\'g\'ri joriy parol'), findsOneWidget);
    });
  });
}
