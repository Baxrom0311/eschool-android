import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/gallery_model.dart';
import 'api_helpers.dart';

class GalleryApi with ApiHelpers {
  final DioClient _client;

  GalleryApi(this._client);

  Future<List<GalleryAlbumModel>> getAlbums({int? groupId}) async {
    try {
      final response = await _client.get(
        '/api/gallery/albums',
        queryParameters: {
          if (groupId != null) 'group_id': groupId,
        },
      );
      return parseListResponse(response.data, GalleryAlbumModel.fromJson, listKey: 'albums');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<List<GalleryPhotoModel>> getPhotos(int albumId) async {
    try {
      final response = await _client.get('/api/gallery/albums/$albumId/photos');
      return parseListResponse(response.data, GalleryPhotoModel.fromJson, listKey: 'photos');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }
}
