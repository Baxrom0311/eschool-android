import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/home/widgets/home_header.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  Widget buildTestWidget(ChildModel child) {
    return ProviderScope(
      overrides: [selectedChildProvider.overrideWithValue(child)],
      child: MaterialApp(
        locale: const Locale('uz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: HomeHeader()),
      ),
    );
  }

  testWidgets('home header renders localized greeting and current date', (
    tester,
  ) async {
    const child = ChildModel(
      id: 1,
      fullName: 'Ali Valiyev',
      className: '5-A',
      classId: 10,
    );

    await tester.pumpWidget(buildTestWidget(child));
    await tester.pumpAndSettle();

    expect(find.text('Salom, Ali Valiyev'), findsOneWidget);
    expect(
      find.text(DateFormat('EEEE, d-MMMM', 'uz').format(DateTime.now())),
      findsOneWidget,
    );
  });
}
