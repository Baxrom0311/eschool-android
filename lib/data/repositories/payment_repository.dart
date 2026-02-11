import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/payment_api.dart';
import '../models/payment_model.dart';

/// Payment Repository — to'lov biznes logikasi
class PaymentRepository {
  final PaymentApi _paymentApi;

  PaymentRepository({required PaymentApi paymentApi})
      : _paymentApi = paymentApi;

  /// Balans va shartnoma ma'lumotlari
  Future<Either<Failure, BalanceInfo>> getBalance({int? studentId}) async {
    try {
      final balance = await _paymentApi.getBalance(studentId: studentId);
      return Right(balance);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Balansni yuklashda xatolik: ${e.toString()}'));
    }
  }

  /// To'lovlar tarixi
  Future<Either<Failure, List<PaymentModel>>> getPaymentHistory({
    int? studentId,
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    try {
      final payments = await _paymentApi.getPaymentHistory(
        studentId: studentId,
        page: page,
        perPage: perPage,
        status: status,
      );
      return Right(payments);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('To\'lovlar tarixini yuklashda xatolik: ${e.toString()}'),
      );
    }
  }

  /// Yangi to'lov yaratish
  Future<Either<Failure, Map<String, dynamic>>> createPayment({
    required int amount,
    required String method,
  }) async {
    try {
      final result = await _paymentApi.createPayment(
        amount: amount,
        method: method,
      );
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('To\'lov yaratishda xatolik: ${e.toString()}'),
      );
    }
  }

  /// To'lov usullari
  Future<Either<Failure, List<Map<String, dynamic>>>> getPaymentMethods() async {
    try {
      final methods = await _paymentApi.getPaymentMethods();
      return Right(methods);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Xatolik: ${e.toString()}'));
    }
  }
}
