import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Chat List Screen - List of all message threads
///
/// Sprint 6 - Task 1
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for chats
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'Malika Qodirova',
        'role': 'Ona tili o\'qituvchisi',
        'lastMessage': 'Ertaga majlis bo\'ladi, qatnashishingizni so\'raymiz.',
        'time': '14:30',
        'unreadCount': 2,
        'isOnline': true,
      },
      {
        'name': 'Azizova Gulnora',
        'role': 'Ingliz tili o\'qituvchisi',
        'lastMessage': 'Vazifani qabul qildim, rahmat.',
        'time': 'Bugun',
        'unreadCount': 0,
        'isOnline': false,
      },
      {
        'name': 'Sardor Aliyev',
        'role': 'Fizika o\'qituvchisi',
        'lastMessage': 'Yangi laboratoriya ishi yuklandi.',
        'time': 'Kecha',
        'unreadCount': 0,
        'isOnline': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chatlar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 88),
          child: Divider(height: 1, color: AppColors.border),
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            onTap: () {
              context.push(RouteNames.chatRoom, extra: chat);
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text(
                    chat['name'][0],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                if (chat['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chat['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  chat['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chat['lastMessage'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: chat['unreadCount'] > 0
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: chat['unreadCount'] > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (chat['unreadCount'] > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        chat['unreadCount'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
