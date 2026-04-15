import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/transport_model.dart';
import 'api_helpers.dart';

class TransportApi with ApiHelpers {
  final DioClient _client;

  TransportApi(this._client);

  Future<BusRouteInfoModel> getStudentLocation(int studentId) async {
    try {
      final response = await _client.get(
        '/api/transport/location',
        queryParameters: {'student_id': studentId},
      );
      return BusRouteInfoModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
