import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/academic_provider.dart';
import '../../providers/app_locale_provider.dart';
import '../../providers/app_theme_mode_provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/user_provider.dart';
import '../profile/profile_screen.dart';
import '../academics/grades_screen.dart';
import '../payments/payments_screen.dart';
import '../menu/daily_menu_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../../providers/leaderboard_provider.dart';

import 'widgets/academic_stats.dart';
import 'widgets/attendance_card.dart';
import 'widgets/daily_menu_card.dart';
import 'widgets/home_header.dart';
import 'widgets/schedule_list.dart';
import 'widgets/services_grid.dart';

/// Home Screen - Main App Screen with Bottom Navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Tabs are lazily instantiated to avoid firing all tab API calls on startup.
  late final List<Widget Function()> _screenBuilders = [
    () => const _HomeTabScreen(),
    () => const _EducationTabScreen(),
    () => const DailyMenuScreen(),
    () => const PaymentsScreen(),
    () => const ProfileScreen(),
  ];
  late final List<Widget?> _loadedScreens;

  @override
  void initState() {
    super.initState();
    _loadedScreens = List<Widget?>.filled(_screenBuilders.length, null);
    _loadedScreens[0] = _screenBuilders[0]();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _loadedScreens[index] ??= _screenBuilders[index]();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(appLocaleProvider);
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showMainAppBar = _currentIndex <= 1;

    return Scaffold(
      appBar: showMainAppBar
          ? AppBar(
              title: Text(
                _currentIndex == 0 ? l10n.homeTitle : l10n.academicsTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor:
                  theme.appBarTheme.backgroundColor ?? colorScheme.surface,
              foregroundColor:
                  theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
              elevation: 0,
              centerTitle: false,
              actions: [
                PopupMenuButton<ThemeMode>(
                  tooltip: l10n.changeTheme,
                  initialValue: currentThemeMode,
                  onSelected: (themeMode) {
                    ref
                        .read(appThemeModeProvider.notifier)
                        .setThemeMode(themeMode);
                  },
                  itemBuilder: (context) => ThemeMode.values
                      .map(
                        (themeMode) => PopupMenuItem<ThemeMode>(
                          value: themeMode,
                          child: Row(
                            children: [
                              Icon(_themeModeIcon(themeMode), size: 18),
                              const SizedBox(width: 10),
                              Text(_themeModeLabel(themeMode, l10n)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  icon: Icon(
                    _themeModeIcon(currentThemeMode),
                    color: colorScheme.onSurface,
                  ),
                ),
                PopupMenuButton<AppLocale>(
                  tooltip: l10n.changeLanguage,
                  initialValue: currentLocale,
                  onSelected: (locale) {
                    ref.read(appLocaleProvider.notifier).setLocale(locale);
                  },
                  itemBuilder: (context) => AppLocale.values
                      .map(
                        (locale) => PopupMenuItem<AppLocale>(
                          value: locale,
                          child: Text(locale.nativeLabel),
                        ),
                      )
                      .toList(),
                  icon: const Icon(Icons.translate_rounded),
                ),
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
      body: IndexedStack(
        index: _currentIndex,
        children: List<Widget>.generate(
          _screenBuilders.length,
          (index) => _loadedScreens[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school_rounded),
            label: l10n.academics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_rounded),
            label: l10n.menu,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            label: l10n.paymentShort,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode themeMode, AppLocalizations l10n) {
    return switch (themeMode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
  }

  IconData _themeModeIcon(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };
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

    // We use ref.read(...notifier) to trigger shared async logic.
    // Ensure providers are kept alive if needed, but autoDispose is fine
    // as long as the widget watches them (which build() does).

    // Note: With AsyncNotifier, if we call these, they update the state.
    // If the providers are autoDispose and not watched, they might cancel immediately.
    // But we watch them in build(), so they stay alive designated by the widget lifecycle.

    ref.read(scheduleProvider.notifier).loadSchedule(child.id);
    ref.read(scheduleProvider.notifier).selectDay(now.weekday);
    // Backenddagi /api/parent/children/{id} endpoint vaqtincha nosoz bo'lgani
    // uchun Home ochilganda grades/attendance prefetch qilmaymiz.
    // Tegishli ekran ochilganda ular alohida yuklanadi.
    ref.read(ratingProvider.notifier).loadChildRating(child.id);
    ref.read(leaderboardProvider.notifier).loadData(child.id);
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildProvider);

    // Watch AsyncValues
    final attendanceAsync = ref.watch(attendanceProvider);
    final gradesAsync = ref.watch(gradesProvider);
    final ratingState = ref.watch(ratingProvider);

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
    final rank = ratingState.childRating?.rank;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                  score: child?.coins ?? 0,
                  level: child?.level ?? 1,
                ),

                const ScheduleList(),

                const SizedBox(height: 24),

                const ServicesGrid(),

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
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 40),
              tabs: [
                Tab(text: l10n.gradesTab),
                Tab(text: l10n.ratingTab),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(children: [GradesScreen(), LeaderboardScreen()]),
          ),
        ],
      ),
    );
  }
}
