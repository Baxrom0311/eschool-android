import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/presentation/providers/payment_provider.dart';
import 'package:parent_school_app/presentation/screens/payments/payment_method_screen.dart';

class MockPaymentNotifier extends StateNotifier<PaymentState>
    with Mock
    implements PaymentNotifier {
  MockPaymentNotifier(super.state);
}

void main() {
  Widget buildTestWidget(MockPaymentNotifier notifier) {
    return ProviderScope(
      overrides: [paymentProvider.overrideWith((ref) => notifier)],
      child: MaterialApp(
        locale: const Locale('uz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const PaymentMethodScreen(),
      ),
    );
  }

  testWidgets('payment method screen renders localized content', (
    tester,
  ) async {
    final notifier = MockPaymentNotifier(const PaymentState.initial());

    await tester.pumpWidget(buildTestWidget(notifier));
    await tester.pumpAndSettle();

    expect(find.text('To\'lov usuli'), findsOneWidget);
    expect(find.text('To\'lov summasi (UZS)'), findsOneWidget);
    expect(find.text('Qanday usulda to\'lamoqchisiz?'), findsOneWidget);
    expect(find.text('Click'), findsOneWidget);
    expect(find.text('PayMe'), findsOneWidget);
    expect(find.text('To\'lovga o\'tish'), findsOneWidget);
  });
}
