import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/chat_api.dart';
import '../../data/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'auth_provider.dart';

// ─── Dependency Providers ───

final chatApiProvider = Provider<ChatApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatApi(dioClient);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final api = ref.watch(chatApiProvider);
  return ChatRepository(chatApi: api);
});

// ═══════════════════════════════════════════════════════════════
// CONVERSATIONS STATE (chat ro'yxati)
// ═══════════════════════════════════════════════════════════════

class ConversationsState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  const ConversationsState.initial()
      : conversations = const [],
        isLoading = false,
        error = null;

  ConversationsState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Jami o'qilmagan xabarlar soni
  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ChatRepository _repository;

  ConversationsNotifier({required ChatRepository repository})
      : _repository = repository,
        super(const ConversationsState.initial());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getConversations();

    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (conversations) => state = state.copyWith(
        conversations: conversations,
        isLoading: false,
      ),
    );
  }
}

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ConversationsNotifier(repository: repository);
});

// ═══════════════════════════════════════════════════════════════
// CHAT ROOM STATE (bitta suhbat ichidagi xabarlar)
// ═══════════════════════════════════════════════════════════════

class ChatRoomState {
  final int? conversationId;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const ChatRoomState({
    this.conversationId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  const ChatRoomState.initial()
      : conversationId = null,
        messages = const [],
        isLoading = false,
        isSending = false,
        error = null,
        currentPage = 1,
        hasMore = true;

  ChatRoomState copyWith({
    int? conversationId,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return ChatRoomState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  final ChatRepository _repository;

  ChatRoomNotifier({required ChatRepository repository})
      : _repository = repository,
        super(const ChatRoomState.initial());

  /// Suhbatni ochish va xabarlarni yuklash
  Future<void> openConversation(int conversationId) async {
    state = ChatRoomState(
      conversationId: conversationId,
      isLoading: true,
    );

    final result = await _repository.getMessages(conversationId);

    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (messages) => state = state.copyWith(
        messages: messages,
        isLoading: false,
        hasMore: messages.length >= 30,
      ),
    );
  }

  /// Eski xabarlarni yuklash (scroll up)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.conversationId == null) {
      return;
    }

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.getMessages(
      state.conversationId!,
      page: nextPage,
    );

    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (newMessages) => state = state.copyWith(
        messages: [...state.messages, ...newMessages],
        isLoading: false,
        currentPage: nextPage,
        hasMore: newMessages.length >= 30,
      ),
    );
  }

  /// Matn xabari yuborish
  Future<bool> sendMessage(String content) async {
    if (state.conversationId == null) return false;

    state = state.copyWith(isSending: true, error: null);

    final result = await _repository.sendMessage(
      state.conversationId!,
      content: content,
    );

    return result.fold(
      (f) {
        state = state.copyWith(isSending: false, error: f.message);
        return false;
      },
      (message) {
        state = state.copyWith(
          messages: [message, ...state.messages],
          isSending: false,
        );
        return true;
      },
    );
  }

  /// Fayl yuborish
  Future<bool> sendFile(String filePath) async {
    if (state.conversationId == null) return false;

    state = state.copyWith(isSending: true, error: null);

    final result = await _repository.sendFile(
      state.conversationId!,
      filePath,
    );

    return result.fold(
      (f) {
        state = state.copyWith(isSending: false, error: f.message);
        return false;
      },
      (message) {
        state = state.copyWith(
          messages: [message, ...state.messages],
          isSending: false,
        );
        return true;
      },
    );
  }

  /// Suhbatni yopish
  void closeConversation() {
    state = const ChatRoomState.initial();
  }
}

final chatRoomProvider =
    StateNotifierProvider<ChatRoomNotifier, ChatRoomState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatRoomNotifier(repository: repository);
});
