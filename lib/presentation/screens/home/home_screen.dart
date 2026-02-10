import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../profile/profile_screen.dart';
import '../academics/grades_screen.dart';
import '../payments/payments_screen.dart';
import '../menu/daily_menu_screen.dart';
import '../rating/rating_screen.dart';

/// Home Screen - Main App Screen with Bottom Navigation
///
/// Sprint 2 - Task 1
/// Dev1 Responsibility
///
/// Structure: Scaffold with BottomNavigationBar
/// Tabs: Home, Education, Menu, Payments, Profile
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'E-School',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
// Placeholder Tab Screens (Dev1 will implement later)
// ═══════════════════════════════════════════════════════

class _HomeTabScreen extends StatelessWidget {
  const _HomeTabScreen();

  // Mock data for today's classes
  final List<Map<String, dynamic>> todayClasses = const [
    {
      'subject': 'Matematika',
      'time': '08:00 - 08:45',
      'room': '204-xona',
      'isActive': true,
    },
    {
      'subject': 'Ingliz tili',
      'time': '09:00 - 09:45',
      'room': '301-xona',
      'isActive': false,
    },
    {
      'subject': 'Fizika',
      'time': '10:00 - 10:45',
      'room': '205-xona',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Welcome Row ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salom, Azizbek 👋',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Bugun dushanba, 10-fevral',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(RouteNames.notifications);
                      },
                      icon: Stack(
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 30,
                            color: AppColors.textPrimary,
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ═══════════════════════════════════════════════════════
              // Header Card (Attendance & Points)
              // ═══════════════════════════════════════════════════════
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.secondaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Davomat',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '98%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Ballar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '845',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // Today's Classes Section
              // ═══════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bugungi Darslar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(RouteNames.schedule);
                      },
                      child: const Text('Barchasi'),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: todayClasses.length,
                  itemBuilder: (context, index) {
                    final classItem = todayClasses[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: classItem['isActive']
                            ? AppColors.primaryBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: classItem['isActive']
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                classItem['time'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: classItem['isActive']
                                      ? Colors.white.withOpacity(0.9)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            classItem['subject'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: classItem['isActive']
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.room_rounded,
                                size: 14,
                                color: classItem['isActive']
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                classItem['room'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: classItem['isActive']
                                      ? Colors.white.withOpacity(0.9)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════
              // Stats Row (Average Grade & Class Rank)
              // ═══════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Average Grade Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'O\'rtacha baho',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: 0.96,
                                    strokeWidth: 8,
                                    backgroundColor: AppColors.border,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                                const Text(
                                  '4.8',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Class Rank Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Sinf reytingi',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Icon(
                              Icons.emoji_events_rounded,
                              size: 48,
                              color: Color(0xFFFFD700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '#3',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            Text(
                              'o\'rin',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════
              // Latest News Section
              // ═══════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'So\'nggi yangilik',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '12:30',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bugungi Tushlik',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Oshxonada yangi taomlar tayyorlandi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
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
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 40),
              tabs: const [
                Tab(text: 'Baholar'),
                Tab(text: 'Reyting'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            GradesScreen(),
            RatingScreen(),
          ],
        ),
      ),
    );
  }
}
