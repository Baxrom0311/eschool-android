import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/data/datasources/remote/chat_api.dart';
import 'package:parent_school_app/data/models/chat_model.dart';
import 'package:parent_school_app/data/repositories/chat_repository.dart';

class MockChatApi extends Mock implements ChatApi {}

void main() {
  late ChatRepository repository;
  late MockChatApi mockChatApi;

  setUp(() {
    mockChatApi = MockChatApi();
    repository = ChatRepository(chatApi: mockChatApi);
  });

  group('ChatRepository', () {
    const tConversationId = 1;
    final tConversationList = [
      const ConversationModel(
        id: 1,
        participantName: 'Teacher',
        unreadCount: 0,
        isOnline: true,
      )
    ];
    final tMessageList = [
      const MessageModel(
        id: 1,
        content: 'Hello',
        type: MessageType.text,
        senderId: 1,
        senderName: 'Siz',
        isMine: true,
        createdAt: '2025-01-01',
        isRead: true,
      )
    ];

    test('getConversations returns Right data on success', () async {
      // Arrange
      when(() => mockChatApi.getConversations())
          .thenAnswer((_) async => tConversationList);

      // Act
      final result = await repository.getConversations();

      // Assert
      expect(result, Right(tConversationList));
      verify(() => mockChatApi.getConversations()).called(1);
    });

    test('getConversations returns Left on ServerException', () async {
      // Arrange
      when(() => mockChatApi.getConversations())
          .thenThrow(const ServerException(message: 'Server Error'));

      // Act
      final result = await repository.getConversations();

      // Assert
      expect(result, left(const ServerFailure('Server Error')));
    });

    test('getMessages returns Right data on success', () async {
      // Arrange
      when(() => mockChatApi.getMessages(tConversationId, page: 1))
          .thenAnswer((_) async => tMessageList);

      // Act
      final result = await repository.getMessages(tConversationId, page: 1);

      // Assert
      expect(result, Right(tMessageList));
      verify(() => mockChatApi.getMessages(tConversationId, page: 1)).called(1);
    });

    test('sendMessage returns Right on success', () async {
      // Arrange
      when(() => mockChatApi.sendMessage(
            tConversationId,
            content: any(named: 'content'),
          )).thenAnswer((_) async => tMessageList.first);

      // Act
      final result = await repository.sendMessage(
        tConversationId,
        content: 'Hello',
      );

      // Assert
      expect(result, Right(tMessageList.first));
      verify(() => mockChatApi.sendMessage(
            tConversationId,
            content: 'Hello',
          )).called(1);
    });
  });
}
