import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/menu_model.dart';
import 'package:parent_school_app/presentation/providers/menu_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/menu/daily_menu_screen.dart';
import 'package:parent_school_app/presentation/widgets/menu/meal_card.dart';

class MockMenuNotifier extends StateNotifier<MenuState> with Mock implements MenuNotifier {
  MockMenuNotifier(super.state);
}

void main() {
  late MockMenuNotifier mockMenuNotifier;

  final testChild = ChildModel(
    id: 1,
    fullName: 'Ali',
    className: '1A',
    classId: 10,
  );

  final todayStr = DateTime.now().toIso8601String().split('T').first;

  final testMenu = [
    MenuModel(
      id: 1,
      date: todayStr,
      mealType: MealType.breakfast,
      totalCalories: 500,
      dishes: [
        DishModel(
          id: 1,
          name: 'Sutli Bo\'tqa',
          description: 'Sut, sariyog\', guruch',
          calories: 300,
        ),
      ],
    ),
    MenuModel(
      id: 2,
      date: todayStr,
      mealType: MealType.lunch,
      totalCalories: 800,
      dishes: [
        DishModel(
          id: 2,
          name: 'Osh',
          description: 'Guruch, go\'sht, sabzi',
          calories: 800,
        ),
      ],
    ),
  ];

  setUp(() {
    mockMenuNotifier = MockMenuNotifier(
      MenuState(weeklyMenu: testMenu),
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        menuProvider.overrideWith((ref) => mockMenuNotifier),
        selectedChildProvider.overrideWithValue(testChild),
      ],
      child: const MaterialApp(
        home: DailyMenuScreen(),
      ),
    );
  }

  group('DailyMenuScreen Widget Tests', () {
    testWidgets('shows loading state properly', (tester) async {
      mockMenuNotifier = MockMenuNotifier(
        const MenuState(isLoading: true),
      );
      when(() => mockMenuNotifier.loadWeeklyMenu(studentId: 1)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders daily menu correctly based on selected date', (tester) async {
      when(() => mockMenuNotifier.loadWeeklyMenu(studentId: 1)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Ovqat menyusi'), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
      
      // Should find MealCards for today's dishes
      expect(find.byType(MealCard), findsNWidgets(2));
      expect(find.text('Sutli Bo\'tqa'), findsOneWidget);
      expect(find.text('Osh'), findsOneWidget);
      expect(find.text('300 kcal'), findsOneWidget); // Calories
      expect(find.text('800 kcal'), findsOneWidget); // Calories

      verify(() => mockMenuNotifier.loadWeeklyMenu(studentId: 1)).called(1);
    });

    testWidgets('shows empty message when no menu exists for selected date', (tester) async {
      when(() => mockMenuNotifier.loadWeeklyMenu(studentId: 1)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on next day in calendar
      final tableCalendar = find.byType(TableCalendar);
      final widget = tester.widget<TableCalendar>(tableCalendar);
      
      // Calculate a date that is tomorrow
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      // Trigger day selection directly using TableCalendar's callback instead of trying to find the cell by text
      widget.onDaySelected!(tomorrow, tomorrow);
      await tester.pumpAndSettle();

      expect(find.text('Tanlangan kun uchun menyu mavjud emas'), findsOneWidget);
    });
  });
}
