import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/academic_provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/user_provider.dart';
import '../profile/profile_screen.dart';
import '../academics/grades_screen.dart';
import '../payments/payments_screen.dart';
import '../menu/daily_menu_screen.dart';
import '../rating/rating_screen.dart';

import 'widgets/academic_stats.dart';
import 'widgets/attendance_card.dart';
import 'widgets/daily_menu_card.dart';
import 'widgets/home_header.dart';
import 'widgets/schedule_list.dart';

/// Home Screen - Main App Screen with Bottom Navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Tab screens
  final List<Widget> _screens = [
    const _HomeTabScreen(),
    const _EducationTabScreen(),
    const DailyMenuScreen(),
    const PaymentsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final showMainAppBar = _currentIndex <= 1;

    return Scaffold(
      appBar: showMainAppBar
          ? AppBar(
              title: Text(
                _currentIndex == 0 ? 'E-School' : 'Ta\'lim',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () {
                    context.push(RouteNames.notifications);
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Asosiy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Ta\'lim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Ovqat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'To\'lov',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Home Dashboard Tab
// ═══════════════════════════════════════════════════════

class _HomeTabScreen extends ConsumerStatefulWidget {
  const _HomeTabScreen();

  @override
  ConsumerState<_HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<_HomeTabScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  void _loadHomeData() {
    final child = ref.read(selectedChildProvider);
    if (child == null) return;

    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // We use ref.read(...notifier) to trigger shared async logic.
    // Ensure providers are kept alive if needed, but autoDispose is fine
    // as long as the widget watches them (which build() does).

    // Note: With AsyncNotifier, if we call these, they update the state.
    // If the providers are autoDispose and not watched, they might cancel immediately.
    // But we watch them in build(), so they stay alive designated by the widget lifecycle.

    ref.read(scheduleProvider.notifier).loadSchedule(child.id);
    ref.read(scheduleProvider.notifier).selectDay(now.weekday);
    ref
        .read(attendanceProvider.notifier)
        .loadAttendance(child.id, month: month);
    ref.read(gradesProvider.notifier).loadGrades(child.id);
    ref.read(ratingProvider.notifier).loadChildRating(child.id);
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildProvider);

    // Watch AsyncValues
    final attendanceAsync = ref.watch(attendanceProvider);
    final gradesAsync = ref.watch(gradesProvider);
    final ratingState = ref.watch(
      ratingProvider,
    ); // Rating is still old StateNotifier

    // Listen for child changes to reload
    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadHomeData();
      }
    });

    // Calculate Attendance Rate
    final attendanceRate =
        attendanceAsync.valueOrNull?.summary?.attendancePercentage ??
        child?.attendancePercentage ??
        0.0;

    // Calculate GPA
    final gradesData = gradesAsync.valueOrNull;
    double gpa = 0.0;

    if (gradesData != null) {
      if (gradesData.summary.isNotEmpty) {
        gpa =
            gradesData.summary.fold<double>(
              0.0,
              (sum, item) => sum + item.averageGrade,
            ) /
            gradesData.summary.length;
      } else if (gradesData.grades.isNotEmpty) {
        gpa =
            gradesData.grades.fold<double>(
              0.0,
              (sum, item) => sum + item.grade,
            ) /
            gradesData.grades.length;
      }
    }

    if (gpa == 0.0) gpa = child?.averageGrade ?? 0.0;
    gpa = gpa.clamp(0.0, 5.0);

    // Rating Score/Rank
    final score = ratingState.childRating?.totalScore.round() ?? 0;
    final rank = ratingState.childRating?.rank;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadHomeData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),

                AttendanceCard(
                  attendanceRate: attendanceRate
                      .round()
                      .clamp(0, 100)
                      .toDouble(),
                  score: score,
                ),

                const ScheduleList(),

                const SizedBox(height: 24),

                AcademicStats(gpa: gpa, rank: rank),

                const SizedBox(height: 24),

                const DailyMenuCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EducationTabScreen extends StatelessWidget {
  const _EducationTabScreen();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 40),
              tabs: [
                Tab(text: 'Baholar'),
                Tab(text: 'Reyting'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(children: [GradesScreen(), RatingScreen()]),
          ),
        ],
      ),
    );
  }
}
