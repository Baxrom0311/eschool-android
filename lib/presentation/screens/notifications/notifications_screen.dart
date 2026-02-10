import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Notifications Screen - Grouped view of system and app notifications
///
/// Sprint 7 - Task 2
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded Mock Data inside build
    final List<Map<String, dynamic>> todayNotifications = [
      {
        'title': 'Dastur yangilandi',
        'body':
            'E-School ilovasining yangi 1.1.0 versiyasi yuklandi. Yangi imkoniyatlar bilan tanishib chiqing.',
        'time': '10:30',
        'type': 'system',
        'isRead': false,
      },
      {
        'title': 'To\'lov qabul qilindi',
        'body': 'Fevral oyi uchun oylik to\'lov muvaffaqiyatli qabul qilindi.',
        'time': '09:15',
        'type': 'payment',
        'isRead': false,
      },
    ];

    final List<Map<String, dynamic>> yesterdayNotifications = [
      {
        'title': 'Matematikadan 5 baho',
        'body':
            'Bugungi nazorat ishi uchun sizga 5 baho qo\'yildi. Baraka toping!',
        'time': 'Kecha, 16:45',
        'type': 'grade',
        'isRead': true,
      },
      {
        'title': 'Yangi vazifa: Fizika',
        'body':
            'Sardor Aliyev yangi laboratoriya ishlari bo\'yicha topshiriq yukladi.',
        'time': 'Kecha, 11:00',
        'type': 'homework',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader('Bugun'),
          ...todayNotifications.map((n) => _NotificationTile(data: n)),
          const SizedBox(height: 24),
          _buildHeader('Kecha'),
          ...yesterdayNotifications.map((n) => _NotificationTile(data: n)),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Internal Notification Tile Widget
class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _NotificationTile({required this.data});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (data['type']) {
      case 'system':
        icon = Icons.info_outline_rounded;
        color = AppColors.primaryBlue;
        break;
      case 'grade':
        icon = Icons.star_rounded;
        color = Colors.orange;
        break;
      case 'payment':
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
        break;
      case 'homework':
        icon = Icons.book_rounded;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data['isRead'] ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: data['isRead']
            ? null
            : [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            data['isRead'] ? FontWeight.w600 : FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      data['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['body'],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
