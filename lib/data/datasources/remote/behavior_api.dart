import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/behavior_model.dart';
import 'api_helpers.dart';

class BehaviorApi with ApiHelpers {
  final DioClient _client;

  BehaviorApi(this._client);

  Future<BehaviorSummaryModel> getStudentBehavior(int studentId) async {
    try {
      final response = await _client.get('/api/behavior/student/$studentId');
      return BehaviorSummaryModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return BehaviorSummaryModel();
      }
      throw handleDioError(e);
    }
  }
}
