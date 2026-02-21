import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/chat/message_bubble.dart';

/// Chat Room Screen - Direct messaging interface
///
/// Sprint 6 - Task 2
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../../core/utils/formatters.dart';

/// Chat Room Screen - Direct messaging interface
class ChatRoomScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? chatData;

  const ChatRoomScreen({super.key, this.chatData});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const double _paginationThreshold = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    if (widget.chatData != null && widget.chatData!['id'] != null) {
      Future.microtask(() {
        ref
            .read(chatRoomProvider.notifier)
            .openConversation(widget.chatData!['id']);
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= (position.maxScrollExtent - _paginationThreshold)) {
      ref.read(chatRoomProvider.notifier).loadMore();
    }
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final success = await ref
        .read(chatRoomProvider.notifier)
        .sendMessage(content);
    if (!mounted) return;

    if (success) {
      _controller.clear();
      return;
    }

    final error = ref.read(chatRoomProvider).error;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Xabar yuborilmadi')));
  }

  @override
  void dispose() {
    ref.read(chatRoomProvider.notifier).closeConversation();
    _scrollController.removeListener(_handleScroll);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomProvider);
    final messages = state.messages;
    final showTopLoader = state.isLoading && messages.isNotEmpty;

    final chatName = widget.chatData?['name'] ?? 'Chat';
    final isOnline = widget.chatData?['isOnline'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Text(
                chatName.isNotEmpty ? chatName[0] : '?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isOnline ? 'Onlayn' : 'Oflayn',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Messages usually start from bottom
                    padding: const EdgeInsets.all(20),
                    itemCount: messages.length + (showTopLoader ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (showTopLoader && index == messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final msg = messages[index];
                      return MessageBubble(
                        text: msg.content ?? '',
                        time: Formatters.formatTime(msg.timestamp),
                        isMe: msg.isMe,
                      );
                    },
                  ),
          ),

          // ─── Input Area ───
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.attach_file_rounded),
                    color: AppColors.textSecondary,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Xabar yozing...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: state.isSending
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send_rounded),
                          color: Colors.white,
                          onPressed: _sendMessage,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
