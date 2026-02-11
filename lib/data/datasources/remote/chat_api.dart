import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/chat_model.dart';
import 'api_helpers.dart';

/// Chat API — suhbatlar va xabarlar
class ChatApi with ApiHelpers {
  final DioClient _client;

  ChatApi(this._client);

  /// Suhbatlar ro'yxati
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _client.get(ApiConstants.conversations);
      final root = asMap(response.data);
      final contacts = root['contacts'] is List
          ? (root['contacts'] as List).whereType<Map>().toList()
          : const <Map>[];

      return contacts.map((raw) {
        final contact = Map<String, dynamic>.from(raw);
        return ConversationModel.fromJson({
          'id': toInt(contact['id']),
          'participant_name': (contact['name'] ?? 'Foydalanuvchi').toString(),
          'participant_role': contact['role']?.toString(),
          'participant_avatar': contact['avatar_url']?.toString(),
          'last_message': contact['last_message']?.toString(),
          'last_message_at': contact['last_message_at']?.toString(),
          'unread_count': toInt(contact['unread_count']),
          'is_online': contact['is_online'] ?? false,
        });
      }).toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// Suhbatdagi xabarlar
  Future<List<MessageModel>> getMessages(
    int conversationId, {
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      final response = await _client.get(ApiConstants.messages(conversationId));
      final root = asMap(response.data);
      final messages = root['messages'] is List
          ? (root['messages'] as List).whereType<Map>().toList()
          : const <Map>[];

      final mapped = messages.map((raw) {
        final row = Map<String, dynamic>.from(raw);
        final senderId = toInt(row['sender_id']);
        final receiverId = toInt(row['receiver_id']);
        final isMine = senderId != 0 && senderId != conversationId;
        return MessageModel.fromJson({
          'id': toInt(row['id']) == 0
              ? row.toString().hashCode.abs()
              : toInt(row['id']),
          'content': (row['body'] ?? row['content'] ?? '').toString(),
          'type': 'text',
          'sender_id': senderId,
          'sender_name': (asMap(row['sender'])['name'] ?? 'User $senderId')
              .toString(),
          'is_mine': isMine,
          'created_at': (row['created_at'] ?? DateTime.now().toIso8601String())
              .toString(),
          'is_read': row['is_read'] ?? false,
          'file_url': row['file_url']?.toString(),
          'file_name': row['file_name']?.toString(),
          'receiver_id': receiverId,
        });
      }).toList();

      mapped.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final start = ((page - 1) * perPage).clamp(0, mapped.length);
      final end = (start + perPage).clamp(0, mapped.length);
      return mapped.sublist(start, end);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// Xabar yuborish
  Future<MessageModel> sendMessage(
    int conversationId, {
    required String content,
    String type = 'text',
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.sendMessage(conversationId),
        data: {'receiver_id': conversationId, 'body': content},
      );
      final root = asMap(response.data);
      final message = root['message'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(root['message'] as Map<String, dynamic>)
          : root;

      final senderId = toInt(message['sender_id']);
      // Agar sender_id 0 bo'lsa, bu API tomondan to'ldirilmagan —
      // biz yuborgan xabar ekanligini belgilaymiz.
      final isMine = senderId == 0 || senderId != conversationId;
      return MessageModel.fromJson({
        'id': toInt(message['id']) == 0
            ? message.toString().hashCode.abs()
            : toInt(message['id']),
        'content': (message['body'] ?? message['content'] ?? content)
            .toString(),
        'type': type,
        'sender_id': senderId,
        'sender_name': (asMap(message['sender'])['name'] ?? 'User $senderId')
            .toString(),
        'is_mine': isMine,
        'created_at':
            (message['created_at'] ?? DateTime.now().toIso8601String())
                .toString(),
        'is_read': message['is_read'] ?? false,
        'file_url': message['file_url']?.toString(),
        'file_name': message['file_name']?.toString(),
      });
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// Fayl yuborish (rasm yoki hujjat)
  Future<MessageModel> sendFile(int conversationId, String filePath) async {
    throw const ServerException(
      message: 'Ushbu API versiyasida chat fayl yuborish endpointi mavjud emas',
      statusCode: 501,
    );
  }
}
