import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';

/// Assignment Detail Screen - Detailed view of a homework assignment
///
/// Sprint 5 - Task 2
class AssignmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? assignment;

  const AssignmentDetailScreen({
    super.key,
    this.assignment,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback data if assignment is null
    final data = assignment ??
        {
          'subject': 'Matematika',
          'title': '15-20 mashqlar',
          'description':
              'Kvadrat tenglamalar mavzusidan barcha mashqlarni yechish. Har bir yechimni to\'liq yozish va chizmalar bilan ko\'rsatish shart.',
          'deadline': 'Ertaga 18:00 gacha',
          'color': const Color(0xFF4CAF50),
        };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vazifa tafsilotlari'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Top Info Card ───
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (data['color'] as Color).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: data['color'],
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['subject'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: data['color'],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['title'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          children: [
                            Icon(Icons.event_note_rounded,
                                color: AppColors.danger, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Muddat:',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data['deadline'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Description Section ───
                  Text(
                    'Topshiriq mazmuni',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      data['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Attachments Section ───
                  Text(
                    'Biriktirilgan fayllar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Color(0xFFC62828),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'algebra_vazifa.pdf',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '1.2 MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.file_download_outlined),
                          color: AppColors.primaryBlue,
                          onPressed: () {
                            // TODO: Download file
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Action Bottom Button ───
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: CustomButton(
              text: 'Vazifani yuklash',
              onPressed: () {
                // TODO: Upload assignment logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fayl tanlash oynasi ochiladi...')),
                );
              },
              height: 56,
              borderRadius: 16,
              icon: Icons.cloud_upload_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
