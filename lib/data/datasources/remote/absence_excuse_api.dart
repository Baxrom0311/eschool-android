import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/absence_model.dart';
import 'api_helpers.dart';

class AbsenceExcuseApi with ApiHelpers {
  final DioClient _client;

  AbsenceExcuseApi(this._client);

  Future<List<AbsenceExcuseModel>> getExcuses(int childId) async {
    try {
      final response = await _client.get(
        ApiConstants.absenceExcuses,
        queryParameters: {'student_id': childId},
      );
      return parseListResponse(
        response.data,
        AbsenceExcuseModel.fromJson,
        listKey: 'excuses',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<void> submitExcuse({
    required int childId,
    required String dateFrom,
    required String dateTo,
    required String reason,
    String? attachmentPath,
  }) async {
    try {
      final data = {
        'student_id': childId,
        'excuse_date': dateFrom,
        if (dateTo.isNotEmpty) 'excuse_date_to': dateTo,
        'reason': reason,
      };

      if (attachmentPath != null) {
        final formData = FormData.fromMap({
          ...data,
          'attachment': await MultipartFile.fromFile(attachmentPath),
        });
        await _client.post(
          ApiConstants.absenceExcuses,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        await _client.post(ApiConstants.absenceExcuses, data: data);
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
