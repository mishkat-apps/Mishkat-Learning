import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/catalog/presentation/course_overview_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/payments/presentation/payment_history_screen.dart';
import '../../features/courses/presentation/lesson_player_screen.dart';
import '../../features/courses/presentation/my_courses_screen.dart';
import '../../widgets/navigation/main_shell.dart';
import '../../features/style_guide/presentation/brand_style_guide_screen.dart';


final goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Note: In a real app, you'd use a more robust way to sync Riverpod with GoRouter
    // For now, we'll keep it simple and handle it in the screens or via a provider
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CatalogScreen(),
          routes: [
            GoRoute(
              path: ':courseSlug',
              builder: (context, state) {
                final slug = state.pathParameters['courseSlug']!;
                return CourseOverviewScreen(slug: slug);
              },
              routes: [
                GoRoute(
                  path: ':lessonSlug',
                  builder: (context, state) {
                    final courseSlug = state.pathParameters['courseSlug']!;
                    final lessonSlug = state.pathParameters['lessonSlug']!;
                    // Optional partSlug query param or path?
                    // User requested: courses/<coursenameslug>/<lessonnameslug>/<partnameslug>
                    // So we should have a sub-route or capture it here.
                    // But if we want it optional, we might need a sub-route.
                    // Let's make it a sub-route for cleaner history.
                    return LessonPlayerScreen(
                      courseSlug: courseSlug,
                      lessonSlug: lessonSlug,
                    );
                  },
                  routes: [
                     GoRoute(
                      path: ':partSlug',
                      builder: (context, state) {
                        final courseSlug = state.pathParameters['courseSlug']!;
                        final lessonSlug = state.pathParameters['lessonSlug']!;
                        final partSlug = state.pathParameters['partSlug']!;
                        return LessonPlayerScreen(
                          courseSlug: courseSlug,
                          lessonSlug: lessonSlug,
                          partSlug: partSlug,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/my-courses',
          builder: (context, state) => const MyCoursesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'payments',
              builder: (context, state) => const PaymentHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/style-guide',
          builder: (context, state) => const BrandStyleGuideScreen(),
        ),
      ],
    ),
  ],
);
