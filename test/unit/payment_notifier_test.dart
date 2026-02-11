import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/payment_provider.dart';
import 'package:parent_school_app/data/repositories/payment_repository.dart';
import 'package:parent_school_app/data/models/payment_model.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Mock PaymentRepository
class MockPaymentRepository implements PaymentRepository {
  bool shouldReturnError = false;

  @override
  Future<Either<Failure, BalanceInfo>> getBalance({int? studentId}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Balance load failed'));
    }
    return const Right(BalanceInfo(
      balance: 1500000,
      monthlyFee: 500000,
      contractNumber: '123/456',
      debtAmount: 0,
    ));
  }

  @override
  Future<Either<Failure, List<PaymentModel>>> getPaymentHistory({
    int? studentId,
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('History load failed'));
    }
    // Return 20 items to ensure hasMore is true
    return Right(List.generate(20, (index) => PaymentModel(
      id: (page - 1) * 20 + index, 
      amount: 500000,
      status: PaymentStatus.completed,
      method: PaymentMethod.payme,
      createdAt: '2023-10-10',
      description: 'Monthly fee $index',
    )));
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPaymentMethods() async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Methods load failed'));
    }
    return const Right([
      {'id': 'payme', 'name': 'PayMe', 'icon': 'assets/icons/payme.png'},
      {'id': 'click', 'name': 'Click', 'icon': 'assets/icons/click.png'},
    ]);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createPayment({required int amount, required String method}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Payment creation failed'));
    }
    return const Right({
      'payment_id': 123,
      'redirect_url': 'https://payme.uz/checkout/123',
    });
  }
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
      expect(paymentNotifier.state.payments.length, 20); // Updated expectation
      expect(paymentNotifier.state.paymentMethods.length, 2);
      expect(paymentNotifier.state.error, null);
    });

    // ... (failure test unchanged)

    test('loadMore success', () async {
      await paymentNotifier.loadInitialData(); // Load first page (20)
      
      await paymentNotifier.loadMore(); // Load second page (20)
      
      expect(paymentNotifier.state.isLoading, false);
      expect(paymentNotifier.state.currentPage, 2);
      expect(paymentNotifier.state.payments.length, 40); // 20 + 20
    });

    test('createPayment success', () async {
      final result = await paymentNotifier.createPayment(amount: 50000, method: 'payme');
      
      expect(paymentNotifier.state.isLoading, false);
      expect(result, isNotNull);
      expect(result?['payment_id'], 123);
    });

    test('createPayment failure', () async {
      mockRepository.shouldReturnError = true;
      final result = await paymentNotifier.createPayment(amount: 50000, method: 'payme');
      
      expect(paymentNotifier.state.isLoading, false);
      expect(result, null);
      expect(paymentNotifier.state.error, 'Payment creation failed');
    });
  });
}
