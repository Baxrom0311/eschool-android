import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/library_model.dart';
import 'api_helpers.dart';

class LibraryApi with ApiHelpers {
  final DioClient _client;

  LibraryApi(this._client);

  Future<List<LibraryBookModel>> getBooks({
    String? category,
    String? query,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.libraryBooks,
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
          if (query != null && query.isNotEmpty) 'q': query,
        },
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

  Future<List<Map<String, dynamic>>> getMyLoans() async {
    try {
      final response = await _client.get(ApiConstants.libraryMyLoans);
      final list = asMap(response.data)['loans'];
      return list is List
          ? list
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw handleDioError(e);
    }
  }

  Future<void> borrowBook(int bookId) async {
    try {
      await _client.post(ApiConstants.borrowBook(bookId));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<void> returnBook(int loanId) async {
    try {
      await _client.post(ApiConstants.returnBook(loanId));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
