import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/conference_model.dart';
import 'api_helpers.dart';

class ConferenceApi with ApiHelpers {
  final DioClient _client;

  ConferenceApi(this._client);

  Future<List<ConferenceModel>> getAvailableSlots(int childId) async {
    try {
      final response = await _client.get(ApiConstants.conferenceAvailable);
      return parseListResponse(
        response.data,
        ConferenceModel.fromJson,
        listKey: 'slots',
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<List<ConferenceModel>> getMyBookings(int childId) async {
    try {
      final response = await _client.get(
        ApiConstants.conferenceMyBookings,
        queryParameters: {'student_id': childId},
      );
      return parseListResponse(
        response.data,
        ConferenceModel.fromJson,
        listKey: 'bookings',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<void> bookConference({
    required int childId,
    required int conferenceSlotId,
    String? note,
  }) async {
    try {
      await _client.post(
        ApiConstants.conferenceBook,
        data: {
          'student_id': childId,
          'slot_id': conferenceSlotId,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
