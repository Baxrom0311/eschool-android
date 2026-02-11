import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/notification_provider.dart';
import 'package:parent_school_app/data/datasources/remote/notification_api.dart';
import 'package:parent_school_app/data/models/notification_model.dart';
import 'package:parent_school_app/core/error/exceptions.dart';

// Mock NotificationApi (using extends because it's a class not interface, 
// strictly we should use Mockito's generate, but manual mock is faster here)
class MockNotificationApi implements NotificationApi {
  bool shouldThrowError = false;

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1, int perPage = 20}) async {
    if (shouldThrowError) {
      throw const ServerException(message: 'Load failed');
    }
    // Return 20 items to ensure hasMore is true
    return List.generate(20, (index) => NotificationModel(
      id: (page - 1) * 20 + index,
      title: 'Title $index',
      body: 'Body $index',
      type: NotificationType.general,
      createdAt: '2023-10-10',
      isRead: false,
    ));
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    if (shouldThrowError) {
      throw const ServerException(message: 'Mark read failed');
    }
  }

  @override
  Future<void> saveFcmToken(String token) async {
    if (shouldThrowError) {
      throw const ServerException(message: 'Token save failed');
    }
  }
}

void main() {
  late MockNotificationApi mockApi;
  late NotificationNotifier notificationNotifier;

  setUp(() {
    mockApi = MockNotificationApi();
    notificationNotifier = NotificationNotifier(api: mockApi);
  });

  group('NotificationNotifier Tests', () {
    test('Initial state correct', () {
      expect(notificationNotifier.state.isLoading, false);
      expect(notificationNotifier.state.notifications, isEmpty);
    });

    test('loadNotifications success', () async {
      await notificationNotifier.loadNotifications();
      
      expect(notificationNotifier.state.isLoading, false);
      expect(notificationNotifier.state.notifications.length, 20);
      expect(notificationNotifier.state.hasMore, true);
      expect(notificationNotifier.state.unreadCount, 20);
    });

    test('loadNotifications failure', () async {
      mockApi.shouldThrowError = true;
      await notificationNotifier.loadNotifications();
      
      expect(notificationNotifier.state.isLoading, false);
      expect(notificationNotifier.state.error, 'Load failed');
    });

    test('loadMore success', () async {
      await notificationNotifier.loadNotifications(); // Load page 1
      
      await notificationNotifier.loadMore(); // Load page 2
      
      expect(notificationNotifier.state.isLoading, false);
      expect(notificationNotifier.state.currentPage, 2);
      expect(notificationNotifier.state.notifications.length, 40);
    });

    test('markAsRead success', () async {
      await notificationNotifier.loadNotifications();
      final idToMark = notificationNotifier.state.notifications.first.id;
      
      await notificationNotifier.markAsRead(idToMark);
      
      expect(notificationNotifier.state.notifications.firstWhere((n) => n.id == idToMark).isRead, true);
      expect(notificationNotifier.state.unreadCount, 19);
    });

     test('markAsRead failure (silent)', () async {
      await notificationNotifier.loadNotifications();
      mockApi.shouldThrowError = true;
      final idToMark = notificationNotifier.state.notifications.first.id;
      
      await notificationNotifier.markAsRead(idToMark);
      
      // Should not change state on error (silent fail logic in provider)
      expect(notificationNotifier.state.notifications.firstWhere((n) => n.id == idToMark).isRead, false);
    });
  });
}
