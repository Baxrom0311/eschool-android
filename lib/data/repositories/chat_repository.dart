import '../datasources/remote/chat_api.dart';
import '../models/chat_model.dart';
import 'base_repository.dart';

/// Chat Repository — muloqot va xabarlar biznes logikasi
class ChatRepository extends BaseRepository {
  final ChatApi _chatApi;

  ChatRepository({required ChatApi chatApi}) : _chatApi = chatApi;

  /// Barcha suhbatlar ro'yxatini olish
  Future<List<ConversationModel>> getConversations() =>
      _chatApi.getConversations();

  /// Suhbatdagi xabarlarni olish (pagination bilan)
  Future<List<MessageModel>> getMessages(int conversationId, {int page = 1}) =>
      _chatApi.getMessages(conversationId, page: page);

  /// Matnli xabar yuborish
  Future<MessageModel> sendMessage(
    int conversationId, {
    required String content,
  }) => _chatApi.sendMessage(conversationId, content: content);

  /// Fayl yuborish (rasm, hujjat va h.k.)
  Future<MessageModel> sendFile(int conversationId, String filePath) =>
      _chatApi.sendFile(conversationId, filePath);
}
