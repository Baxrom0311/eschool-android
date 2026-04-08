import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/presentation/screens/auth/forgot_password_screen.dart';

void main() {
  testWidgets('forgot password screen renders localized first step', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('uz'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ForgotPasswordScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Parolni tiklash'), findsOneWidget);
    expect(find.text('Telefon raqamingizni kiriting'), findsOneWidget);
    expect(find.text('Kod yuborish'), findsOneWidget);
    expect(find.text('Kirishga qaytish'), findsOneWidget);
  });
}
