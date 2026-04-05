import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/badge_model.dart';
import 'api_helpers.dart';

class LeaderboardApi with ApiHelpers {
  final DioClient _client;

  LeaderboardApi(this._client);

  Future<int> getCoins(int childId) async {
    try {
      final response = await _client.get(
        ApiConstants.leaderboardCoins,
        queryParameters: {'student_id': childId},
      );
      final data = asMap(response.data);
      return toInt(data['coins']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return 0;
      throw handleDioError(e);
    }
  }

  Future<List<BadgeModel>> getBadges({int? childId}) async {
    try {
      final response = await _client.get(
        ApiConstants.leaderboardBadges,
        queryParameters: childId != null ? {'student_id': childId} : {},
      );
      return parseListResponse(
        response.data,
        BadgeModel.fromJson,
        listKey: 'badges',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<List<BadgeModel>> getMyBadges(int childId) async {
    try {
      final response = await _client.get(
        ApiConstants.leaderboardMyBadges,
        queryParameters: {'student_id': childId},
      );
      return parseListResponse(
        response.data,
        BadgeModel.fromJson,
        listKey: 'badges',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }
}
