import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled
}

class PaymentResult {
  final PaymentStatus status;
  final String? message;
  final String? transactionId;

  PaymentResult({
    required this.status,
    this.message,
    this.transactionId,
  });

  bool get isSuccess => status == PaymentStatus.completed;
}

/// To'lov xizmatlari uchun abstrakt klass
abstract class PaymentService {
  /// To'lovni boshlash
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? extra,
  });

  /// To'lov holatini tekshirish
  Future<PaymentStatus> checkStatus(String transactionId);
}

/// Asosiy To'lov xizmati implementatsiyasi (Stub)
class GeneralPaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? extra,
  }) async {
    // Kelajakda PayMe, Click yoki boshqa provayder integratsiyasi shu yerda bo'ladi
    await Future.delayed(const Duration(seconds: 2));
    
    return PaymentResult(
      status: PaymentStatus.completed,
      transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      message: 'To\'lov muvaffaqiyatli yakunlandi',
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String transactionId) async {
    return PaymentStatus.completed;
  }
}

/// Payment service provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return GeneralPaymentService();
});
