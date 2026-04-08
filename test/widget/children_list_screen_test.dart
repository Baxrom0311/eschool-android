import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/profile/children_list_screen.dart';

class MockUserNotifier extends StateNotifier<UserState>
    with Mock
    implements UserNotifier {
  MockUserNotifier(super.state);
}

void main() {
  Widget buildTestWidget(MockUserNotifier notifier) {
    return ProviderScope(
      overrides: [userProvider.overrideWith((ref) => notifier)],
      child: MaterialApp(
        locale: const Locale('uz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ChildrenListScreen(),
      ),
    );
  }

  testWidgets('children list screen renders localized title and rows', (
    tester,
  ) async {
    const children = [
      ChildModel(id: 1, fullName: 'Ali Valiyev', className: '5-A', classId: 10),
      ChildModel(
        id: 2,
        fullName: 'Vali Valiyev',
        className: '6-B',
        classId: 11,
      ),
    ];

    final notifier = MockUserNotifier(
      UserState(children: children, selectedChild: children[0]),
    );

    await tester.pumpWidget(buildTestWidget(notifier));
    await tester.pumpAndSettle();

    expect(find.text('Mening farzandlarim'), findsOneWidget);
    expect(find.text('Ali Valiyev'), findsOneWidget);
    expect(find.text('Sinf: 5-A'), findsOneWidget);
    expect(find.text('Vali Valiyev'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
