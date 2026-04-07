import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/localization/app_localizations.dart';
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
        errorMessage: AppLocalizations.current.conversationsLoadFailed,
      );

  Future<Either<Failure, List<MessageModel>>> getMessages(
    int conversationId, {
    int page = 1,
  }) => safeApiCall(
    () => _chatApi.getMessages(conversationId, page: page),
    errorMessage: AppLocalizations.current.messagesLoadFailed,
  );

  Future<Either<Failure, MessageModel>> sendMessage(
    int conversationId, {
    required String content,
  }) => safeApiCall(
    () => _chatApi.sendMessage(conversationId, content: content),
    errorMessage: AppLocalizations.current.chatMessageSendFailed,
  );

  Future<Either<Failure, MessageModel>> sendFile(
    int conversationId,
    String filePath,
  ) => safeApiCall(
    () => _chatApi.sendFile(conversationId, filePath),
    errorMessage: AppLocalizations.current.chatFileSendFailed,
  );
}
