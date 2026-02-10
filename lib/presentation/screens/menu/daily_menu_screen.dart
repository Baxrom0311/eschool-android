import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/menu/meal_card.dart';

/// Daily Menu Screen - Weekly food schedule
///
/// Sprint 4 - Task 1
/// Dev1 Responsibility
class DailyMenuScreen extends ConsumerStatefulWidget {
  const DailyMenuScreen({super.key});

  @override
  ConsumerState<DailyMenuScreen> createState() => _DailyMenuScreenState();
}

class _DailyMenuScreenState extends ConsumerState<DailyMenuScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Mock data for meals
  final Map<int, List<Map<String, dynamic>>> _mockMeals = {
    // 1: Monday, 2: Tuesday, etc.
    DateTime.monday: [
      {
        'title': 'Suli bo\'tqasi va mevalar',
        'time': '08:30 - Nonushta',
        'calories': '350',
        'imageUrl':
            'https://images.unsplash.com/photo-1517673132405-a56a62b18caf',
        'ingredients': ['Suli', 'Sut', 'Banan', 'Asal'],
      },
      {
        'title': 'Mastava va Sho\'rva',
        'time': '13:00 - Tushlik',
        'calories': '650',
        'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd',
        'ingredients': ['Guruch', 'Go\'sht', 'Sabzi', 'Kartoshka'],
      },
      {
        'title': 'Tovuqli salat',
        'time': '16:00 - Ikkinchi tushlik',
        'calories': '250',
        'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        'ingredients': ['Tovuq', 'Bodring', 'Pomidor', 'Zaytun moyi'],
      },
    ],
    DateTime.tuesday: [
      {
        'title': 'Issiq sendvich va choy',
        'time': '08:30 - Nonushta',
        'calories': '400',
        'imageUrl':
            'https://images.unsplash.com/photo-1525351484163-7529414344d8',
        'ingredients': ['Non', 'Pishloq', 'Bodring'],
      },
      {
        'title': 'Palov (Osh)',
        'time': '13:00 - Tushlik',
        'calories': '850',
        'imageUrl':
            'https://images.unsplash.com/photo-1512058560566-d837c3aee132',
        'ingredients': ['Guruch', 'Go\'sht', 'Sabzi', 'No\'xat'],
      },
      {
        'title': 'Meva va sharbat',
        'time': '16:00 - Ikkinchi tushlik',
        'calories': '150',
        'imageUrl':
            'https://images.unsplash.com/photo-1490818387583-1baba5e638af',
        'ingredients': ['Olma', 'Banan', 'Sharbat'],
      },
    ],
    // Add other days if needed, but for mock, we rotate
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Map<String, dynamic>> _getMealsForDay(DateTime day) {
    // Return meals based on weekday (1-7)
    return _mockMeals[day.weekday] ?? _mockMeals[DateTime.monday]!;
  }

  @override
  Widget build(BuildContext context) {
    final meals = _getMealsForDay(_selectedDay ?? _focusedDay);

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
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: const BorderRadius.only(
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
                  leftChevronIcon:
                      const Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      const Icon(Icons.chevron_right, color: Colors.white),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
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
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: MealCard(
                    title: meal['title'],
                    time: meal['time'],
                    calories: meal['calories'],
                    imageUrl: meal['imageUrl'],
                    ingredients: meal['ingredients'],
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
