import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/menu_api.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';
import 'package:parent_school_app/data/models/menu_model.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MenuApi menuApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    menuApi = MenuApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('MenuApi', () {
    const tStudentId = 1;
    const tDate = '2025-01-01';

    test('getDailyMenu parses meals_by_child properly', () async {
      // Arrange
      final tResponse = {
        'meals_by_child': {
          '1': {
            'report': {
              'id': 10,
              'meal_date': '2025-01-01',
              'breakfast_name': 'Boiled eggs',
              'breakfast_recipe': 'Boil for 5 mins',
              'media': [
                {
                  'meal_type': 'breakfast',
                  'file_path': 'http://example.com/egg.jpg'
                }
              ]
            },
            'group': {
              'name': 'A1'
            }
          }
        },
        'date': '2025-01-01'
      };

      when(() => mockDioClient.get(
            ApiConstants.dailyMenu,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.dailyMenu),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await menuApi.getDailyMenu(date: tDate, studentId: tStudentId);

      // Assert
      expect(result.isNotEmpty, true);
      final breakfast = result.firstWhere((m) => m.mealType == MealType.breakfast);
      expect(breakfast.dishes.length, 1);
      final dish = breakfast.dishes.first;
      expect(dish.name, 'Boiled eggs');
      expect(dish.description, 'Guruh: A1\nBoil for 5 mins');
      expect(dish.imageUrl, 'http://example.com/egg.jpg');
    });
  });
}
