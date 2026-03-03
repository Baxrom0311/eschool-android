import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/chat_model.dart';
import 'package:parent_school_app/data/repositories/chat_repository.dart';
import 'package:parent_school_app/presentation/providers/chat_provider.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;

  setUp(() async {
    mockRepository = MockChatRepository();
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ConversationsNotifier', () {
    final tConversations = <ConversationModel>[
      const ConversationModel(
        id: 1,
        participantName: 'Teacher A',
        lastMessage: 'Hello',
        unreadCount: 2,
        lastMessageAt: '2025-01-01',
      )
    ];

    test('initial state is correct', () {
      final container = createContainer();
      final state = container.read(conversationsProvider);
      expect(state.conversations, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('loadConversations updates state on success', () async {
      final container = createContainer();
      when(() => mockRepository.getConversations())
          .thenAnswer((_) async => Right(tConversations));

      final future = container.read(conversationsProvider.notifier).loadConversations();
      expect(container.read(conversationsProvider).isLoading, true);

      await future;

      final state = container.read(conversationsProvider);
      expect(state.isLoading, false);
      expect(state.conversations, tConversations);
      expect(state.totalUnread, 2);
    });
  });

  group('ChatRoomNotifier', () {
    const tConversationId = 1;
    final tMessagesPage1 = <MessageModel>[
      const MessageModel(
        id: 1,
        senderId: 10,
        senderName: 'Teacher A',
        content: 'Msg 1',
        createdAt: '2025-01-01',
        isMine: false,
        isRead: true,
        type: MessageType.text,
      )
    ];
    final tMessagesPage2 = <MessageModel>[
      const MessageModel(
        id: 2,
        senderId: 10,
        senderName: 'Teacher A',
        content: 'Msg 2',
        createdAt: '2025-01-01',
        isMine: false,
        isRead: true,
        type: MessageType.text,
      )
    ];

    test('openConversation updates state correctly', () async {
      final container = createContainer();
      when(() => mockRepository.getMessages(tConversationId))
          .thenAnswer((_) async => Right(tMessagesPage1));

      await container.read(chatRoomProvider.notifier).openConversation(tConversationId);

      final state = container.read(chatRoomProvider);
      expect(state.isLoading, false);
      expect(state.messages, tMessagesPage1);
      expect(state.conversationId, tConversationId);
      expect(state.currentPage, 1);
    });

    test('loadMore fetches next page and appends messages', () async {
      final container = createContainer();
      when(() => mockRepository.getMessages(tConversationId))
          .thenAnswer((_) async => Right(tMessagesPage1));
      when(() => mockRepository.getMessages(tConversationId, page: 2))
          .thenAnswer((_) async => Right(tMessagesPage2));

      await container.read(chatRoomProvider.notifier).openConversation(tConversationId);
      
      // Assume getting 1 item implies hasMore is true initially for the sake of the test, wait, 
      // the real code checks `messages.length >= 30` to set `hasMore`. Let's mock 30 messages for page 1.
      final t30Messages = List<MessageModel>.generate(30, (i) => MessageModel(
        id: i,
        senderId: 10,
        senderName: 'Teacher A',
        content: 'M$i',
        createdAt: '2025-01-01',
        isMine: false,
        isRead: true,
        type: MessageType.text,
      ));

      when(() => mockRepository.getMessages(tConversationId))
          .thenAnswer((_) async => Right(t30Messages));
          
      await container.read(chatRoomProvider.notifier).openConversation(tConversationId);
      expect(container.read(chatRoomProvider).hasMore, true);
      
      await container.read(chatRoomProvider.notifier).loadMore();

      final state = container.read(chatRoomProvider);
      expect(state.isLoading, false);
      expect(state.messages.length, 31); // 30 + 1 (page 2)
      expect(state.currentPage, 2);
    });

    test('sendMessage prepends new message on success', () async {
      final container = createContainer();
      final tNewMessage = const MessageModel(
        id: 99,
        senderId: 20,
        senderName: 'Me',
        content: 'New message',
        createdAt: '2025-01-02',
        isMine: true,
        isRead: true,
        type: MessageType.text,
      );

      when(() => mockRepository.getMessages(tConversationId))
          .thenAnswer((_) async => Right(tMessagesPage1));
      when(() => mockRepository.sendMessage(tConversationId, content: 'New message'))
          .thenAnswer((_) async => Right(tNewMessage));

      await container.read(chatRoomProvider.notifier).openConversation(tConversationId);
      final result = await container.read(chatRoomProvider.notifier).sendMessage('New message');

      expect(result, true);
      final state = container.read(chatRoomProvider);
      expect(state.isSending, false);
      expect(state.messages.length, 2);
      expect(state.messages.first, tNewMessage); 
    });
  });
}
