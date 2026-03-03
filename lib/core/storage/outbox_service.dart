import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/chat_model.dart';
import '../../data/repositories/chat_repository.dart';

final outboxServiceProvider = Provider<OutboxService>((ref) {
  return OutboxService();
});

class OutboxMessage {
  final String id;
  final int conversationId;
  final String content;
  final String type; // 'text' or 'file'
  final String? filePath;
  final DateTime queuedAt;

  OutboxMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.type,
    this.filePath,
    required this.queuedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'content': content,
        'type': type,
        'filePath': filePath,
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory OutboxMessage.fromJson(Map<String, dynamic> json) => OutboxMessage(
        id: json['id'] as String,
        conversationId: json['conversationId'] as int,
        content: json['content'] as String,
        type: json['type'] as String,
        filePath: json['filePath'] as String?,
        queuedAt: DateTime.parse(json['queuedAt'] as String),
      );
}

class OutboxService {
  static const String _boxName = 'chat_outbox_box';
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Future<void> queueMessage(OutboxMessage message) async {
    if (_box == null) await init();
    try {
      final jsonString = jsonEncode(message.toJson());
      await _box!.put(message.id, jsonString);
    } catch (_) {}
  }

  Future<List<OutboxMessage>> getQueuedMessages() async {
    if (_box == null) await init();
    try {
      final List<OutboxMessage> messages = [];
      for (final key in _box!.keys) {
        final jsonString = _box!.get(key) as String?;
        if (jsonString != null) {
          final map = jsonDecode(jsonString) as Map<String, dynamic>;
          messages.add(OutboxMessage.fromJson(map));
        }
      }
      return messages..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> removeMessage(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  Future<void> flushOutbox(ChatRepository repository) async {
    final messages = await getQueuedMessages();
    for (final message in messages) {
      bool success = false;
      if (message.type == 'text') {
        final res = await repository.sendMessage(
          message.conversationId,
          content: message.content,
        );
        success = res.isRight();
      } else if (message.type == 'file' && message.filePath != null) {
        final res = await repository.sendFile(
          message.conversationId,
          message.filePath!,
        );
        success = res.isRight();
      }

      if (success) {
        await removeMessage(message.id);
      }
    }
  }

  MessageModel createDummyMessage(OutboxMessage outboxMessage, int senderId, String senderName) {
    return MessageModel(
      id: -DateTime.now().millisecondsSinceEpoch, // Negative ID implies local/offline
      content: outboxMessage.content,
      type: outboxMessage.type == 'text' ? MessageType.text : MessageType.file,
      senderId: senderId,
      senderName: senderName,
      createdAt: outboxMessage.queuedAt.toIso8601String(),
      isMine: true,
      isRead: true, // Optimistically read
    );
  }
}
