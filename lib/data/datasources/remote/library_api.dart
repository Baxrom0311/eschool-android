import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/library_model.dart';
import 'api_helpers.dart';

class LibraryApi with ApiHelpers {
  final DioClient _client;

  LibraryApi(this._client);

  Future<List<LibraryBookModel>> getBooks({int? categoryId}) async {
    try {
      final response = await _client.get(
        '/api/library/books',
        queryParameters: categoryId != null ? {'category_id': categoryId} : null,
      );
      return parseListResponse(
        response.data,
        LibraryBookModel.fromJson,
        listKey: 'books',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client.get('/api/library/categories');
      final list = asMap(response.data)['categories'];
      return list is List ? List<Map<String, dynamic>>.from(list) : [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }
}
