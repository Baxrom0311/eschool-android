import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/menu_provider.dart';
import 'package:parent_school_app/data/repositories/menu_repository.dart';
import 'package:parent_school_app/data/models/menu_model.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Mock MenuRepository
class MockMenuRepository implements MenuRepository {
  bool shouldReturnError = false;

  @override
  Future<Either<Failure, List<MenuModel>>> getDailyMenu({
    String? date,
    int? studentId,
  }) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Daily menu load failed'));
    }
    return const Right([
      MenuModel(id: 1, date: '2023-10-10', mealType: MealType.breakfast, dishes: [DishModel(name: 'Egg'), DishModel(name: 'Bread')]),
    ]);
  }

  @override
  Future<Either<Failure, List<MenuModel>>> getWeeklyMenu({
    String? weekStart,
    int? studentId,
  }) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Weekly menu load failed'));
    }
    return const Right([
      MenuModel(id: 1, date: '2023-10-10', mealType: MealType.breakfast, dishes: [DishModel(name: 'Egg')]),
      MenuModel(id: 2, date: '2023-10-10', mealType: MealType.lunch, dishes: [DishModel(name: 'Soup')]),
    ]);
  }
}

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
      await menuNotifier.loadDailyMenu(date: '2023-10-10');
      
      expect(menuNotifier.state.isLoading, false);
      expect(menuNotifier.state.dailyMenu.length, 1);
      expect(menuNotifier.state.selectedDate, '2023-10-10');
      expect(menuNotifier.state.error, null);
    });

    test('loadDailyMenu failure', () async {
      mockRepository.shouldReturnError = true;
      await menuNotifier.loadDailyMenu(date: '2023-10-10');
      
      expect(menuNotifier.state.isLoading, false);
      expect(menuNotifier.state.error, 'Daily menu load failed');
    });

    test('loadWeeklyMenu success', () async {
      await menuNotifier.loadWeeklyMenu();
      
      expect(menuNotifier.state.isLoading, false);
      expect(menuNotifier.state.weeklyMenu.length, 2);
      expect(menuNotifier.state.error, null);
    });
  });
}
