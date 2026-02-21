import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../providers/user_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/menu/meal_card.dart';

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
    final state = ref.watch(menuProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _loadWeeklyMenuForSelectedChild();
      }
    });

    // Tanlangan sana uchun barcha meal lar
    final dailyMenus =
        state.weeklyMenu.where((menu) {
          if (menu.date.isEmpty) return false;
          try {
            final menuDate = DateTime.parse(menu.date);
            return isSameDay(menuDate, _selectedDay ?? _focusedDay);
          } catch (_) {
            return false;
          }
        }).toList()..sort(
          (a, b) => _mealOrder(a.mealType).compareTo(_mealOrder(b.mealType)),
        );

    final meals = dailyMenus
        .expand(
          (menu) => menu.dishes.map(
            (dish) => {
              'title': dish.name,
              'time': menu.mealTypeText,
              'calories': '${dish.calories}',
              'imageUrl': dish.imageUrl ?? '',
              'ingredients': (dish.description ?? '')
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            },
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ovqat menyusi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              // Show info about ingredients and allergens
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Top Calendar Section ───
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white70, fontSize: 13),
                  weekendStyle: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          ),

          // ─── Meals List Section ───
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(child: Text(state.error!))
                : meals.isEmpty
                ? const Center(
                    child: Text('Tanlangan kun uchun menyu mavjud emas'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: MealCard(
                          title: meal['title'] as String,
                          time: meal['time'] as String,
                          calories: meal['calories'] as String,
                          imageUrl: meal['imageUrl'] as String,
                          ingredients: meal['ingredients'] as List<String>,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
