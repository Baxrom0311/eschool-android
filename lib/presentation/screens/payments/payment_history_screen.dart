import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Payment History Screen - List of past transactions
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);
    final transactions = state.payments;
    final isLoading = state.isLoading;

    ref.listen(selectedChildProvider, (previous, next) {
      if (previous?.id != next?.id) {
        ref
            .read(paymentProvider.notifier)
            .loadInitialData(studentId: next?.id);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('To\'lovlar tarixi'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips (Visual only for now, or implement local filter)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                   _FilterChip(label: 'Hammasi', isActive: true),
                  SizedBox(width: 8),
                  _FilterChip(label: 'Muvaffaqiyatli', isActive: false),
                  SizedBox(width: 8),
                   _FilterChip(label: 'Rad etilgan', isActive: false),
                ],
              ),
            ),
          ),

          // Transactions List
          if (transactions.isEmpty && !isLoading)
            const Expanded(child: Center(child: Text('To\'lovlar tarixi bo\'sh')))
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: transactions.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == transactions.length) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final tx = transactions[index];
                  final isSuccess = tx.isCompleted;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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
                          color: isSuccess ? AppColors.success : AppColors.danger,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        'To\'lov #${tx.id}', 
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            tx.createdAt, 
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                tx.methodText,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '• ${tx.statusText}',
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
                        tx.formattedAmount,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSuccess
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          decoration:
                              isSuccess ? null : TextDecoration.lineThrough,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primaryBlue : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
