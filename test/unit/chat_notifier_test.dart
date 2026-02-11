import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/chat_provider.dart';
import 'package:parent_school_app/data/repositories/chat_repository.dart';
import 'package:parent_school_app/data/models/chat_model.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Mock ChatRepository
class MockChatRepository implements ChatRepository {
  bool shouldReturnError = false;

  @override
  Future<Either<Failure, List<ConversationModel>>> getConversations() async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Conversations load failed'));
    }
    return const Right([
      ConversationModel(id: 1, participantName: 'Teacher 1', unreadCount: 2),
      ConversationModel(id: 2, participantName: 'Teacher 2', unreadCount: 0),
    ]);
  }

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(int conversationId, {int page = 1}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Messages load failed'));
    }
    // Return 30 messages to test pagination (hasMore = true)
    return Right(List.generate(30, (index) => MessageModel(
      id: (page - 1) * 30 + index,
      content: 'Message $index',
      type: MessageType.text,
      senderId: 1,
      senderName: 'Sender',
      createdAt: '2023-10-10',
      isMine: index % 2 == 0,
    )));
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage(int conversationId, {required String content}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Send failed'));
    }
    return Right(MessageModel(
      id: 999,
      content: content,
      type: MessageType.text,
      senderId: 100, // My ID
      senderName: 'Me',
      createdAt: 'Now',
      isMine: true,
    ));
  }

  @override
  Future<Either<Failure, MessageModel>> sendFile(int conversationId, String filePath) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('File send failed'));
    }
    return const Right(MessageModel(
      id: 1000,
      type: MessageType.image,
      senderId: 100,
      senderName: 'Me',
      createdAt: 'Now',
      isMine: true,
      fileUrl: 'http://example.com/image.jpg',
    ));
  }
}

void main() {
  late MockChatRepository mockRepository;
  late ConversationsNotifier conversationsNotifier;
  late ChatRoomNotifier chatRoomNotifier;

  setUp(() {
    mockRepository = MockChatRepository();
    conversationsNotifier = ConversationsNotifier(repository: mockRepository);
    chatRoomNotifier = ChatRoomNotifier(repository: mockRepository);
  });

  group('ConversationsNotifier Tests', () {
    test('loadConversations success', () async {
      await conversationsNotifier.loadConversations();
      
      expect(conversationsNotifier.state.isLoading, false);
      expect(conversationsNotifier.state.conversations.length, 2);
      expect(conversationsNotifier.state.totalUnread, 2);
    });

    test('loadConversations failure', () async {
      mockRepository.shouldReturnError = true;
      await conversationsNotifier.loadConversations();
      
      expect(conversationsNotifier.state.isLoading, false);
      expect(conversationsNotifier.state.error, 'Conversations load failed');
    });
  });

  group('ChatRoomNotifier Tests', () {
    test('openConversation success', () async {
      await chatRoomNotifier.openConversation(1);
      
      expect(chatRoomNotifier.state.isLoading, false);
      expect(chatRoomNotifier.state.conversationId, 1);
      expect(chatRoomNotifier.state.messages.length, 30);
      expect(chatRoomNotifier.state.hasMore, true); // 30 items returned
    });

    test('loadMore success', () async {
      await chatRoomNotifier.openConversation(1); // Load page 1 (30 items)
      
      await chatRoomNotifier.loadMore(); // Load page 2 (30 items)
      
      expect(chatRoomNotifier.state.isLoading, false);
      expect(chatRoomNotifier.state.currentPage, 2);
      expect(chatRoomNotifier.state.messages.length, 60);
    });

    test('sendMessage success', () async {
      await chatRoomNotifier.openConversation(1);
      final success = await chatRoomNotifier.sendMessage('Hello');
      
      expect(success, true);
      expect(chatRoomNotifier.state.messages.first.content, 'Hello');
      expect(chatRoomNotifier.state.messages.length, 31); // 30 + 1 new
    });

    test('sendMessage failure', () async {
      await chatRoomNotifier.openConversation(1);
      mockRepository.shouldReturnError = true;
      
      final success = await chatRoomNotifier.sendMessage('Hello');
      
      expect(success, false);
      expect(chatRoomNotifier.state.error, 'Send failed');
    });

    test('sendFile success', () async {
      await chatRoomNotifier.openConversation(1);
      final success = await chatRoomNotifier.sendFile('/path/to/file.jpg');
      
      expect(success, true);
      expect(chatRoomNotifier.state.messages.first.type, MessageType.image);
    });
  });
}
