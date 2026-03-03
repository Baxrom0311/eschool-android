import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/screens/payments/payments_screen.dart';
import 'package:parent_school_app/presentation/providers/payment_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/data/models/payment_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/user_model.dart';

// Mock Payment Notifier
class MockPaymentNotifier extends StateNotifier<PaymentState> implements PaymentNotifier {
  MockPaymentNotifier(PaymentState state) : super(state);

  @override
  Future<void> loadInitialData({int? studentId}) async {}
  
  @override
  Future<void> refresh({int? studentId}) async {}
  
  @override
  Future<void> loadMorePayments({int? studentId}) async {}

  @override
  void clear() {}

  @override
  void clearError() {}

  @override
  Future<Map<String, dynamic>?> createPayment({
    required int amount,
    required String method,
    int? studentId,
  }) async => null;

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refreshBalance() async {}
}

class MockUserNotifier extends StateNotifier<UserState> implements UserNotifier {
  MockUserNotifier(UserState state) : super(state);

  @override
  void setUser(UserModel user) {}
  @override
  Future<void> loadProfile() async {}
  @override
  void selectChild(child) {}
  @override
  void selectChildById(int childId) {}
  @override
  void clear() {}
  @override
  void clearError() {}
  @override
  Future<void> updateProfile({String? fullName, String? email, String? phone, bool? notificationsEnabled}) async {}
  @override
  Future<void> restoreCachedProfile() async {}
  @override
  Future<String?> changePassword({required String currentPassword, required String newPassword, required String confirmPassword}) async => null;
  @override
  Future<void> uploadAvatar(String filePath) async {}
}

void main() {
  group('PaymentsScreen Widget Tests', () {
    testWidgets('Shows loading indicator when state is loading and no balance', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paymentProvider.overrideWith((ref) => MockPaymentNotifier(
              const PaymentState(isLoading: true)
            )),
          ],
          child: const MaterialApp(
            home: PaymentsScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Displays error message correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paymentProvider.overrideWith((ref) => MockPaymentNotifier(
              const PaymentState(isLoading: false, error: 'Tarmoq xatosi yuz berdi')
            )),
          ],
          child: const MaterialApp(
            home: PaymentsScreen(),
          ),
        ),
      );

      expect(find.text('Tarmoq xatosi yuz berdi'), findsOneWidget);
    });

    testWidgets('Displays debt section when balance object has debt', (tester) async {
      final mockChild = const ChildModel(id: 1, fullName: 'Test Child', className: '1-A', classId: 1);
      final mockBalance = const BalanceInfo(
        balance: 50000, 
        monthlyFee: 150000, 
        debtAmount: 100000, 
        contractNumber: 'CH-1234',
        hasFinancialData: true
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith((ref) => MockUserNotifier(
              UserState(selectedChild: mockChild)
            )),
            paymentProvider.overrideWith((ref) => MockPaymentNotifier(
              PaymentState(isLoading: false, balance: mockBalance, selectedStudentId: 1)
            )),
          ],
          child: const MaterialApp(
            home: PaymentsScreen(),
          ),
        ),
      );

      expect(find.text('Qarzdorlik mavjud'), findsOneWidget);
      expect(find.text('Shartnoma ma\'lumotlari'), findsOneWidget);
      expect(find.text('CH-1234'), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });
  });
}
