import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/quiz_model.dart';
import 'api_helpers.dart';

class QuizApi with ApiHelpers {
  final DioClient _client;

  QuizApi(this._client);

  Future<List<QuizModel>> getStudentQuizzes() async {
    try {
      final response = await _client.get('/api/student/quizzes');
      return parseListResponse(response.data, QuizModel.fromJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<QuizAttemptStart> startQuiz(int quizId) async {
    try {
      final response = await _client.post('/api/student/quizzes/$quizId/start');
      final data = asMap(response.data);
      return QuizAttemptStart.fromJson(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<QuizSubmitResult> submitQuiz(
    int quizId,
    Map<String, dynamic> answers,
  ) async {
    try {
      final response = await _client.post(
        '/api/student/quizzes/$quizId/submit',
        data: {'answers': answers},
      );
      final data = asMap(response.data);
      return QuizSubmitResult.fromJson(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
