import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/core/storage/secure_storage.dart';
import 'package:parent_school_app/presentation/providers/notification_provider.dart';
import 'package:parent_school_app/data/datasources/remote/notification_api.dart';
import 'package:parent_school_app/data/models/notification_model.dart';
import 'package:parent_school_app/core/error/exceptions.dart';

import 'package:parent_school_app/data/datasources/remote/api_helpers.dart';

class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveFcmToken(String token) async => _store['fcm_token'] = token;
  @override
  Future<String?> getFcmToken() async => _store['fcm_token'];
  @override
  Future<void> deleteFcmToken() async => _store.remove('fcm_token');
  @override
  Future<void> saveAccessToken(String token) async => _store['access_token'] = token;
  @override
  Future<String?> getAccessToken() async => _store['access_token'];
  @override
  Future<void> deleteAccessToken() async => _store.remove('access_token');
  @override
  Future<void> saveRefreshToken(String token) async => _store['refresh_token'] = token;
  @override
  Future<String?> getRefreshToken() async => _store['refresh_token'];
  @override
  Future<void> deleteRefreshToken() async => _store.remove('refresh_token');
  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _store['access_token'] = accessToken;
    _store['refresh_token'] = refreshToken;
  }
  @override
  Future<void> clearAll() async => _store.clear();
  @override
  Future<void> write(String key, String value) async => _store[key] = value;
  @override
  Future<String?> read(String key) async => _store[key];
  @override
  Future<void> delete(String key) async => _store.remove(key);
}

class MockNotificationApi with ApiHelpers implements NotificationApi {
  bool shouldThrowError = false;
  bool shouldThrowGenericError = false;

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    if (shouldThrowGenericError) {
      throw '';
    }
    if (shouldThrowError) {
      throw const ServerException(message: 'Load failed');
    }
    // Return 20 items to ensure hasMore is true
    return List.generate(
      20,
      (index) => NotificationModel(
        id: '${(page - 1) * 20 + index}',
        title: 'Title $index',
        body: 'Body $index',
        type: NotificationType.general,
        createdAt: '2023-10-10',
        isRead: false,
      ),
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
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
  late MockSecureStorageService mockStorage;
  late NotificationNotifier notificationNotifier;

  setUp(() {
    mockApi = MockNotificationApi();
    mockStorage = MockSecureStorageService();
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
    notificationNotifier = NotificationNotifier(api: mockApi, secureStorage: mockStorage);
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

    test(
      'loadNotifications uses localized fallback for generic errors',
      () async {
        AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));
        mockApi.shouldThrowGenericError = true;

        await notificationNotifier.loadNotifications();

        expect(notificationNotifier.state.isLoading, false);
        expect(
          notificationNotifier.state.error,
          'Failed to load notifications',
        );
      },
    );

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

      expect(
        notificationNotifier.state.notifications
            .firstWhere((n) => n.id == idToMark)
            .isRead,
        true,
      );
      expect(notificationNotifier.state.unreadCount, 19);
    });

    test('markAsRead failure (silent)', () async {
      await notificationNotifier.loadNotifications();
      mockApi.shouldThrowError = true;
      final idToMark = notificationNotifier.state.notifications.first.id;

      await notificationNotifier.markAsRead(idToMark);

      // Should not change state on error (silent fail logic in provider)
      expect(
        notificationNotifier.state.notifications
            .firstWhere((n) => n.id == idToMark)
            .isRead,
        false,
      );
    });
  });
}
