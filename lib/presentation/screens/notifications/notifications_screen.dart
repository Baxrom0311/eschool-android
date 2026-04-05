import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/app_state_view.dart';

/// Notifications Screen - Shows list of notifications
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Bildirishnomalar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
        child: AppStateView(
          isLoading: state.isLoading && state.notifications.isEmpty,
          errorMessage: state.notifications.isEmpty ? state.error : null,
          isEmpty: state.notifications.isEmpty && !state.isLoading,
          emptyMessage: 'Bildirishnomalar yo\'q',
          onRetry: () =>
              ref.read(notificationProvider.notifier).loadNotifications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return _NotificationTile(data: notification);
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel data;

  const _NotificationTile({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IconData icon;
    Color color;

    switch (data.type) {
      case NotificationType.payment:
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
        break;
      case NotificationType.grade:
        icon = Icons.star_rounded;
        color = Colors.orange;
        break;
      case NotificationType.attendance:
        icon = Icons.event_available_rounded;
        color = Colors.blue;
        break;
      case NotificationType.assignment:
        icon = Icons.book_rounded;
        color = Colors.purple;
        break;
      case NotificationType.announcement:
        icon = Icons.campaign_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: data.isRead ? Colors.white.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: data.isRead
            ? null
            : [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _handleTap(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
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
                          Expanded(
                            child: Text(
                              data.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: data.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(data.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.body,
                        style: const TextStyle(
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
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.tryParse(dateString);
      if (date == null) {
        return dateString; // Fallback to raw string if parse fails
      }

      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return Formatters.formatTime(date);
      }
      return Formatters.formatDate(date);
    } catch (_) {
      return dateString;
    }
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (!data.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(data.id);
    }

    switch (data.type) {
      case NotificationType.payment:
        context.push(RouteNames.payments);
        return;
      case NotificationType.grade:
        context.push(RouteNames.grades);
        return;
      case NotificationType.attendance:
        context.push(RouteNames.attendance);
        return;
      case NotificationType.assignment:
        context.push(RouteNames.assignments);
        return;
      case NotificationType.chat:
        final chatExtra = _chatRouteExtra(data.data);
        if (chatExtra != null) {
          context.push(RouteNames.chatRoom, extra: chatExtra);
        } else {
          context.push(RouteNames.chatList);
        }
        return;
      case NotificationType.announcement:
      case NotificationType.general:
        return;
    }
  }

  Map<String, dynamic>? _chatRouteExtra(Map<String, dynamic>? payload) {
    if (payload == null) return null;

    final rawId =
        payload['conversation_id'] ?? payload['user_id'] ?? payload['id'];
    final chatId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    if (chatId == null) return null;

    return {
      'id': chatId,
      'name':
          payload['name']?.toString() ??
          payload['participant_name']?.toString() ??
          payload['title']?.toString() ??
          'Chat',
      'isOnline': false,
      'role':
          payload['role']?.toString() ??
          payload['participant_role']?.toString(),
    };
  }
}
