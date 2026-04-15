import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/event_model.dart';
import 'api_helpers.dart';

class EventApi with ApiHelpers {
  final DioClient _client;

  EventApi(this._client);

  Future<List<SchoolEventModel>> getEvents({String? type}) async {
    try {
      final response = await _client.get(
        '/api/events',
        queryParameters: {
          if (type != null && type.isNotEmpty) 'type': type,
        },
      );
      return parseListResponse(response.data, SchoolEventModel.fromJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }
}
