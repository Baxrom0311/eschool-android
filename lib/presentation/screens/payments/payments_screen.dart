import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/payments/balance_header.dart';
import '../../widgets/common/custom_button.dart';

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

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadPaymentDataForSelectedChild();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.paymentsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        elevation: 0,
      ),
      body: state.isLoading && state.balance == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(paymentProvider.notifier)
                  .refresh(studentId: child?.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ─── Header Section ───
                    Container(
                      color:
                          theme.appBarTheme.backgroundColor ??
                          colorScheme.surface,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: BalanceHeader(
                        balance: hasFinancialData
                            ? _formatCurrencyAmount(
                                l10n,
                                state.balance?.balance ?? 0,
                              )
                            : l10n.noFinancialData,
                        lastUpdated: _formatLastUpdated(
                          l10n,
                          state.balance?.nextPaymentDate,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                state.error!,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),

                          // ─── Contract Info Card ───
                          if (child != null ||
                              state.balance?.contractNumber != null)
                            _InfoCard(
                              title: l10n.contractInfoTitle,
                              icon: Icons.description_rounded,
                              items: [
                                if (state.balance?.contractNumber != null)
                                  {
                                    'label': l10n.contractLabel,
                                    'value': state.balance!.contractNumber!,
                                  },
                                if (child != null)
                                  {
                                    'label': l10n.studentLabel,
                                    'value': child.fullName,
                                  },
                                if (child != null)
                                  {
                                    'label': l10n.classLabel,
                                    'value': child.className,
                                  },
                                if (hasFinancialData && state.balance != null)
                                  {
                                    'label': l10n.balanceLabel,
                                    'value': _formatCurrencyAmount(
                                      l10n,
                                      state.balance!.balance,
                                    ),
                                  },
                                if (hasFinancialData &&
                                    (state.balance?.monthlyFee ?? 0) > 0)
                                  {
                                    'label': l10n.monthlyPaymentLabel,
                                    'value': _formatCurrencyAmount(
                                      l10n,
                                      state.balance!.monthlyFee,
                                    ),
                                  },
                              ],
                            ),
                          const SizedBox(height: 24),

                          // ─── Payment Status ───
                          if (hasDebt)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0), // Light Orange
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.debtExistsTitle,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.debtPaymentPrompt(
                                            _formatCurrencyAmount(
                                              l10n,
                                              debtAmount,
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 32),

                          // ─── Action Buttons ───
                          CustomButton(
                            text: l10n.payNowAction,
                            onPressed: () {
                              context.push(RouteNames.paymentMethod);
                            },
                            height: 56,
                            borderRadius: 16,
                            icon: Icons.payments_rounded,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              context.push(RouteNames.paymentHistory);
                            },
                            icon: const Icon(Icons.history_rounded),
                            label: Text(l10n.paymentHistoryTitle),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              foregroundColor: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      item['value']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
