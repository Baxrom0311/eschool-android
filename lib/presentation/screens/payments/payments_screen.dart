import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../widgets/payments/balance_header.dart';
import '../../widgets/common/custom_button.dart';

/// Payments Screen - Main view for billing and payments
///
/// Sprint 3 - Task 1
/// Dev1 Responsibility
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Header Section ───
            Container(
              color: AppColors.primaryBlue,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: const BalanceHeader(
                balance: '450,000 UZS',
                lastUpdated: 'Bugun, 14:30',
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Contract Info Card ───
                  _InfoCard(
                    title: 'Shartnoma ma\'lumotlari',
                    icon: Icons.description_rounded,
                    items: const [
                      {'label': 'Shartnoma №', 'value': 'EDU-2024-452'},
                      {'label': 'O\'quvchi', 'value': 'Azizbek Rahimov'},
                      {'label': 'Sinf', 'value': '8-A sinf'},
                      {'label': 'Oylik to\'lov', 'value': '1,200,000 UZS'},
                      {'label': 'To\'langan', 'value': '750,000 UZS'},
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Payment Status ───
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0), // Light Orange
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qarzdorlik mavjud',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Fevral oyi uchun 450,000 UZS to\'lov kutilmoqda',
                                style: TextStyle(
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
                    label: const Text('To\'lovlar tarixi'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side:
                          BorderSide(color: AppColors.primaryBlue, width: 1.5),
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
                  style: TextStyle(
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
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        item['value']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
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
