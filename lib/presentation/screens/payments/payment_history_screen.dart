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
                l10n.paymentHistoryTitle,
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
            child: Column(
              children: [
                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _FilterChip(label: l10n.allPaymentsFilter, isActive: true),
                        const SizedBox(width: 8),
                        _FilterChip(label: l10n.successfulPaymentsFilter, isActive: false),
                        const SizedBox(width: 8),
                        _FilterChip(label: l10n.rejectedPaymentsFilter, isActive: false),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          if (transactions.isEmpty && isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (transactions.isEmpty && !isLoading)
            SliverFillRemaining(child: Center(child: Text(l10n.paymentHistoryEmpty)))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == transactions.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final tx = transactions[index];
                    final isSuccess = tx.isCompleted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isSuccess ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isSuccess ? Icons.receipt_long_rounded : Icons.error_outline_rounded,
                            color: isSuccess ? AppColors.success : AppColors.danger,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          l10n.paymentRecordTitle(tx.id),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
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
                                color: AppColors.slate400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l10n.paymentMethodLabelText(tx.method.name).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.slate600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.paymentStatusLabel(tx.status.name),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSuccess ? AppColors.success : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrencyAmount(l10n, tx.amount),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isSuccess ? AppColors.slate900 : AppColors.slate400,
                                decoration: isSuccess ? null : TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: transactions.length + (showLoadMoreIndicator ? 1 : 0),
                ),
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
        color: isActive ? AppColors.primaryBlue : AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryBlue : AppColors.slate200,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.slate600,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }
}
