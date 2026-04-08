import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/profile/edit_profile_screen.dart';

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
        home: const EditProfileScreen(),
      ),
    );
  }

  testWidgets('edit profile screen renders localized sections and actions', (
    tester,
  ) async {
    final notifier = MockUserNotifier(
      const UserState(
        user: UserModel(
          id: 7,
          fullName: 'Ali Valiyev',
          phone: '+998901234567',
          email: 'ali@example.com',
          notificationsEnabled: true,
        ),
      ),
    );

    await tester.pumpWidget(buildTestWidget(notifier));
    await tester.pumpAndSettle();

    expect(find.text('Shaxsiy ma\'lumotlar'), findsOneWidget);
    expect(find.text('Saqlash'), findsNWidgets(2));
    expect(find.text('Rasmni o\'zgartirish'), findsOneWidget);
    expect(find.text('Asosiy ma\'lumotlar'), findsOneWidget);
    expect(find.text('Ism va familiya'), findsOneWidget);
    expect(find.text('Telefon raqami'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Xabarnomalar'), findsOneWidget);
    expect(
      find.text('Push-xabarnomalarni yoqish yoki o\'chirish'),
      findsOneWidget,
    );
  });
}
