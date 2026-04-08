import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
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
    final l10n = context.l10n;
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(digits);

    if (amount == null || amount <= 0) {
      AppSnackBar.show(
        context,
        l10n.paymentAmountInvalid,
        type: AppSnackBarType.error,
      );
      return;
    }

    final selectedStudentId = ref.read(selectedChildProvider)?.id;
    if (selectedStudentId == null || selectedStudentId <= 0) {
      AppSnackBar.show(
        context,
        l10n.selectChildFirst,
        type: AppSnackBarType.error,
      );
      return;
    }

    final paymentData = await ref
        .read(paymentProvider.notifier)
        .createPayment(
          amount: amount,
          method: _selectedMethod,
          studentId: selectedStudentId,
        );
    if (!mounted) return;

    if (paymentData == null) {
      final error =
          ref.read(paymentProvider).error ?? l10n.paymentCreateUnsupported;
      AppSnackBar.show(context, error, type: AppSnackBarType.error);
      return;
    }

    final redirectUrl = paymentData['redirect_url']?.toString();

    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      final uri = Uri.parse(redirectUrl);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showError(l10n.paymentRedirectOpenFallback);
          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        }
      } catch (e) {
        _showError(l10n.paymentLinkOpenFailed);
      }
    } else {
      AppSnackBar.show(context, l10n.paymentCreatedNoLink);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    AppSnackBar.show(context, message, type: AppSnackBarType.error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final paymentState = ref.watch(paymentProvider);
    final isLoading = paymentState.isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.paymentMethodTitle),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Amount Input ───
            Text(
              l10n.paymentAmountLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  suffixText: l10n.currencyCode,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ─── Payment Methods ───
            Text(
              l10n.paymentMethodsPrompt,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
            const SizedBox(height: 48),

            // ─── Pay Button ───
            CustomButton(
              text: l10n.paymentAction,
              onPressed: isLoading ? null : _handlePayment,
              isLoading: isLoading,
              height: 56,
              borderRadius: 16,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.paymentAgreementText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
