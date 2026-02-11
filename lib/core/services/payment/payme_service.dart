class PayMeService {
  Future<void> initiatePayment({
    required double amount,
    required String orderId,
  }) async {
    final _ = (amount, orderId);
    throw UnsupportedError(
      'PayMe SDK hali integratsiya qilinmagan. To\'lovni backend API orqali yarating.',
    );
  }

  Future<bool> verifyTransaction(String transactionId) async {
    final _ = transactionId;
    throw UnsupportedError(
      'PayMe transaction verification hali implement qilinmagan.',
    );
  }
}
