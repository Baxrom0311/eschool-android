import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/l10n/app_localizations.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/payments/balance_header.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/page_background.dart';

/// Payments Screen - Main view for billing and payments
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  int? _lastLoadedStudentId;

  void _loadPaymentDataForSelectedChild({bool force = false}) {
    final studentId = ref.read(selectedChildProvider)?.id;
    final paymentState = ref.read(paymentProvider);
    final hasData =
        paymentState.selectedStudentId == studentId &&
        (paymentState.balance != null ||
            paymentState.payments.isNotEmpty ||
            paymentState.paymentMethods.isNotEmpty) &&
        paymentState.error == null;
    if (!force &&
        paymentState.isLoading &&
        paymentState.selectedStudentId == studentId) {
      return;
    }
    if (!force && _lastLoadedStudentId == studentId && hasData) {
      return;
    }

    _lastLoadedStudentId = studentId;
    ref.read(paymentProvider.notifier).loadInitialData(studentId: studentId);
  }

  String _formatLastUpdated(AppLocalizations l10n, String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return l10n.notUpdatedLabel;
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return l10n.notUpdatedLabel;

    final now = DateTime.now();
    if (now.year == parsed.year &&
        now.month == parsed.month &&
        now.day == parsed.day) {
      return l10n.todayLabel;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day.$month.${parsed.year}';
  }

  String _formatCurrencyAmount(AppLocalizations l10n, num amount) {
    return '${Formatters.formatCurrency(amount.toDouble())} ${l10n.currencyCode}';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPaymentDataForSelectedChild);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(paymentProvider);
    final userState = ref.watch(userProvider);
    final child = userState.selectedChild;
    final hasFinancialData = state.balance?.hasFinancialData ?? false;
    final hasDebt = hasFinancialData && (state.balance?.hasDebt ?? false);
    final debtAmount = state.balance?.debtAmount ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text(
                l10n.paymentsTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: PageBackground(
        child: state.isLoading && state.balance == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async => _loadPaymentDataForSelectedChild(force: true),
                color: AppColors.primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120), // More space for floating nav
                  child: Column(
                    children: [
                      // ─── Header Section ───
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                        child: BalanceHeader(
                          balance: hasFinancialData
                              ? _formatCurrencyAmount(l10n, state.balance?.balance ?? 0)
                              : l10n.noFinancialData,
                          lastUpdated: _formatLastUpdated(l10n, state.balance?.nextPaymentDate),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.error != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  state.error!,
                                  style: TextStyle(color: colorScheme.error, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),

                            // ─── Contract Info Card ───
                            if (child != null || state.balance?.contractNumber != null)
                              _InfoCard(
                                title: l10n.contractInfoTitle,
                                icon: Icons.description_rounded,
                                items: [
                                  if (state.balance?.contractNumber != null)
                                    {'label': l10n.contractLabel, 'value': state.balance!.contractNumber!},
                                  if (child != null)
                                    {'label': l10n.studentLabel, 'value': child.fullName},
                                  if (child != null)
                                    {'label': l10n.classLabel, 'value': child.className},
                                  if (hasFinancialData && state.balance != null)
                                    {'label': l10n.balanceLabel, 'value': _formatCurrencyAmount(l10n, state.balance!.balance)},
                                  if (hasFinancialData && (state.balance?.monthlyFee ?? 0) > 0)
                                    {'label': l10n.monthlyPaymentLabel, 'value': _formatCurrencyAmount(l10n, state.balance!.monthlyFee)},
                                ],
                              ),
                            
                            const SizedBox(height: 22),

                            // ─── Payment Status (Debt Alert) ───
                            if (hasDebt)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.amber.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.2), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.amber.withValues(alpha: 0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: AppColors.amber,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.debtExistsTitle,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.amber,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.debtPaymentPrompt(_formatCurrencyAmount(l10n, debtAmount)),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.amber.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            const SizedBox(height: 22),

                            // ─── Action Buttons ───
                            CustomButton(
                              text: l10n.payNowAction,
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                context.push(RouteNames.paymentMethod);
                              },
                              height: 60,
                              borderRadius: 20,
                              icon: Icons.payments_rounded,
                              backgroundColor: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.push(RouteNames.paymentHistory);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15), width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.history_rounded, color: theme.colorScheme.primary, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.paymentHistoryTitle,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, String>> items;

  const _InfoCard({required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label']!,
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.w600, 
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        item['value']!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
