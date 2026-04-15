import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/ai_insight_model.dart';
import 'base_repository.dart';

class AiInsightRepository extends BaseRepository {
  final DioClient _dioClient;

  AiInsightRepository(this._dioClient);

  /// Fetch AI recommendations and risk predictions for a specific student.
  Future<AiInsightModel> getStudentInsights(int studentId) async {
    return safeCall<AiInsightModel>(
      () => _dioClient.dio.get('/api/v1/ai/student-insights/$studentId'),
      (data) {
        // Backend returns: {"student_name": "...", "insights": { ... }}
        final insightsJson = data['insights'] ?? {};
        return AiInsightModel.fromJson(insightsJson);
      },
    );
  }
}
