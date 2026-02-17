import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/assignment_model.dart';
import '../storage/secure_storage.dart';

import 'route_names.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/academics/grades_screen.dart';
import '../../presentation/screens/academics/assignments_screen.dart';
import '../../presentation/screens/rating/rating_screen.dart';
import '../../presentation/screens/payments/payments_screen.dart';
import '../../presentation/screens/payments/payment_history_screen.dart';
import '../../presentation/screens/payments/payment_method_screen.dart';
import '../../presentation/screens/menu/daily_menu_screen.dart';
import '../../presentation/screens/academics/schedule_screen.dart';
import '../../presentation/screens/academics/attendance_screen.dart';
import '../../presentation/screens/academics/assignment_detail_screen.dart';
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/chat_room_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/profile/children_list_screen.dart';
import '../../presentation/screens/profile/change_password_screen.dart';

// Placeholder screens — Developer 1 ularni haqiqiy screenlar bilan almashtiradi

/// GoRouter konfiguratsiyasi
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final SecureStorageService _secureStorage = SecureStorageService();

  static const Set<String> _publicRoutes = {
    RouteNames.splash,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
  };

  static Future<bool> _hasValidSession() async {
    try {
      final token = await _secureStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) async {
      final location = state.matchedLocation;
      final isPublicRoute = _publicRoutes.contains(location);
      final isAuthenticated = await _hasValidSession();

      if (!isAuthenticated && !isPublicRoute) {
        return RouteNames.login;
      }

      return null;
    },
    routes: [
      // ─── Splash ───
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── Auth ───
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─── Home (Main Navigation container) ───
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // ─── Profile ───
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.childrenList,
        builder: (context, state) => const ChildrenListScreen(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // ─── Academics ───
      GoRoute(
        path: RouteNames.grades,
        builder: (context, state) => const GradesScreen(),
      ),
      GoRoute(
        path: RouteNames.schedule,
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: RouteNames.assignments,
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: RouteNames.assignmentDetail,
        builder: (context, state) =>
            AssignmentDetailScreen(assignment: state.extra as AssignmentModel?),
      ),
      GoRoute(
        path: RouteNames.attendance,
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: RouteNames.rating,
        builder: (context, state) => const RatingScreen(),
      ),

      // ─── Payments ───
      GoRoute(
        path: RouteNames.payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: RouteNames.paymentMethod,
        builder: (context, state) => const PaymentMethodScreen(),
      ),
      GoRoute(
        path: RouteNames.paymentHistory,
        builder: (context, state) => const PaymentHistoryScreen(),
      ),

      // ─── Menu ───
      GoRoute(
        path: RouteNames.menu,
        builder: (context, state) => const DailyMenuScreen(),
      ),

      // ─── Chat ───
      GoRoute(
        path: RouteNames.chatList,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: RouteNames.chatRoom,
        builder: (context, state) =>
            ChatRoomScreen(chatData: state.extra as Map<String, dynamic>?),
      ),

      // ─── Notifications ───
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
