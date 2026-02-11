import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/notification_api.dart';
import '../../data/models/notification_model.dart';
import '../../core/error/exceptions.dart';
import 'auth_provider.dart';

// ─── Dependency Providers ───

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationApi(dioClient);
});

// ─── Notification State ───

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  const NotificationState.initial()
      : notifications = const [],
        isLoading = false,
        error = null,
        currentPage = 1,
        hasMore = true;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// O'qilmagan bildirishnomalar soni
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationApi _api;

  NotificationNotifier({required NotificationApi api})
      : _api = api,
        super(const NotificationState.initial());

  /// Bildirishnomalarni yuklash
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notifications = await _api.getNotifications();
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        hasMore: notifications.length >= 20,
      );
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Xatolik: ${e.toString()}',
      );
    }
  }

  /// Keyingi sahifa
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    try {
      final newNotifications = await _api.getNotifications(page: nextPage);
      state = state.copyWith(
        notifications: [...state.notifications, ...newNotifications],
        isLoading: false,
        currentPage: nextPage,
        hasMore: newNotifications.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Xatolik: ${e.toString()}',
      );
    }
  }

  /// O'qilgan deb belgilash
  Future<void> markAsRead(int notificationId) async {
    try {
      await _api.markAsRead(notificationId);
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              isRead: true,
              data: n.data,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
      );
    } catch (_) {
      // Silent fail — UI da ko'rsatmaslik
    }
  }

  /// FCM tokenni saqlash
  Future<void> saveFcmToken(String token) async {
    try {
      await _api.saveFcmToken(token);
    } catch (_) {
      // Silent fail
    }
  }

  Future<void> refresh() async {
    state = const NotificationState.initial();
    await loadNotifications();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final api = ref.watch(notificationApiProvider);
  return NotificationNotifier(api: api);
});
