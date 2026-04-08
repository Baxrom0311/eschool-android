import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/data/models/menu_model.dart';
import 'package:parent_school_app/data/repositories/menu_repository.dart';
import 'package:parent_school_app/presentation/providers/menu_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late MenuNotifier menuNotifier;
  late MockMenuRepository mockRepository;

  setUp(() {
    mockRepository = MockMenuRepository();
    menuNotifier = MenuNotifier(repository: mockRepository);
  });

  group('MenuNotifier Tests', () {
    test('Initial state correct', () {
      expect(menuNotifier.state.isLoading, false);
      expect(menuNotifier.state.dailyMenu, isEmpty);
    });

    test('loadDailyMenu success', () async {
      when(
        () => mockRepository.getDailyMenu(
          date: any(named: 'date'),
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer(
        (_) async => const [
          MenuModel(
            id: 1,
            date: '2023-10-10',
            mealType: MealType.breakfast,
            dishes: [
              DishModel(name: 'Egg'),
              DishModel(name: 'Bread'),
            ],
          ),
        ],
      );

      await menuNotifier.loadDailyMenu(date: '2023-10-10');

      expect(menuNotifier.state.isLoading, false);
      expect(menuNotifier.state.dailyMenu.length, 1);
      expect(menuNotifier.state.selectedDate, '2023-10-10');
      expect(menuNotifier.state.error, isNull);
    });

    test('loadDailyMenu failure', () async {
      when(
        () => mockRepository.getDailyMenu(
          date: any(named: 'date'),
          studentId: any(named: 'studentId'),
        ),
      ).thenThrow(const ServerException(message: 'Daily menu load failed'));

      await menuNotifier.loadDailyMenu(date: '2023-10-10');

      expect(menuNotifier.state.isLoading, false);
      expect(
        menuNotifier.state.error,
        'ServerException: Daily menu load failed',
      );
    });

    test('loadWeeklyMenu success', () async {
      when(
        () => mockRepository.getWeeklyMenu(
          weekStart: any(named: 'weekStart'),
          studentId: any(named: 'studentId'),
        ),
      ).thenAnswer(
        (_) async => const [
          MenuModel(
            id: 1,
            date: '2023-10-10',
            mealType: MealType.breakfast,
            dishes: [DishModel(name: 'Egg')],
          ),
          MenuModel(
            id: 2,
            date: '2023-10-10',
            mealType: MealType.lunch,
            dishes: [DishModel(name: 'Soup')],
          ),
        ],
      );

      await menuNotifier.loadWeeklyMenu();

      expect(menuNotifier.state.isLoading, false);
      expect(menuNotifier.state.weeklyMenu.length, 2);
      expect(menuNotifier.state.error, isNull);
    });
  });
}
