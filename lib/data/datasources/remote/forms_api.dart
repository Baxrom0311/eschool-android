import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/form_model.dart';
import 'api_helpers.dart';

class FormsApi with ApiHelpers {
  final DioClient _client;

  FormsApi(this._client);

  Future<List<DynamicFormModel>> getForms() async {
    try {
      final response = await _client.get('/api/forms');
      final data = response.data;
      final list = data is Map
          ? (data['forms'] ?? data['data'] ?? []) as List
          : (data is List ? data : []);
      return list
          .map((e) => DynamicFormModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<FormDetailModel> getFormDetail(int formId) async {
    try {
      final response = await _client.get('/api/forms/$formId');
      return FormDetailModel.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> submitForm(int formId, List<String> answers) async {
    try {
      await _client.post(
        '/api/forms/$formId/submit',
        data: {'answers': answers},
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
