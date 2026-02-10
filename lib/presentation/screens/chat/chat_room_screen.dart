import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/chat/message_bubble.dart';

/// Chat Room Screen - Direct messaging interface
///
/// Sprint 6 - Task 2
class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic>? chatData;

  const ChatRoomScreen({super.key, this.chatData});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Assalomu alaykum, Malika opa. Oylik imtihon qachon bo\'lishi aniq bo\'ldimi?',
      'time': '10:15',
      'isMe': true,
    },
    {
      'text':
          'Vaalaykum assalom. Ha, kelasi dushanba kuni 2-parada o\'tkazamiz.',
      'time': '10:20',
      'isMe': false,
    },
    {
      'text':
          'Tushunarli, rahmat! Tayyorlov materiallarini qayerdan olsak bo\'ladi?',
      'time': '10:22',
      'isMe': true,
    },
    {
      'text':
          'Men hozir "Vazifalar" bo\'limiga barcha kerakli fayllarni yuklab qo\'ydim. O\'sha yerdan ko\'rishingiz mumkin.',
      'time': '10:25',
      'isMe': false,
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _controller.text.trim(),
        'time': 'Hozir',
        'isMe': true,
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chatData ??
        {
          'name': 'Malika Qodirova',
          'isOnline': true,
        };

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
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Text(
                chat['name'][0],
                style: TextStyle(
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
                  chat['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  chat['isOnline'] ? 'Onlayn' : 'Oflayn',
                  style: TextStyle(
                    fontSize: 12,
                    color: chat['isOnline']
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
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  text: msg['text'],
                  time: msg['time'],
                  isMe: msg['isMe'],
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
                  color: Colors.black.withOpacity(0.05),
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
                    decoration: InputDecoration(
                      hintText: 'Xabar yozing...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
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
