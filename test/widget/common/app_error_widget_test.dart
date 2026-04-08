import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/presentation/widgets/common/app_error_widget.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('uz'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  testWidgets('app error widget renders localized retry state', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(AppErrorWidget.noInternet(onRetry: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Internet aloqasi yo\'q'), findsOneWidget);
    expect(find.text('Qayta urinish'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
  });
}
