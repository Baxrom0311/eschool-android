import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/chat_api.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';
import 'package:parent_school_app/data/models/chat_model.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late ChatApi chatApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    chatApi = ChatApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('ChatApi', () {
    const tConversationId = 1;

    test('getConversations returns list of ConversationModel on success', () async {
      // Arrange
      final tResponse = {
        'contacts': [
          {
            'id': 1,
            'name': 'Bekmurod Domla',
            'role': 'teacher',
            'avatar_url': 'http://example.com/avatar.jpg',
            'last_message': 'Salom qalayzsiz?',
            'last_message_at': '2025-01-01',
            'unread_count': 2,
            'is_online': true
          }
        ]
      };

      when(() => mockDioClient.get(
            ApiConstants.conversations,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.conversations),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await chatApi.getConversations();

      // Assert
      expect(result.length, 1);
      final conversation = result.first;
      expect(conversation.id, 1);
      expect(conversation.participantName, 'Bekmurod Domla');
      expect(conversation.unreadCount, 2);
      expect(conversation.isOnline, true);
    });

    test('getMessages returns list of MessageModel on success', () async {
      // Arrange
      final tResponse = {
        'messages': [
          {
            'id': 100,
            'body': 'Test xabar',
            'sender_id': 1,
            'receiver_id': 2,
            'sender': {
              'name': 'Bekmurod Domla'
            },
            'created_at': '2025-01-01',
            'is_read': true,
          }
        ]
      };

      when(() => mockDioClient.get(
            ApiConstants.messages(tConversationId),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.messages(tConversationId)),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await chatApi.getMessages(tConversationId);

      // Assert
      expect(result.length, 1);
      final message = result.first;
      expect(message.id, 100);
      expect(message.content, 'Test xabar');
      expect(message.type, MessageType.text);
      expect(message.senderName, 'Bekmurod Domla');
      expect(message.isRead, true);
    });
  });
}
