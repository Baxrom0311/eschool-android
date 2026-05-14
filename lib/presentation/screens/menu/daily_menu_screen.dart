import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../data/models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/menu/meal_card.dart';
import '../../widgets/common/app_state_view.dart';
import '../../widgets/common/glass_app_bar.dart';
import '../../widgets/common/page_background.dart';
import '../../widgets/common/liquid_glass.dart';

/// Daily Menu Screen - Weekly food schedule
class DailyMenuScreen extends ConsumerStatefulWidget {
  const DailyMenuScreen({super.key});

  @override
  ConsumerState<DailyMenuScreen> createState() => _DailyMenuScreenState();
}

class _DailyMenuScreenState extends ConsumerState<DailyMenuScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int? _lastLoadedStudentId;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(_loadWeeklyMenuForSelectedChild);
  }

  void _loadWeeklyMenuForSelectedChild({bool force = false}) {
    final selectedChild = ref.read(selectedChildProvider);
    final studentId = selectedChild?.id;
    final menuState = ref.read(menuProvider);
    final hasWeeklyData =
        menuState.weeklyMenu.isNotEmpty &&
        menuState.error == null &&
        _lastLoadedStudentId == studentId;

    if (!force && (menuState.isLoading || hasWeeklyData)) {
      return;
    }

    _lastLoadedStudentId = studentId;
    ref.read(menuProvider.notifier).loadWeeklyMenu(studentId: studentId);
  }

  int _mealOrder(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 0;
      case MealType.lunch:
        return 1;
      case MealType.afternoonTea:
        return 2;
      case MealType.dinner:
        return 3;
      case MealType.snack:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(menuProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _loadWeeklyMenuForSelectedChild();
      }
    });

    final dailyMenus = state.weeklyMenu.where((menu) {
      if (menu.date.isEmpty) return false;
      try {
        final menuDate = DateTime.parse(menu.date);
        return isSameDay(menuDate, _selectedDay ?? _focusedDay);
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) => _mealOrder(a.mealType).compareTo(_mealOrder(b.mealType)));

    final groupedMeals = <MealType, Map<String, dynamic>>{};
    for (final menu in dailyMenus) {
      if (!groupedMeals.containsKey(menu.mealType)) {
        groupedMeals[menu.mealType] = {
          'time': menu.mealTypeText,
          'dishes': <Map<String, dynamic>>[],
        };
      }
      for (final dish in menu.dishes) {
        (groupedMeals[menu.mealType]!['dishes'] as List).add({
          'title': dish.name,
          'calories': '${dish.calories}',
          'imageUrl': dish.imageUrl ?? '',
          'ingredients': (dish.description ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        });
      }
    }

    final sortedMealTypes = groupedMeals.keys.toList()
      ..sort((a, b) => _mealOrder(a).compareTo(_mealOrder(b)));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(l10n.dailyMenuTitle, style: theme.appBarTheme.titleTextStyle),
      ),
      body: PageBackground(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 56),

            // ─── Modern Liquid Glass Calendar ───
            LiquidGlassPanel(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: BorderRadius.circular(32),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 90)),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {CalendarFormat.week: 'Week'},
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.5,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  selectedDecoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.liquidIndigo),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: theme.textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    letterSpacing: 1.0,
                  ),
                  weekendStyle: theme.textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            // ─── Meals List Section (Grouped) ───
            Expanded(
              child: AppStateView(
                isLoading: state.isLoading,
                errorMessage: state.error,
                isEmpty: sortedMealTypes.isEmpty && !state.isLoading,
                emptyMessage: l10n.noMenuOnSelectedDay,
                onRetry: () => _loadWeeklyMenuForSelectedChild(force: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: sortedMealTypes.length,
                  itemBuilder: (context, index) {
                    final mealType = sortedMealTypes[index];
                    final mealData = groupedMeals[mealType]!;
                    final dishes = mealData['dishes'] as List;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MealCard(
                        title: mealData['time'] as String,
                        time: mealData['time'] as String,
                        calories: dishes.first['calories'] as String,
                        imageUrl: dishes.first['imageUrl'] as String,
                        dishes: dishes.map((d) => d['title'] as String).toList(),
                        ingredients: dishes.expand((d) => d['ingredients'] as List).map((e) => e as String).toSet().toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
