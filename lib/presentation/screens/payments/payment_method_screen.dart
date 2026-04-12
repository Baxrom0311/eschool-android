import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/constants/app_colors.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── Premium Header ───
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
              ),
              title: Text(
                l10n.paymentMethodTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Amount Input ───
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.paymentAmountLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            suffixText: ' ${l10n.currencyCode}',
                            suffixStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Payment Methods ───
                  Text(
                    l10n.paymentMethodsPrompt,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PaymentMethodCard(
                  name: 'Click',
                  logoUrl: 'https://pay.click.uz/static/img/click_logo.png',
                  isSelected: _selectedMethod == 'click',
                  onTap: () => setState(() => _selectedMethod = 'click'),
                ),
                const SizedBox(height: 12),
                PaymentMethodCard(
                  name: 'PayMe',
                  logoUrl: 'https://cdn.payme.uz/v2/logos/payme_logo.png',
                  isSelected: _selectedMethod == 'payme',
                  onTap: () => setState(() => _selectedMethod = 'payme'),
                ),
              ]),
            ),
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: l10n.paymentAction.toUpperCase(),
                    onPressed: isLoading ? null : _handlePayment,
                    isLoading: isLoading,
                    height: 62,
                    borderRadius: 32,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.paymentAgreementText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.slate400,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
