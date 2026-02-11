import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/rating_model.dart';

/// Rating API — reyting jadvallari
///
/// Parent Tenant OAS da alohida rating endpoint yo'q, shu sabab farzand profili
/// va children ro'yxatidagi ma'lumotlardan derived reyting quriladi.
class RatingApi {
  final DioClient _client;

  RatingApi(this._client);

  /// Sinf bo'yicha reyting (lokal derivation)
  Future<List<RatingModel>> getClassRating(int classId) async {
    try {
      final all = await _buildChildrenRatings();
      if (classId <= 0) return _toRankedModels(all);

      final filtered = all
          .where((row) => _toInt(row['class_id']) == classId)
          .toList();
      return _toRankedModels(filtered);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Umumiy maktab reytingi (available children bo'yicha)
  Future<List<RatingModel>> getSchoolRating() async {
    try {
      final all = await _buildChildrenRatings();
      return _toRankedModels(all);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Farzand reytingi
  Future<RatingModel> getChildRating(int childId) async {
    try {
      final response = await _client.get(ApiConstants.childRating(childId));
      final root = _asMap(response.data);
      final student = root['student'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(root['student'] as Map<String, dynamic>)
          : root;

      final average = _deriveAverageGrade(root, student['average_grade']);
      final score = average * 20.0;

      return RatingModel.fromJson({
        'id': _toInt(student['id']) == 0 ? childId : _toInt(student['id']),
        'student_name': (student['name'] ?? student['full_name'] ?? 'O\'quvchi')
            .toString(),
        'rank': 1,
        'total_score': score,
        'average_grade': average,
        'avatar_url': student['avatar_url']?.toString(),
        'is_current': true,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> _buildChildrenRatings() async {
    final response = await _client.get(ApiConstants.children);
    final root = _asMap(response.data);
    final list = root['children'] is List
        ? (root['children'] as List).whereType<Map>().toList()
        : const <Map>[];

    final rows = <Map<String, dynamic>>[];
    for (final item in list) {
      final child = Map<String, dynamic>.from(item);
      final avg = _toNullableDouble(child['average_grade']) ?? 0.0;
      rows.add({
        'id': _toInt(child['id']),
        'student_name': (child['name'] ?? child['full_name'] ?? 'O\'quvchi')
            .toString(),
        'total_score': avg * 20.0,
        'average_grade': avg,
        'avatar_url': child['avatar_url']?.toString(),
        'is_current': false,
        'class_id': _toInt(child['class_id'] ?? _asMap(child['group'])['id']),
      });
    }
    return rows;
  }

  List<RatingModel> _toRankedModels(List<Map<String, dynamic>> rows) {
    final sorted = [...rows]
      ..sort(
        (a, b) => (_toNullableDouble(b['total_score']) ?? 0.0).compareTo(
          _toNullableDouble(a['total_score']) ?? 0.0,
        ),
      );

    final result = <RatingModel>[];
    for (var i = 0; i < sorted.length; i++) {
      final row = sorted[i];
      result.add(
        RatingModel.fromJson({
          'id': _toInt(row['id']),
          'student_name': row['student_name'],
          'rank': i + 1,
          'total_score': _toNullableDouble(row['total_score']) ?? 0.0,
          'average_grade': _toNullableDouble(row['average_grade']) ?? 0.0,
          'avatar_url': row['avatar_url'],
          'is_current': row['is_current'] ?? false,
        }),
      );
    }
    return result;
  }

  double _deriveAverageGrade(Map<String, dynamic> root, dynamic fallback) {
    final fallbackValue = _toNullableDouble(fallback) ?? 0.0;
    final qMap = root['qMap'];
    if (qMap is! Map) return fallbackValue;

    final grades = <double>[];
    for (final subjectValue in qMap.values) {
      if (subjectValue is! Map) continue;
      for (final quarterValue in subjectValue.values) {
        final row = _asMap(quarterValue);
        final grade = _toNullableDouble(row['grade_5']);
        if (grade != null && grade > 0) grades.add(grade);
      }
    }
    if (grades.isEmpty) return fallbackValue;
    return grades.reduce((a, b) => a + b) / grades.length;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Server xatoligi';
        if (data is Map<String, dynamic>) {
          message =
              (data['message'] as String?) ??
              (data['error'] as String?) ??
              message;
        }
        if (statusCode == 401) return AuthException(message: message);
        return ServerException(message: message, statusCode: statusCode);
      default:
        return const ServerException();
    }
  }
}
