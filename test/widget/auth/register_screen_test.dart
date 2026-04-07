import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/presentation/screens/auth/register_screen.dart';

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('uz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const RegisterScreen(),
      ),
    );
  }

  testWidgets('register screen renders localized labels', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Ro\'yxatdan o\'tish'), findsOneWidget);
    expect(find.text('Yangi hisob yaratish'), findsOneWidget);
    expect(find.text('Ism Familiya'), findsOneWidget);
    expect(find.text('Telefon raqam'), findsOneWidget);
    expect(find.text('Parol'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Parolni tasdiqlang'),
      find.byType(Scrollable),
      const Offset(0, -120),
    );
    expect(find.text('Parolni tasdiqlang'), findsOneWidget);
    expect(find.text('Hisob yaratish'), findsOneWidget);
    expect(find.text('Hisobingiz bormi? '), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);
  });

  testWidgets('register screen shows localized unavailable message', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ali Valiyev');
    await tester.enterText(fields.at(1), '+998901234567');
    await tester.enterText(fields.at(2), 'secret12');
    await tester.enterText(fields.at(3), 'secret12');

    await tester.ensureVisible(find.text('Hisob yaratish'));
    await tester.tap(find.text('Hisob yaratish'));
    await tester.pump();

    expect(
      find.textContaining(
        'Tenant API da ro\'yxatdan o\'tish endpointi mavjud emas',
      ),
      findsOneWidget,
    );
  });
}
