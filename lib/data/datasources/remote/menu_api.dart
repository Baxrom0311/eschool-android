import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/menu_model.dart';

/// Menu API — kunlik va haftalik ovqat menyusi
class MenuApi {
  final DioClient _client;

  MenuApi(this._client);

  /// Kunlik menyu
  Future<List<MenuModel>> getDailyMenu({String? date, int? studentId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null && date.isNotEmpty) queryParams['date'] = date;
      if (studentId != null && studentId > 0) {
        queryParams['student_id'] = studentId;
      }

      final response = await _client.get(
        ApiConstants.dailyMenu,
        queryParameters: queryParams,
      );

      return _mapMealsResponse(
        response.data,
        dateOverride: date,
        studentId: studentId,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Haftalik menyu
  ///
  /// Parent OAS da haftalik endpoint yo'q, shu sabab bir hafta uchun
  /// kunlik endpoint ketma-ket chaqiriladi.
  Future<List<MenuModel>> getWeeklyMenu({String? weekStart, int? studentId}) async {
    try {
      final start = _parseDate(weekStart) ?? _startOfWeek(DateTime.now());
      final result = <MenuModel>[];
      for (var i = 0; i < 7; i++) {
        final day = start.add(Duration(days: i));
        final date = _formatDate(day);
        try {
          final daily = await getDailyMenu(date: date, studentId: studentId);
          result.addAll(daily);
        } catch (_) {
          // Bir kunlik menyu xatosi butun haftalik yuklashni to'xtatmaydi.
        }
      }
      return result;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  List<MenuModel> _mapMealsResponse(
    dynamic data, {
    String? dateOverride,
    int? studentId,
  }) {
    final root = _asMap(data);
    final byChild = root['meals_by_child'] is Map
        ? Map<String, dynamic>.from(root['meals_by_child'] as Map)
        : <String, dynamic>{};

    final date =
        dateOverride ??
        root['date']?.toString() ??
        DateTime.now().toIso8601String().split('T').first;
    final mapped = <MenuModel>[];

    var sequence = 1;
    var entries = byChild.entries.toList();
    if (studentId != null && studentId > 0 && entries.isNotEmpty) {
      final selected = byChild[studentId.toString()];
      if (selected != null) {
        entries = [MapEntry(studentId.toString(), selected)];
      } else {
        // Fallback: API queried by student_id, but key mismatch bo'lsa
        // birinchi child payloadni ko'rsatamiz.
        entries = [entries.first];
      }
    }

    for (final entry in entries) {
      final childPayload = _asMap(entry.value);
      final report = _asMap(childPayload['report']);
      if (report.isEmpty) continue;

      final reportDate = (report['meal_date'] ?? date).toString();
      final media = report['media'] is List
          ? (report['media'] as List).whereType<Map>().toList()
          : const <Map>[];
      final groupName = _asMap(childPayload['group'])['name']?.toString() ?? '';

      void addMeal({
        required MealType mealType,
        required String? name,
        required String? recipe,
        required List<Map> mediaItems,
      }) {
        if (name == null || name.isEmpty) return;
        final image = mediaItems
            .map((e) => _asMap(e)['file_path']?.toString())
            .whereType<String>()
            .where((e) => e.isNotEmpty)
            .cast<String?>()
            .firstWhere((_) => true, orElse: () => null);

        mapped.add(
          MenuModel.fromJson({
            'id': _toInt(report['id']) * 10 + sequence++,
            'date': reportDate,
            'meal_type': _mealTypeValue(mealType),
            'dishes': [
              {
                'id': _toInt(report['id']) * 100 + sequence,
                'name': name,
                'description': [
                  if (groupName.isNotEmpty) 'Guruh: $groupName',
                  if (recipe != null && recipe.isNotEmpty) recipe,
                ].join('\n'),
                'calories': 0,
                'image_url': image,
              },
            ],
            'total_calories': 0,
          }),
        );
      }

      final breakfastMedia = _mediaByType(media, 'breakfast');
      final lunchMedia = _mediaByType(media, 'lunch');
      final teaMedia = _mediaByType(media, 'afternoon_tea');
      final dinnerMedia = _mediaByType(media, 'dinner');

      addMeal(
        mealType: MealType.breakfast,
        name: report['breakfast_name']?.toString(),
        recipe: report['breakfast_recipe']?.toString(),
        mediaItems: breakfastMedia,
      );
      addMeal(
        mealType: MealType.lunch,
        name: report['lunch_name']?.toString(),
        recipe: report['lunch_recipe']?.toString(),
        mediaItems: lunchMedia,
      );

      final snackName = [
        report['afternoon_tea_name']?.toString(),
        report['dinner_name']?.toString(),
      ].whereType<String>().where((e) => e.isNotEmpty).join(' / ');
      final snackRecipe = [
        report['afternoon_tea_recipe']?.toString(),
        report['dinner_recipe']?.toString(),
      ].whereType<String>().where((e) => e.isNotEmpty).join('\n');
      addMeal(
        mealType: MealType.snack,
        name: snackName.isEmpty ? null : snackName,
        recipe: snackRecipe.isEmpty ? null : snackRecipe,
        mediaItems: [...teaMedia, ...dinnerMedia],
      );
    }

    return mapped;
  }

  List<Map> _mediaByType(List<Map> media, String mealType) {
    return media.where((item) {
      final row = _asMap(item);
      return row['meal_type']?.toString() == mealType;
    }).toList();
  }

  String _mealTypeValue(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.snack:
        return 'snack';
    }
  }

  DateTime _startOfWeek(DateTime date) {
    final dayOffset = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - dayOffset);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
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
