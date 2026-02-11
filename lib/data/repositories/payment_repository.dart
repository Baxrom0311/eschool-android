import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/utils/safe_api_call.dart';
import '../datasources/remote/payment_api.dart';
import '../models/payment_model.dart';

/// Payment Repository — to'lov biznes logikasi
class PaymentRepository {
  final PaymentApi _paymentApi;

  PaymentRepository({required PaymentApi paymentApi})
      : _paymentApi = paymentApi;

  /// Balans va shartnoma ma'lumotlari
  Future<Either<Failure, BalanceInfo>> getBalance({int? studentId}) =>
      safeApiCall(
        () => _paymentApi.getBalance(studentId: studentId),
        errorMessage: 'Balansni yuklashda xatolik',
      );

  /// To'lovlar tarixi
  Future<Either<Failure, List<PaymentModel>>> getPaymentHistory({
    int? studentId,
    int page = 1,
    int perPage = 20,
    String? status,
  }) =>
      safeApiCall(
        () => _paymentApi.getPaymentHistory(
          studentId: studentId,
          page: page,
          perPage: perPage,
          status: status,
        ),
        errorMessage: 'To\'lovlar tarixini yuklashda xatolik',
      );

  /// Yangi to'lov yaratish
  Future<Either<Failure, Map<String, dynamic>>> createPayment({
    required int amount,
    required String method,
  }) =>
      safeApiCall(
        () => _paymentApi.createPayment(amount: amount, method: method),
        errorMessage: 'To\'lov yaratishda xatolik',
      );

  /// To'lov usullari
  Future<Either<Failure, List<Map<String, dynamic>>>> getPaymentMethods() =>
      safeApiCall(
        () => _paymentApi.getPaymentMethods(),
        errorMessage: 'To\'lov usullarini yuklashda xatolik',
      );
}
