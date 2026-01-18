import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
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
          builder: (context, state) => const DashboardPlaceholder(),
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
          builder: (context, state) => const Center(child: Text('Profile')),
        ),
      ],
    ),
  ],
);

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assalamu Alaikum, Ahmad',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text('Dashboard content will go here'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
