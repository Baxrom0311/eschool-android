import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/payments/payment_method_card.dart';
import '../../widgets/common/custom_button.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  String _selectedMethod = 'click';
  final TextEditingController _amountController = TextEditingController(
    text: '450000',
  );

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(digits);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('To\'lov summasini to\'g\'ri kiriting'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final paymentData = await ref
        .read(paymentProvider.notifier)
        .createPayment(amount: amount, method: _selectedMethod);
    if (!mounted) return;

    if (paymentData == null) {
      final error =
          ref.read(paymentProvider).error ??
          'Parent API da to\'lov yaratish qo\'llab-quvvatlanmaydi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.danger),
      );
      return;
    }

    final redirectUrl = paymentData['redirect_url']?.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          redirectUrl == null || redirectUrl.isEmpty
              ? 'To\'lov yaratildi'
              : 'To\'lov havolasi: $redirectUrl',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final isLoading = paymentState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('To\'lov usuli'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Amount Input ───
            const Text(
              'To\'lov summasi (UZS)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  suffixText: 'UZS',
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ─── Payment Methods ───
            const Text(
              'Xo\'sh, qanday to\'laymiz?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 16),

            PaymentMethodCard(
              name: 'Click',
              logoUrl:
                  'https://pay.click.uz/static/img/click_logo.png', // Fallback URL
              isSelected: _selectedMethod == 'click',
              onTap: () => setState(() => _selectedMethod = 'click'),
            ),
            const SizedBox(height: 12),

            PaymentMethodCard(
              name: 'PayMe',
              logoUrl:
                  'https://cdn.payme.uz/v2/logos/payme_logo.png', // Fallback URL
              isSelected: _selectedMethod == 'payme',
              onTap: () => setState(() => _selectedMethod = 'payme'),
            ),
            const SizedBox(height: 12),

            PaymentMethodCard(
              name: 'Visa / MasterCard',
              logoUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png',
              isSelected: _selectedMethod == 'card',
              onTap: () => setState(() => _selectedMethod = 'card'),
            ),
            const SizedBox(height: 48),

            // ─── Pay Button ───
            CustomButton(
              text: 'To\'lovni amalga oshirish',
              onPressed: isLoading ? null : _handlePayment,
              isLoading: isLoading,
              height: 56,
              borderRadius: 16,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tugmani bosish orqali siz ommaviy oferta shartlariga rozilik bildirasiz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
