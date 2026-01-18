import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/catalog/presentation/course_overview_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../widgets/navigation/main_shell.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Login Screen'))),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Register Screen'))),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/course/:id',
          builder: (context, state) => const CourseOverviewScreen(),
        ),
        GoRoute(
          path: '/curriculum',
          builder: (context, state) => const Center(child: Text('Curriculum')),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const Center(child: Text('Library')),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
