import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/utils/safe_api_call.dart';
import '../datasources/remote/chat_api.dart';
import '../models/chat_model.dart';

/// Chat Repository
class ChatRepository {
  final ChatApi _chatApi;

  ChatRepository({required ChatApi chatApi}) : _chatApi = chatApi;

  Future<Either<Failure, List<ConversationModel>>> getConversations() =>
      safeApiCall(
        () => _chatApi.getConversations(),
        errorMessage: 'Suhbatlarni yuklashda xatolik',
      );

  Future<Either<Failure, List<MessageModel>>> getMessages(
    int conversationId, {
    int page = 1,
  }) =>
      safeApiCall(
        () => _chatApi.getMessages(conversationId, page: page),
        errorMessage: 'Xabarlarni yuklashda xatolik',
      );

  Future<Either<Failure, MessageModel>> sendMessage(
    int conversationId, {
    required String content,
  }) =>
      safeApiCall(
        () => _chatApi.sendMessage(conversationId, content: content),
        errorMessage: 'Xabar yuborishda xatolik',
      );

  Future<Either<Failure, MessageModel>> sendFile(
    int conversationId,
    String filePath,
  ) =>
      safeApiCall(
        () => _chatApi.sendFile(conversationId, filePath),
        errorMessage: 'Fayl yuborishda xatolik',
      );
}
