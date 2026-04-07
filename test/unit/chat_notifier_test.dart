import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/presentation/providers/chat_provider.dart';
import 'package:parent_school_app/data/repositories/chat_repository.dart';
import 'package:parent_school_app/data/models/chat_model.dart';
import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/core/storage/outbox_service.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:mocktail/mocktail.dart';

// Mock ChatRepository
class MockChatRepository extends Mock implements ChatRepository {
  bool shouldReturnError = false;
  bool shouldReturnNetworkError = false;

  @override
  Future<List<ConversationModel>> getConversations() async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Conversations load failed');
    }
    return const [
      ConversationModel(id: 1, participantName: 'Teacher 1', unreadCount: 2),
      ConversationModel(id: 2, participantName: 'Teacher 2', unreadCount: 0),
    ];
  }

  @override
  Future<List<MessageModel>> getMessages(
    int conversationId, {
    int page = 1,
  }) async {
    if (shouldReturnError) {
      throw const ServerException(message: 'Messages load failed');
    }
    // Return 30 messages to test pagination (hasMore = true)
    return List.generate(
      30,
      (index) => MessageModel(
        id: (page - 1) * 30 + index,
        content: 'Message $index',
        type: MessageType.text,
        senderId: 1,
        senderName: 'Sender',
        createdAt: '2023-10-10',
        isMine: index % 2 == 0,
      ),
    );
  }

  @override
  Future<MessageModel> sendMessage(
    int conversationId, {
    required String content,
  }) async {
    if (shouldReturnNetworkError) {
      throw const NetworkException(message: 'No internet connection');
    }
    if (shouldReturnError) {
      throw const ServerException(message: 'Send failed');
    }
    return MessageModel(
      id: 999,
      content: content,
      type: MessageType.text,
      senderId: 100, // My ID
      senderName: 'Me',
      createdAt: 'Now',
      isMine: true,
    );
  }

  @override
  Future<MessageModel> sendFile(
    int conversationId,
    String filePath,
  ) async {
    if (shouldReturnNetworkError) {
      throw const NetworkException(message: 'No internet connection');
    }
    if (shouldReturnError) {
      throw const ServerException(message: 'File send failed');
    }
    return const MessageModel(
      id: 1000,
      type: MessageType.image,
      senderId: 100,
      senderName: 'Me',
      createdAt: 'Now',
      isMine: true,
      fileUrl: 'http://example.com/image.jpg',
    );
  }
}

class MockOutboxService extends Mock implements OutboxService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      OutboxMessage(
        id: '1',
        conversationId: 1,
        content: 'x',
        type: 'file',
        queuedAt: DateTime(2025),
      ),
    );
  });

  late MockChatRepository mockRepository;
  late MockOutboxService mockOutbox;
  late ConversationsNotifier conversationsNotifier;
  late ChatRoomNotifier chatRoomNotifier;

  const mockUser = UserModel(
    id: 1,
    fullName: 'Test User',
    phone: '998901234567',
  );

  setUp(() {
    mockRepository = MockChatRepository();
    mockOutbox = MockOutboxService();
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
    when(() => mockOutbox.queueMessage(any())).thenAnswer((_) async {});
    when(() => mockOutbox.createDummyMessage(any(), any(), any())).thenAnswer((
      invocation,
    ) {
      final outboxMessage = invocation.positionalArguments[0] as OutboxMessage;
      final senderId = invocation.positionalArguments[1] as int;
      final senderName = invocation.positionalArguments[2] as String;
      return MessageModel(
        id: -1,
        content: outboxMessage.content,
        type: outboxMessage.type == 'file'
            ? MessageType.file
            : MessageType.text,
        senderId: senderId,
        senderName: senderName,
        createdAt: outboxMessage.queuedAt.toIso8601String(),
        isMine: true,
        isRead: true,
      );
    });
    conversationsNotifier = ConversationsNotifier(repository: mockRepository);
    chatRoomNotifier = ChatRoomNotifier(
      repository: mockRepository,
      outbox: mockOutbox,
      currentUser: mockUser,
    );
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
      expect(conversationsNotifier.state.error, 'ServerException: Conversations load failed');
    });
  });

  group('ChatRoomNotifier Tests', () {
    test('openConversation success', () async {
      await chatRoomNotifier.openConversation(1);

      expect(chatRoomNotifier.state.isLoading, false);
      expect(chatRoomNotifier.state.conversationId, 1);
      expect(chatRoomNotifier.state.messages.length, 30);
      expect(chatRoomNotifier.state.hasMore, true);
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
      expect(chatRoomNotifier.state.messages.length, 31);
    });

    test('sendMessage failure', () async {
      await chatRoomNotifier.openConversation(1);
      mockRepository.shouldReturnError = true;

      final success = await chatRoomNotifier.sendMessage('Hello');

      expect(success, false);
      expect(chatRoomNotifier.state.error, 'ServerException: Send failed');
    });

    test('sendFile success', () async {
      await chatRoomNotifier.openConversation(1);
      final success = await chatRoomNotifier.sendFile('/path/to/file.jpg');

      expect(success, true);
      expect(chatRoomNotifier.state.messages.first.type, MessageType.image);
    });

    test('sendFile queues placeholder on network error', () async {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));
      await chatRoomNotifier.openConversation(1);
      mockRepository.shouldReturnNetworkError = true;

      final success = await chatRoomNotifier.sendFile('/path/to/file.jpg');

      expect(success, true);
      expect(chatRoomNotifier.state.messages.first.content, 'File attached');
      verify(() => mockOutbox.queueMessage(any())).called(1);
    });
  });
}
