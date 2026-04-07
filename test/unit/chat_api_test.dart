import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/datasources/remote/chat_api.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';
import 'package:parent_school_app/data/models/chat_model.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late ChatApi chatApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
    chatApi = ChatApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('ChatApi', () {
    const tConversationId = 1;

    test(
      'getConversations returns list of ConversationModel on success',
      () async {
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
              'is_online': true,
            },
          ],
        };

        when(
          () => mockDioClient.get(
            ApiConstants.conversations,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.conversations),
            data: tResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await chatApi.getConversations();

        // Assert
        expect(result.length, 1);
        final conversation = result.first;
        expect(conversation.id, 1);
        expect(conversation.participantName, 'Bekmurod Domla');
        expect(conversation.unreadCount, 2);
        expect(conversation.isOnline, true);
      },
    );

    test('getMessages returns list of MessageModel on success', () async {
      // Arrange
      final tResponse = {
        'messages': [
          {
            'id': 100,
            'body': 'Test xabar',
            'sender_id': 1,
            'receiver_id': 2,
            'sender': {'name': 'Bekmurod Domla'},
            'created_at': '2025-01-01',
            'is_read': true,
          },
        ],
      };

      when(
        () => mockDioClient.get(
          ApiConstants.messages(tConversationId),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.messages(tConversationId),
          ),
          data: tResponse,
          statusCode: 200,
        ),
      );

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

    test('falls back to localized participant and sender names', () async {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

      when(
        () => mockDioClient.get(
          ApiConstants.conversations,
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.conversations),
          data: {
            'contacts': [
              {'id': 1},
            ],
          },
          statusCode: 200,
        ),
      );

      when(
        () => mockDioClient.get(
          ApiConstants.messages(tConversationId),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.messages(tConversationId),
          ),
          data: {
            'messages': [
              {'id': 100, 'body': 'Hi', 'sender_id': 0, 'receiver_id': 1},
            ],
          },
          statusCode: 200,
        ),
      );

      final conversations = await chatApi.getConversations();
      final messages = await chatApi.getMessages(tConversationId);

      expect(conversations.single.participantName, 'User');
      expect(messages.single.senderName, 'You');
    });

    test(
      'uses created_at timestamp when backend returns zero message id',
      () async {
        const createdAt = '2025-01-01T10:30:45.123456Z';

        when(
          () => mockDioClient.get(
            ApiConstants.messages(tConversationId),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: ApiConstants.messages(tConversationId),
            ),
            data: {
              'messages': [
                {
                  'id': 0,
                  'body': 'Generated id',
                  'sender_id': 1,
                  'receiver_id': 2,
                  'created_at': createdAt,
                },
              ],
            },
            statusCode: 200,
          ),
        );

        final messages = await chatApi.getMessages(tConversationId);

        expect(
          messages.single.id,
          DateTime.parse(createdAt).microsecondsSinceEpoch.abs(),
        );
      },
    );
  });
}
