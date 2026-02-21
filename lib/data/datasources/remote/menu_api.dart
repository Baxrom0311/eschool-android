import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

import '../../../core/network/dio_client.dart';
import '../../models/menu_model.dart';
import 'api_helpers.dart';

/// Menu API — kunlik va haftalik ovqat menyusi
class MenuApi with ApiHelpers {
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
      throw handleDioError(e);
    }
  }

  /// Haftalik menyu
  ///
  /// Parent OAS da haftalik endpoint yo'q, shu sabab bir hafta uchun
  /// kunlik endpoint parallel chaqiriladi.
  Future<List<MenuModel>> getWeeklyMenu({
    String? weekStart,
    int? studentId,
  }) async {
    try {
      final start = _parseDate(weekStart) ?? _startOfWeek(DateTime.now());

      final dailyRequests = List.generate(7, (i) async {
        final day = start.add(Duration(days: i));
        final date = _formatDate(day);
        try {
          final daily = await getDailyMenu(date: date, studentId: studentId);
          return MapEntry(i, daily);
        } catch (_) {
          // Bir kunlik menyu xatosi butun haftalik yuklashni to'xtatmaydi.
          return MapEntry(i, const <MenuModel>[]);
        }
      });

      final dailyResults = await Future.wait(dailyRequests);
      final indexed =
          dailyResults.where((entry) => entry.value.isNotEmpty).toList()
            ..sort((a, b) => a.key.compareTo(b.key));

      final result = <MenuModel>[];
      for (final entry in indexed) {
        result.addAll(entry.value);
      }
      return result;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  List<MenuModel> _mapMealsResponse(
    dynamic data, {
    String? dateOverride,
    int? studentId,
  }) {
    final root = asMap(data);
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
      final childPayload = asMap(entry.value);
      final report = asMap(childPayload['report']);
      if (report.isEmpty) continue;

      final reportDate = (report['meal_date'] ?? date).toString();
      final media = report['media'] is List
          ? (report['media'] as List).whereType<Map>().toList()
          : const <Map>[];
      final groupName = asMap(childPayload['group'])['name']?.toString() ?? '';

      void addMeal({
        required MealType mealType,
        required String? name,
        required String? recipe,
        required List<Map> mediaItems,
      }) {
        if (name == null || name.isEmpty) return;
        final image = mediaItems
            .map((e) => asMap(e)['file_path']?.toString())
            .whereType<String>()
            .where((e) => e.isNotEmpty)
            .cast<String?>()
            .firstWhere((_) => true, orElse: () => null);

        mapped.add(
          MenuModel.fromJson({
            'id': toInt(report['id']) * 10 + sequence++,
            'date': reportDate,
            'meal_type': _mealTypeValue(mealType),
            'dishes': [
              {
                'id': toInt(report['id']) * 100 + sequence,
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
      final row = asMap(item);
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
}
