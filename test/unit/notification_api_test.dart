import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/notification_api.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late NotificationApi notificationApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    notificationApi = NotificationApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('NotificationApi', () {
    const tNotificationId = 123;
    const tToken = 'fcm_token_123';

    test('getNotifications returns list of NotificationModel on success', () async {
      // Arrange
      final tResponse = {
        'notifications': [
          {
            'id': 1,
            'title': 'Test title',
            'body': 'Test message',
            'type': 'general',
            'created_at': '2025-01-01',
            'is_read': false,
          }
        ]
      };

      when(() => mockDioClient.get(
            ApiConstants.notifications,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.notifications),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await notificationApi.getNotifications();

      // Assert
      expect(result.length, 1);
      final notification = result.first;
      expect(notification.id, 1);
      expect(notification.title, 'Test title');
      expect(notification.isRead, false);
    });

    test('markAsRead executes successfully', () async {
      // Arrange
      when(() => mockDioClient.post(
            ApiConstants.markAsRead(tNotificationId),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.markAsRead(tNotificationId)),
            statusCode: 200,
          ));

      // Act
      await notificationApi.markAsRead(tNotificationId);

      // Assert
      verify(() => mockDioClient.post(ApiConstants.markAsRead(tNotificationId))).called(1);
    });

    test('saveFcmToken executes successfully', () async {
      // Arrange
      when(() => mockDioClient.post(
            ApiConstants.saveFcmToken,
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.saveFcmToken),
            statusCode: 200,
          ));

      // Act
      await notificationApi.saveFcmToken(tToken);

      // Assert
      verify(() => mockDioClient.post(
            ApiConstants.saveFcmToken,
            data: {'token': tToken, 'fcm_token': tToken, 'device_type': 'android'},
          )).called(1);
    });
  });
}
