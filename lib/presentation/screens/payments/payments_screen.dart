import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routing/route_names.dart';
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

  String _formatLastUpdated(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Yangilanmagan';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return 'Yangilanmagan';

    final now = DateTime.now();
    if (now.year == parsed.year &&
        now.month == parsed.month &&
        now.day == parsed.day) {
      return 'Bugun';
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day.$month.${parsed.year}';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPaymentDataForSelectedChild);
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'To\'lovlar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
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
                      color: AppColors.primaryBlue,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: BalanceHeader(
                        balance: hasFinancialData
                            ? '${state.balance?.balance ?? 0} UZS'
                            : 'Ma\'lumot yo\'q',
                        lastUpdated: _formatLastUpdated(
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
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),

                          // ─── Contract Info Card ───
                          if (child != null ||
                              state.balance?.contractNumber != null)
                            _InfoCard(
                              title: 'Shartnoma ma\'lumotlari',
                              icon: Icons.description_rounded,
                              items: [
                                if (state.balance?.contractNumber != null)
                                  {
                                    'label': 'Shartnoma',
                                    'value': state.balance!.contractNumber!,
                                  },
                                if (child != null)
                                  {
                                    'label': 'O\'quvchi',
                                    'value': child.fullName,
                                  },
                                if (child != null)
                                  {'label': 'Sinf', 'value': child.className},
                                if (hasFinancialData && state.balance != null)
                                  {
                                    'label': 'Balans',
                                    'value': state.balance!.formattedBalance,
                                  },
                                if (hasFinancialData &&
                                    (state.balance?.monthlyFee ?? 0) > 0)
                                  {
                                    'label': 'Oylik to\'lov',
                                    'value': state.balance!.formattedMonthlyFee,
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
                                        const Text(
                                          'Qarzdorlik mavjud',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Iltimos, ${Formatters.formatCurrency(debtAmount.toDouble())} UZS to\'lov qiling',
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
                            text: 'Hozir to\'lash',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Parent API da to\'lov yaratish endpointi mavjud emas. '
                                    'To\'lovlar maktab tomonidan kiritiladi.',
                                  ),
                                ),
                              );
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
                            label: const Text('To\'lovlar tarixi'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              foregroundColor: AppColors.primaryBlue,
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
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item['value']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
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
