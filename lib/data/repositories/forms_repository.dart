import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/form_model.dart';
import 'base_repository.dart';

class FormsRepository extends BaseRepository {
  final DioClient _dioClient;

  FormsRepository(this._dioClient);

  /// Get list of available published forms
  Future<List<DynamicFormModel>> getAvailableForms() async {
    return safeCallList<DynamicFormModel>(
      () => _dioClient.dio.get('/api/v1/forms'),
      (data) => DynamicFormModel.fromJson(data),
      listKey: 'forms',
    );
  }

  /// Get form details + schema + my_submission
  Future<FormDetailModel> getFormDetails(int formId) async {
    return safeCall<FormDetailModel>(
      () => _dioClient.dio.get('/api/v1/forms/$formId'),
      (data) => FormDetailModel.fromJson(data),
    );
  }

  /// Submit form answers
  Future<void> submitForm(int formId, Map<String, dynamic> answers) async {
    return safeExecute(() async {
      await _dioClient.dio.post(
        '/api/v1/forms/$formId/submit',
        data: {'answers': answers},
      );
    });
  }
}
