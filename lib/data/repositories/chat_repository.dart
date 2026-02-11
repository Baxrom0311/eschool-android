import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../datasources/remote/chat_api.dart';
import '../models/chat_model.dart';

/// Chat Repository
class ChatRepository {
  final ChatApi _chatApi;

  ChatRepository({required ChatApi chatApi}) : _chatApi = chatApi;

  Future<Either<Failure, List<ConversationModel>>> getConversations() async {
    try {
      final conversations = await _chatApi.getConversations();
      return Right(conversations);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Suhbatlarni yuklashda xatolik: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<MessageModel>>> getMessages(
    int conversationId, {
    int page = 1,
  }) async {
    try {
      final messages = await _chatApi.getMessages(
        conversationId,
        page: page,
      );
      return Right(messages);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Xabarlarni yuklashda xatolik: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, MessageModel>> sendMessage(
    int conversationId, {
    required String content,
  }) async {
    try {
      final message = await _chatApi.sendMessage(
        conversationId,
        content: content,
      );
      return Right(message);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Xabar yuborishda xatolik: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, MessageModel>> sendFile(
    int conversationId,
    String filePath,
  ) async {
    try {
      final message = await _chatApi.sendFile(conversationId, filePath);
      return Right(message);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Fayl yuborishda xatolik: ${e.toString()}'));
    }
  }
}
