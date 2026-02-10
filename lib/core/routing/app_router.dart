import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

// Placeholder screens — Developer 1 ularni haqiqiy screenlar bilan almashtiradi
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// GoRouter konfiguratsiyasi
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // ─── Splash ───
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Splash'),
      ),

      // ─── Auth ───
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Register'),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Forgot Password'),
      ),

      // ─── Home (Main Navigation container) ───
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Home'),
      ),

      // ─── Profile ───
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Profile'),
      ),

      // ─── Academics ───
      GoRoute(
        path: RouteNames.grades,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Grades'),
      ),
      GoRoute(
        path: RouteNames.schedule,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Schedule'),
      ),
      GoRoute(
        path: RouteNames.assignments,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Assignments'),
      ),
      GoRoute(
        path: RouteNames.attendance,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Attendance'),
      ),
      GoRoute(
        path: RouteNames.rating,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Rating'),
      ),

      // ─── Payments ───
      GoRoute(
        path: RouteNames.payments,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Payments'),
      ),

      // ─── Menu ───
      GoRoute(
        path: RouteNames.menu,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Menu'),
      ),

      // ─── Chat ───
      GoRoute(
        path: RouteNames.chatList,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Chat List'),
      ),
      GoRoute(
        path: RouteNames.chatRoom,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Chat Room'),
      ),

      // ─── Notifications ───
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Notifications'),
      ),
    ],
  );
}
