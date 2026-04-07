import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parent_school_app/presentation/screens/auth/forgot_password_screen.dart';

void main() {
  testWidgets('forgot password screen renders localized first step',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ForgotPasswordScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Parolni tiklash'), findsOneWidget);
    expect(find.text('Telefon raqamingizni kiriting'), findsOneWidget);
    expect(find.text('Kod yuborish'), findsOneWidget);
    expect(find.text('Kirish sahifasiga qaytish'), findsOneWidget);
  });
}
