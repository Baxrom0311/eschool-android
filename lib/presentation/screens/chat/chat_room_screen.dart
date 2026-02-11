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

  @override
  void initState() {
    super.initState();
    if (widget.chatData != null && widget.chatData!['id'] != null) {
      Future.microtask(() {
        ref.read(chatRoomProvider.notifier).openConversation(widget.chatData!['id']);
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    ref.read(chatRoomProvider.notifier).sendMessage(_controller.text.trim());
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    // Don't close conversation here to keep state if user navigates back and forth?
    // Or do close it? Typically yes, close it.
    // ref.read(chatRoomProvider.notifier).closeConversation(); 
    // Doing this in dispose might be tricky with riverpod auto-dispose or keepAlive.
    // Let's assume manual close for now or let provider handle it.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomProvider);
    final messages = state.messages;
    
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
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
                16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
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
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12),
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
                             width: 24, height: 24, 
                             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
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
