import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/core/routing/route_names.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/models/payment_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/presentation/providers/auth_provider.dart';
import 'package:parent_school_app/presentation/providers/payment_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/profile/profile_screen.dart';

class MockUserNotifier extends StateNotifier<UserState> with Mock implements UserNotifier {
  MockUserNotifier(super.state);
}

class MockPaymentNotifier extends StateNotifier<PaymentState> with Mock implements PaymentNotifier {
  MockPaymentNotifier(super.state);
}

class MockAuthNotifier extends StateNotifier<AuthState> with Mock implements AuthNotifier {
  MockAuthNotifier(super.state);
}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockUserNotifier mockUserNotifier;
  late MockPaymentNotifier mockPaymentNotifier;
  late MockAuthNotifier mockAuthNotifier;
  late MockGoRouter mockGoRouter;

  final testUser = const UserModel(
    id: 1,
    role: 'parent',
    fullName: 'Eshmatov Toshmat',
    phone: '+998901234567',
  );

  final testChildren = const <ChildModel>[
    ChildModel(
      id: 101,
      fullName: 'Eshmatov Ali',
      className: '1A',
      classId: 10,
    ),
    ChildModel(
      id: 102,
      fullName: 'Eshmatov Vali',
      className: '2B',
      classId: 11,
    ),
  ];

  final testBalance = const BalanceInfo(
    balance: 150000,
    monthlyFee: 500000,
    hasFinancialData: true,
  );

  setUp(() {
    mockUserNotifier = MockUserNotifier(
      UserState(
        user: testUser,
        children: testChildren,
      ),
    );

    mockPaymentNotifier = MockPaymentNotifier(
      PaymentState(
        balance: testBalance,
      ),
    );

    mockAuthNotifier = MockAuthNotifier(
      const AuthState(isAuthenticated: true),
    );

    mockGoRouter = MockGoRouter();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        userProvider.overrideWith((ref) => mockUserNotifier),
        paymentProvider.overrideWith((ref) => mockPaymentNotifier),
        authProvider.overrideWith((ref) => mockAuthNotifier),
      ],
      child: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('renders user information and metrics properly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Eshmatov Toshmat'), findsOneWidget);
      expect(find.text('Tel: +998901234567'), findsOneWidget);
      
      // Formatting might vary based on the formatter, assuming 150 000 UZS
      expect(find.textContaining('UZS'), findsOneWidget);
      expect(find.text('2 ta'), findsOneWidget); // 2 farzand
      expect(find.text('Balans'), findsOneWidget);
      expect(find.text('Farzandlar'), findsOneWidget);
    });

    testWidgets('taps on Settings items redirects or shows snackbar appropriately', (tester) async {
      when(() => mockGoRouter.push(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Shaxsiy ma'lumotlar -> SnackBar 'Tez orada...'
      await tester.tap(find.text('Shaxsiy ma\'lumotlar'));
      await tester.pump(const Duration(milliseconds: 100)); // allow snackbar to show
      expect(find.text('Tez orada...'), findsOneWidget);
      await tester.pumpAndSettle(); // clear snackbar

      // Parolni o'zgartirish
      await tester.ensureVisible(find.text('Parolni o\'zgartirish'));
      await tester.tap(find.text('Parolni o\'zgartirish'));
      await tester.pumpAndSettle();
      verify(() => mockGoRouter.push(RouteNames.changePassword)).called(1);

      // Chat / Yordam
      await tester.ensureVisible(find.text('Chat / Yordam'));
      await tester.tap(find.text('Chat / Yordam'));
      await tester.pumpAndSettle();
      verify(() => mockGoRouter.push(RouteNames.chatList)).called(1);

      // Bildirishnomalar
      await tester.ensureVisible(find.text('Bildirishnomalar'));
      await tester.tap(find.text('Bildirishnomalar'));
      await tester.pumpAndSettle();
      verify(() => mockGoRouter.push(RouteNames.notifications)).called(1);
    });

    testWidgets('shows About Dialog when tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Ilova haqida'),
        find.byType(Scrollable),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ilova haqida'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialog), findsOneWidget);
      expect(find.text('E-School'), findsOneWidget);
      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('logout process functions correctly', (tester) async {
      when(() => mockAuthNotifier.logout()).thenAnswer((_) async => null);
      when(() => mockUserNotifier.clear()).thenReturn(null);
      when(() => mockPaymentNotifier.clear()).thenReturn(null);
      when(() => mockGoRouter.go(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Tizimdan chiqish'),
        find.byType(Scrollable),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tizimdan chiqish'));
      await tester.pumpAndSettle();

      // Alert Dialog should be present
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Rostdan ham tizimdan chiqmoqchimisiz?'), findsOneWidget);

      final confirmBtn = find.text('Chiqish');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      verify(() => mockAuthNotifier.logout()).called(1);
      verify(() => mockUserNotifier.clear()).called(1);
      verify(() => mockPaymentNotifier.clear()).called(1);
      verify(() => mockGoRouter.go(RouteNames.login)).called(1);
    });
  });
}
