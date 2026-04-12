import 'dart:ui';
import 'package:parent_school_app/presentation/widgets/common/animated_pressable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/academic_provider.dart';
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
import '../../widgets/common/page_background.dart';

/// Home Screen - Main App Screen with Bottom Navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

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
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _loadedScreens[index] ??= _screenBuilders[index]();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true, // Allow content to flow behind floating nav
      appBar: _currentIndex == 0 ? PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: LiquidGlass.blur, sigmaY: LiquidGlass.blur),
            child: AppBar(
              title: Hero(
                tag: 'home_title',
                child: Text(
                  l10n.homeTitle,
                  style: theme.appBarTheme.titleTextStyle,
                ),
              ),
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: LiquidGlass.opacity(context)),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () => context.push(RouteNames.notifications),
                  icon: Badge(
                    label: const Text('2', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                    backgroundColor: theme.colorScheme.error,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ) : null,
      body: PageBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: List<Widget>.generate(
            _screenBuilders.length,
            (index) => _loadedScreens[index] ?? const SizedBox.shrink(),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? AppColors.slate900.withValues(alpha: LiquidGlass.opacity(context))
                  : AppColors.white.withValues(alpha: LiquidGlass.opacity(context)),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: LiquidGlass.blur, sigmaY: LiquidGlass.blur),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, l10n.home),
                      _buildNavItem(1, Icons.auto_graph_outlined, Icons.auto_graph_rounded, l10n.academics),
                      _buildNavItem(2, Icons.restaurant_outlined, Icons.restaurant_rounded, l10n.menu),
                      _buildNavItem(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, l10n.paymentShort),
                      _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, l10n.profile),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    
    return Expanded(
      child: AnimatedPressable(
        onTap: () => _onTabSelected(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  void _loadHomeData() {
    final child = ref.read(selectedChildProvider);
    if (child == null) return;
    final now = DateTime.now();
    ref.read(scheduleProvider.notifier).loadSchedule(child.id);
    ref.read(scheduleProvider.notifier).selectDay(now.weekday);
    ref.read(ratingProvider.notifier).loadChildRating(child.id);
    ref.read(leaderboardProvider.notifier).loadData(child.id);
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildProvider);
    final attendanceAsync = ref.watch(attendanceProvider);
    final gradesAsync = ref.watch(gradesProvider);
    final ratingState = ref.watch(ratingProvider);
    final theme = Theme.of(context);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadHomeData();
      }
    });

    final attendanceRate = attendanceAsync.valueOrNull?.summary?.attendancePercentage ?? child?.attendancePercentage ?? 0.0;
    final gradesData = gradesAsync.valueOrNull;
    double gpa = 0.0;

    if (gradesData != null) {
      if (gradesData.summary.isNotEmpty) {
        gpa = gradesData.summary.fold<double>(0.0, (sum, item) => sum + item.averageGrade) / gradesData.summary.length;
      } else if (gradesData.grades.isNotEmpty) {
        gpa = gradesData.grades.fold<double>(0.0, (sum, item) => sum + item.grade) / gradesData.grades.length;
      }
    }

    if (gpa == 0.0) gpa = child?.averageGrade ?? 0.0;
    gpa = gpa.clamp(0.0, 5.0).toDouble();
    final rank = ratingState.childRating?.rank;

    return RefreshIndicator(
      onRefresh: () async => _loadHomeData(),
      color: theme.colorScheme.primary,
      backgroundColor: theme.cardColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120), // Height for floating nav
        children: [
          const HomeHeader(),
          AttendanceCard(
            attendanceRate: attendanceRate.round().clamp(0, 100).toDouble(),
            score: child?.coins ?? 0,
            level: child?.level ?? 1,
          ),
          const SizedBox(height: 12),
          const ScheduleList(),
          const SizedBox(height: 16),
          const ServicesGrid(),
          const SizedBox(height: 16),
          AcademicStats(gpa: gpa, rank: rank),
          const SizedBox(height: 16),
          const DailyMenuCard(),
        ],
      ),
    );
  }
}

class _EducationTabScreen extends StatelessWidget {
  const _EducationTabScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: LiquidGlass.blur, sigmaY: LiquidGlass.blur),
            child: AppBar(
              title: Text(l10n.academicsTitle, style: theme.appBarTheme.titleTextStyle),
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: LiquidGlass.opacity(context)),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 8),
            Container(
              padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.05), width: 1)),
              ),
              child: TabBar(
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: l10n.gradesTab.toUpperCase()),
                  Tab(text: l10n.ratingTab.toUpperCase()),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  GradesScreen(),
                  LeaderboardScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
