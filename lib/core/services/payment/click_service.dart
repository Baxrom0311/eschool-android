import '../../error/exceptions.dart';

class ClickService {
  Future<void> initiatePayment({
    required double amount,
    required String orderId,
  }) async {
    final _ = (amount, orderId);
    throw const ServerException(
      message: 'Click SDK hali integratsiya qilinmagan. To\'lovni backend API orqali yarating.',
      statusCode: 405,
    );
  }

  Future<bool> verifyTransaction(String transactionId) async {
    final _ = transactionId;
    throw const ServerException(
      message: 'Click transaction verification hali implement qilinmagan.',
      statusCode: 405,
    );
  }
}
