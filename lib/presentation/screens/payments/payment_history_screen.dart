import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Payment History Screen - List of past transactions
///
/// Sprint 3 - Task 2
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for transactions
    final List<Map<String, dynamic>> transactions = [
      {
        'title': 'Oylik to\'lov (Yanvar)',
        'amount': '1,200,000 UZS',
        'date': '05.01.2024, 10:15',
        'status': 'success',
        'method': 'Click',
      },
      {
        'title': 'Oylik to\'lov (Dekabr)',
        'amount': '1,200,000 UZS',
        'date': '02.12.2023, 14:22',
        'status': 'success',
        'method': 'PayMe',
      },
      {
        'title': 'Tushlik uchun',
        'amount': '50,000 UZS',
        'date': '28.11.2023, 11:05',
        'status': 'failed',
        'method': 'Click',
      },
      {
        'title': 'Oylik to\'lov (Noyabr)',
        'amount': '1,200,000 UZS',
        'date': '03.11.2023, 09:45',
        'status': 'success',
        'method': 'Visa',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('To\'lovlar tarixi'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(label: 'Hammasi', isActive: true),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Muvaffaqiyatli', isActive: false),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Rad etilgan', isActive: false),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Kutilmoqda', isActive: false),
                ],
              ),
            ),
          ),

          // Search / Period Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Oxirgi 3 oy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_month_rounded,
                    color: AppColors.primaryBlue, size: 20),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isSuccess = tx['status'] == 'success';

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
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.danger.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_rounded : Icons.close_rounded,
                        color: isSuccess ? AppColors.success : AppColors.danger,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      tx['title'],
                      style: TextStyle(
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
                          tx['date'],
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              tx['method'],
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '• ${isSuccess ? "Muvaffaqiyatli" : "Xatolik"}',
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
                      tx['amount'],
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
