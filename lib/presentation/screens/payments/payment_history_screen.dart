import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/l10n/app_localizations.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';

/// Payment History Screen - List of past transactions
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  void _ensureDataLoaded() {
    final selectedStudentId = ref.read(selectedChildProvider)?.id;
    final paymentState = ref.read(paymentProvider);
    if (paymentState.payments.isEmpty ||
        paymentState.selectedStudentId != selectedStudentId) {
      ref
          .read(paymentProvider.notifier)
          .loadInitialData(studentId: selectedStudentId);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_ensureDataLoaded);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paymentProvider.notifier).loadMore();
    }
  }

  String _formatCurrencyAmount(AppLocalizations l10n, num amount) {
    return '${Formatters.formatCurrency(amount.toDouble())} ${l10n.currencyCode}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(paymentProvider);
    final transactions = state.payments;
    final isLoading = state.isLoading;
    final showLoadMoreIndicator =
        state.hasMore && isLoading && transactions.isNotEmpty;

    ref.listen(selectedChildProvider, (previous, next) {
      if (previous?.id != next?.id) {
        ref.read(paymentProvider.notifier).loadInitialData(studentId: next?.id);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.paymentHistoryTitle),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? colorScheme.surface,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Filter Chips (Visual only for now, or implement local filter)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: theme.cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(label: l10n.allPaymentsFilter, isActive: true),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.successfulPaymentsFilter,
                    isActive: false,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.rejectedPaymentsFilter,
                    isActive: false,
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          if (transactions.isEmpty && isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (transactions.isEmpty && !isLoading)
            Expanded(child: Center(child: Text(l10n.paymentHistoryEmpty)))
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount:
                    transactions.length + (showLoadMoreIndicator ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == transactions.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final tx = transactions[index];
                  final isSuccess = tx.isCompleted;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.danger.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess ? Icons.check_rounded : Icons.close_rounded,
                          color: isSuccess
                              ? AppColors.success
                              : AppColors.danger,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        l10n.paymentRecordTitle(tx.id),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            tx.createdAt,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                l10n.paymentMethodLabelText(tx.method.name),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '• ${l10n.paymentStatusLabel(tx.status.name)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSuccess
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        _formatCurrencyAmount(l10n, tx.amount),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSuccess
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          decoration: isSuccess
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outline,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
