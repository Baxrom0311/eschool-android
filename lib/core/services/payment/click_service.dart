class ClickService {
  Future<void> initiatePayment({
    required double amount,
    required String orderId,
  }) async {
    final _ = (amount, orderId);
    throw UnsupportedError(
      'Click SDK hali integratsiya qilinmagan. To\'lovni backend API orqali yarating.',
    );
  }

  Future<bool> verifyTransaction(String transactionId) async {
    final _ = transactionId;
    throw UnsupportedError(
      'Click transaction verification hali implement qilinmagan.',
    );
  }
}
