import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/class_story_model.dart';
import 'api_helpers.dart';

class ClassStoryApi with ApiHelpers {
  final DioClient _client;

  ClassStoryApi(this._client);

  Future<List<ClassStoryModel>> getStories({int? groupId, int page = 1}) async {
    try {
      final response = await _client.get(
        '/api/stories',
        queryParameters: {
          'page': page,
          if (groupId != null) 'group_id': groupId,
        },
      );
      return parseListResponse(response.data, ClassStoryModel.fromJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMeta({int? groupId, int page = 1}) async {
    try {
      final response = await _client.get(
        '/api/stories',
        queryParameters: {
          'page': page,
          if (groupId != null) 'group_id': groupId,
        },
      );
      final data = asMap(response.data);
      return Map<String, dynamic>.from(data['meta'] ?? {});
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<bool> toggleLike(int storyId) async {
    try {
      final response = await _client.post('/api/stories/$storyId/like');
      return asMap(response.data)['liked'] == true;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<StoryComment> addComment(int storyId, String body) async {
    try {
      final response = await _client.post(
        '/api/stories/$storyId/comments',
        data: {'body': body},
      );
      final commentData = asMap(response.data)['comment'];
      return StoryComment.fromJson(Map<String, dynamic>.from(commentData ?? {}));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
