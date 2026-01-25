import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mishkat_admin_dashboard/src/features/auth/presentation/login_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/users/presentation/user_management_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/presentation/course_catalog_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/curriculum/presentation/curriculum_builder_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/presentation/enrollment_management_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/presentation/payment_ledger_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/presentation/payment_details_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/technical/presentation/technical_dashboard_screen.dart';
import 'package:mishkat_admin_dashboard/src/features/settings/presentation/settings_screen.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';
      
      if (user == null && !isLoggingIn) return '/login';
      if (user != null && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CourseCatalogScreen(),
            routes: [
              GoRoute(
                path: ':id/curriculum',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final title = state.extra as String? ?? 'Course';
                  return CurriculumBuilderScreen(courseId: id, courseTitle: title);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/enrollments',
            builder: (context, state) => const EnrollmentManagementScreen(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentLedgerScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PaymentDetailsScreen(paymentId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/technical',
            builder: (context, state) => const TechnicalDashboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
