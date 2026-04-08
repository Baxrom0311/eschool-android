import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/payment_provider.dart';
import 'package:parent_school_app/data/repositories/payment_repository.dart';
import 'package:parent_school_app/data/models/payment_model.dart';
import 'package:parent_school_app/core/error/exceptions.dart';

// Mock PaymentRepository
class MockPaymentRepository implements PaymentRepository {
  bool shouldReturnError = false;

  @override
  Future<BalanceInfo> getBalance({int? studentId}) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Balance load failed');
    }
    return const BalanceInfo(
      balance: 1500000,
      monthlyFee: 500000,
      contractNumber: '123/456',
      debtAmount: 0,
    );
  }

  @override
  Future<List<PaymentModel>> getPaymentHistory({
    int? studentId,
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'History load failed');
    }
    // Return 20 items to ensure hasMore is true
    return List.generate(
      20,
      (index) => PaymentModel(
        id: (page - 1) * 20 + index,
        amount: 500000,
        status: PaymentStatus.completed,
        method: PaymentMethod.payme,
        createdAt: '2023-10-10',
        description: 'Monthly fee $index',
      ),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Methods load failed');
    }
    return const [
      {'id': 'payme', 'name': 'PayMe', 'icon': 'assets/icons/payme.png'},
      {'id': 'click', 'name': 'Click', 'icon': 'assets/icons/click.png'},
    ];
  }

  @override
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    required String method,
    int? studentId,
  }) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Payment creation failed');
    }
    return const {
      'payment_id': 123,
      'redirect_url': 'https://payme.uz/checkout/123',
    };
  }

  @override
  Future<T> safeCall<T>(dynamic call, dynamic mapper) async =>
      throw UnimplementedError();
  @override
  Future<List<T>> safeCallList<T>(
    dynamic call,
    dynamic mapper, {
    String? listKey,
  }) async => throw UnimplementedError();
  @override
  Future<T> safeExecute<T>(dynamic call) async => throw UnimplementedError();
}

void main() {
  late PaymentNotifier paymentNotifier;
  late MockPaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockPaymentRepository();
    paymentNotifier = PaymentNotifier(repository: mockRepository);
  });

  group('PaymentNotifier Tests', () {
    test('Initial state should be correct', () {
      expect(paymentNotifier.state.isLoading, false);
      expect(paymentNotifier.state.balance, null);
    });

    test('loadInitialData success', () async {
      await paymentNotifier.loadInitialData();

      expect(paymentNotifier.state.isLoading, false);
      expect(paymentNotifier.state.balance?.balance, 1500000);
      expect(paymentNotifier.state.payments.length, 20);
      expect(paymentNotifier.state.paymentMethods.length, 2);
      expect(paymentNotifier.state.error, null);
    });

    test('loadMore success', () async {
      await paymentNotifier.loadInitialData(); // Load first page (20)

      await paymentNotifier.loadMore(); // Load second page (20)

      expect(paymentNotifier.state.isLoading, false);
      expect(paymentNotifier.state.currentPage, 2);
      expect(paymentNotifier.state.payments.length, 40); // 20 + 20
    });

    test('createPayment success', () async {
      final result = await paymentNotifier.createPayment(
        amount: 50000,
        method: 'payme',
        studentId: 1,
      );

      expect(paymentNotifier.state.isLoading, false);
      expect(result, isNotNull);
      expect(result?['payment_id'], 123);
    });

    test('createPayment failure', () async {
      mockRepository.shouldReturnError = true;
      final result = await paymentNotifier.createPayment(
        amount: 50000,
        method: 'payme',
        studentId: 1,
      );

      expect(paymentNotifier.state.isLoading, false);
      expect(result, null);
      expect(
        paymentNotifier.state.error,
        'ServerException: Payment creation failed',
      );
    });
  });
}
