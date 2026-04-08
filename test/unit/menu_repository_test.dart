import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/data/datasources/remote/menu_api.dart';
import 'package:parent_school_app/data/models/menu_model.dart';
import 'package:parent_school_app/data/repositories/menu_repository.dart';

class MockMenuApi extends Mock implements MenuApi {}

void main() {
  late MenuRepository repository;
  late MockMenuApi mockMenuApi;

  setUp(() {
    mockMenuApi = MockMenuApi();
    repository = MenuRepository(menuApi: mockMenuApi);
  });

  group('MenuRepository', () {
    const tStudentId = 1;
    const tDate = '2025-01-01';
    final tMenuList = [
      const MenuModel(
        id: 101,
        date: tDate,
        mealType: MealType.breakfast,
        dishes: [],
        totalCalories: 0,
      ),
    ];

    test('getDailyMenu returns data on success', () async {
      // Arrange
      when(
        () => mockMenuApi.getDailyMenu(
          date: any(named: 'date'),
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer((_) async => tMenuList);

      // Act
      final result = await repository.getDailyMenu(
        date: tDate,
        studentId: tStudentId,
      );

      // Assert
      expect(result, tMenuList);
      verify(
        () => mockMenuApi.getDailyMenu(date: tDate, studentId: tStudentId),
      ).called(1);
    });

    test('getDailyMenu throws exception on error', () async {
      // Arrange
      when(
        () => mockMenuApi.getDailyMenu(
          date: any(named: 'date'),
          studentId: any(named: 'studentId'),
        ),
      ).thenThrow(const ServerException(message: 'Server xatoligi'));

      // Act & Assert
      expect(
        () => repository.getDailyMenu(date: tDate, studentId: tStudentId),
        throwsA(isA<ServerException>()),
      );
    });

    test('getWeeklyMenu returns data on success', () async {
      // Arrange
      when(
        () => mockMenuApi.getWeeklyMenu(
          weekStart: any(named: 'weekStart'),
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer((_) async => tMenuList);

      // Act
      final result = await repository.getWeeklyMenu(
        weekStart: tDate,
        studentId: tStudentId,
      );

      // Assert
      expect(result, tMenuList);
      verify(
        () =>
            mockMenuApi.getWeeklyMenu(weekStart: tDate, studentId: tStudentId),
      ).called(1);
    });
  });
}
