import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder screens
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome to Mishkat Learning', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Sign In')),
        ],
      ),
    ),
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign In')),
    body: const Center(child: Text('Login Screen Placeholder')),
  );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Dashboard Screen Placeholder')),
  );
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
  ],
);
