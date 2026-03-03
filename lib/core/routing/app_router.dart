import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/assignment_model.dart';

import 'route_names.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';

import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/qr_login_screen.dart';
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';

// Placeholder screens — Developer 1 ularni haqiqiy screenlar bilan almashtiradi

final routerNotifierProvider = ChangeNotifierProvider((ref) => RouterNotifier(ref));

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final location = state.matchedLocation;
    final isPublicRoute = AppRouter.publicRoutes.contains(location);

    // Initial check hasn't finished (still checking secure storage on boot)
    if (authState == const AuthState.initial() && location == RouteNames.splash) {
      return null;
    }

    final isAuthenticated = authState.isAuthenticated;

    if (!isAuthenticated && !isPublicRoute) {
      return RouteNames.login;
    }

    if (isAuthenticated &&
        (location == RouteNames.login ||
            location == RouteNames.forgotPassword ||
            location == RouteNames.splash)) {
      return RouteNames.home;
    }

    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    routes: AppRouter.routes,
  );
});

/// GoRouter konfiguratsiyasi
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static const Set<String> publicRoutes = {
    RouteNames.splash,
    RouteNames.login,
    RouteNames.forgotPassword,
    RouteNames.qrLogin,
  };

  static final List<RouteBase> routes = [
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
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: RouteNames.qrLogin,
      builder: (context, state) => const QrLoginScreen(),
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
  ];
}
