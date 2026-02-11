import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  void _handlePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Parent API da to\'lov yaratish qo\'llab-quvvatlanmaydi.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(paymentProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }

      if (previous?.isLoading == true &&
          !next.isLoading &&
          next.error == null) {
        _showSuccessDialog();
      }
    });

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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8FDF0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'To\'lov muvaffaqiyatli!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'To\'lov tizimiga yo\'naltirilmoqdasiz...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Yopish',
              onPressed: () {
                Navigator.of(context).pop();
                context.pop(); // Go back to main payments screen
              },
              borderRadius: 12,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
