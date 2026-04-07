import '../datasources/remote/payment_api.dart';
import '../models/payment_model.dart';
import 'base_repository.dart';

/// To'lovlar va balans bilan ishlash uchun repozitoriy
class PaymentRepository extends BaseRepository {
  final PaymentApi _paymentApi;

  PaymentRepository({required PaymentApi paymentApi}) : _paymentApi = paymentApi;

  /// Joriy balansni olish
  Future<BalanceInfo> getBalance({int? studentId}) =>
      _paymentApi.getBalance(studentId: studentId);

  /// To'lovlar tarixini olish
  Future<List<PaymentModel>> getPaymentHistory({
    int page = 1,
    int perPage = 20,
    String? status,
    int? studentId,
  }) =>
      _paymentApi.getPaymentHistory(
        page: page,
        perPage: perPage,
        status: status,
        studentId: studentId,
      );

  /// Mavjud to'lov tizimlarini olish (Click, Payme, va h.k.)
  Future<List<Map<String, dynamic>>> getPaymentMethods() =>
      _paymentApi.getPaymentMethods();

  /// Yangi to'lov yaratish (Invoys/Check yaratish)
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    required String method,
    int? studentId,
  }) =>
      _paymentApi.createPayment(
        amount: amount,
        method: method,
        studentId: studentId,
      );
}
