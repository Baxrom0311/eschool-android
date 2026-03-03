import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/datasources/remote/notification_api.dart';
import 'package:parent_school_app/data/models/notification_model.dart';
import 'package:parent_school_app/presentation/providers/notification_provider.dart';

class MockNotificationApi extends Mock implements NotificationApi {}

void main() {
  late MockNotificationApi mockApi;

  setUp(() async {
    mockApi = MockNotificationApi();
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        notificationApiProvider.overrideWithValue(mockApi),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('NotificationNotifier', () {
    final tNotificationsPage1 = <NotificationModel>[
      const NotificationModel(
        id: 1,
        title: 'Title 1',
        body: 'Body 1',
        type: NotificationType.general,
        isRead: false,
        createdAt: '2025-01-01',
      ),
      const NotificationModel(
        id: 2,
        title: 'Title 2',
        body: 'Body 2',
        type: NotificationType.announcement,
        isRead: true,
        createdAt: '2025-01-01',
      ),
    ];
    
    final tNotificationsPage2 = <NotificationModel>[
      const NotificationModel(
        id: 3,
        title: 'Title 3',
        body: 'Body 3',
        type: NotificationType.grade,
        isRead: false,
        createdAt: '2025-01-01',
      ),
    ];

    test('initial state is correct', () {
      final container = createContainer();
      final state = container.read(notificationProvider);
      expect(state.isLoading, false);
      expect(state.notifications, isEmpty);
      expect(state.error, isNull);
      expect(state.hasMore, true);
    });

    test('loadNotifications updates state with new notifications', () async {
      final container = createContainer();
      when(() => mockApi.getNotifications())
          .thenAnswer((_) async => tNotificationsPage1);

      final future = container.read(notificationProvider.notifier).loadNotifications();
      expect(container.read(notificationProvider).isLoading, true);

      await future;

      final state = container.read(notificationProvider);
      expect(state.isLoading, false);
      expect(state.notifications, tNotificationsPage1);
      expect(state.unreadCount, 1);
    });

    test('loadMore fetches next page and appends to state', () async {
      final container = createContainer();
      
      // Simulate 20 items to guarantee hasMore = true
      final t20Notifications = List<NotificationModel>.generate(20, (i) => NotificationModel(
        id: i,
        title: 'Title $i',
        body: 'Body $i',
        type: NotificationType.general,
        isRead: false,
        createdAt: '2025-01-01',
      ));

      when(() => mockApi.getNotifications())
          .thenAnswer((_) async => t20Notifications);
      when(() => mockApi.getNotifications(page: 2))
          .thenAnswer((_) async => tNotificationsPage2);

      await container.read(notificationProvider.notifier).loadNotifications();
      expect(container.read(notificationProvider).hasMore, true);

      await container.read(notificationProvider.notifier).loadMore();

      final state = container.read(notificationProvider);
      expect(state.isLoading, false);
      expect(state.notifications.length, 21);
      expect(state.currentPage, 2);
    });

    test('markAsRead optimistically updates notification to isRead=true', () async {
      final container = createContainer();
      when(() => mockApi.getNotifications())
          .thenAnswer((_) async => tNotificationsPage1);
      when(() => mockApi.markAsRead(1))
          .thenAnswer((_) async => {});

      await container.read(notificationProvider.notifier).loadNotifications();
      
      var state = container.read(notificationProvider);
      expect(state.unreadCount, 1);
      expect(state.notifications.first.isRead, false);

      await container.read(notificationProvider.notifier).markAsRead(1);

      state = container.read(notificationProvider);
      expect(state.unreadCount, 0); // Both are now read
      expect(state.notifications.first.isRead, true);
      verify(() => mockApi.markAsRead(1)).called(1);
    });
  });
}
