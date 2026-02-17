import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/shared_prefs_service.dart';
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
  int get totalUnread => conversations.fold(0, (sum, c) => sum + c.unreadCount);
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ChatRepository _repository;

  ConversationsNotifier({required ChatRepository repository})
    : _repository = repository,
      super(const ConversationsState.initial());

  Future<void> loadConversations() async {
    final cached = _readCache();
    if (cached != null) {
      state = cached.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _repository.getConversations();

    result.fold(
      (f) {
        if (cached != null) {
          state = cached.copyWith(isLoading: false, error: null);
          return;
        }
        state = state.copyWith(isLoading: false, error: f.message);
      },
      (conversations) {
        state = state.copyWith(
          conversations: conversations,
          isLoading: false,
          error: null,
        );
        unawaited(_saveCache(state));
      },
    );
  }

  ConversationsState? _readCache() {
    final raw = SharedPrefsService.getString(StorageKeys.conversationsCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final conversations = decoded
          .whereType<Map>()
          .map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ConversationsState(
        conversations: conversations,
        isLoading: false,
        error: null,
      );
    } catch (_) {
      unawaited(SharedPrefsService.remove(StorageKeys.conversationsCache));
      return null;
    }
  }

  Future<void> _saveCache(ConversationsState state) async {
    await SharedPrefsService.setString(
      StorageKeys.conversationsCache,
      jsonEncode(state.conversations.map((e) => e.toJson()).toList()),
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
    final cached = _readRoomCache(conversationId);
    if (cached != null) {
      state = cached.copyWith(
        conversationId: conversationId,
        isLoading: true,
        error: null,
      );
    } else {
      state = ChatRoomState(conversationId: conversationId, isLoading: true);
    }

    final result = await _repository.getMessages(conversationId);

    result.fold(
      (f) {
        if (cached != null) {
          state = cached.copyWith(
            conversationId: conversationId,
            isLoading: false,
            error: null,
          );
          return;
        }
        state = state.copyWith(isLoading: false, error: f.message);
      },
      (messages) {
        state = state.copyWith(
          conversationId: conversationId,
          messages: messages,
          isLoading: false,
          error: null,
          currentPage: 1,
          hasMore: messages.length >= 30,
        );
        unawaited(_saveRoomCache(state));
      },
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
        error: null,
        currentPage: nextPage,
        hasMore: newMessages.length >= 30,
      ),
    );
    if (!state.isLoading && state.error == null) {
      unawaited(_saveRoomCache(state));
    }
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
          error: null,
        );
        unawaited(_saveRoomCache(state));
        return true;
      },
    );
  }

  /// Fayl yuborish
  Future<bool> sendFile(String filePath) async {
    if (state.conversationId == null) return false;

    state = state.copyWith(isSending: true, error: null);

    final result = await _repository.sendFile(state.conversationId!, filePath);

    return result.fold(
      (f) {
        state = state.copyWith(isSending: false, error: f.message);
        return false;
      },
      (message) {
        state = state.copyWith(
          messages: [message, ...state.messages],
          isSending: false,
          error: null,
        );
        unawaited(_saveRoomCache(state));
        return true;
      },
    );
  }

  /// Suhbatni yopish
  void closeConversation() {
    state = const ChatRoomState.initial();
  }

  ChatRoomState? _readRoomCache(int conversationId) {
    final raw = SharedPrefsService.getString(_roomCacheKey(conversationId));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final messagesRaw = map['messages'];
      final messages = messagesRaw is List
          ? messagesRaw
                .whereType<Map>()
                .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const <MessageModel>[];

      return ChatRoomState(
        conversationId: conversationId,
        messages: messages,
        isLoading: false,
        isSending: false,
        error: null,
        currentPage: map['current_page'] is int
            ? map['current_page'] as int
            : 1,
        hasMore: map['has_more'] is bool
            ? map['has_more'] as bool
            : messages.length >= 30,
      );
    } catch (_) {
      unawaited(SharedPrefsService.remove(_roomCacheKey(conversationId)));
      return null;
    }
  }

  Future<void> _saveRoomCache(ChatRoomState state) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;

    await SharedPrefsService.setString(
      _roomCacheKey(conversationId),
      jsonEncode({
        'messages': state.messages.map((e) => e.toJson()).toList(),
        'current_page': state.currentPage,
        'has_more': state.hasMore,
      }),
    );
  }

  String _roomCacheKey(int conversationId) =>
      '${StorageKeys.chatMessagesCachePrefix}$conversationId';
}

final chatRoomProvider = StateNotifierProvider<ChatRoomNotifier, ChatRoomState>(
  (ref) {
    final repository = ref.watch(chatRepositoryProvider);
    return ChatRoomNotifier(repository: repository);
  },
);
