import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../data/models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/menu/meal_card.dart';
import '../../widgets/common/app_state_view.dart';
import '../../widgets/common/page_background.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

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
    final colorScheme = theme.colorScheme;
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
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text(
                l10n.dailyMenuTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: PageBackground(
        child: Column(
          children: [
            // ─── Top Calendar Section (Modern Bento Card) ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 30)),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      HapticFeedback.selectionClick();
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
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: theme.textTheme.titleMedium?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left_rounded, color: colorScheme.primary),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w600),
                      weekendTextStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                      selectedDecoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w700),
                      weekendStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Meals List Section ───
            Expanded(
              child: AppStateView(
                isLoading: state.isLoading,
                errorMessage: state.error,
                isEmpty: meals.isEmpty && !state.isLoading,
                emptyMessage: l10n.noMenuOnSelectedDay,
                onRetry: () => _loadWeeklyMenuForSelectedChild(force: true),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), // Bottom space for nav
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
            ),
          ],
        ),
      ),
    );
  }
}
