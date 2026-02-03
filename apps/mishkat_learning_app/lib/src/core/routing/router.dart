import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/catalog/presentation/course_overview_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/account_settings_screen.dart';
import '../../features/profile/presentation/language_selection_screen.dart';
import '../../features/profile/presentation/support_faq_screen.dart';
import '../../features/payments/presentation/payment_history_screen.dart';
import '../../features/courses/presentation/lesson_player_screen.dart';
import '../../features/courses/presentation/my_courses_screen.dart';
import '../../widgets/navigation/main_shell.dart';
import '../../features/style_guide/presentation/brand_style_guide_screen.dart';
import '../../features/info/presentation/about_screen.dart';
import '../../features/info/presentation/contact_screen.dart';
import '../../features/info/presentation/privacy_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../services/router_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.watch(authStateProvider);
      if (authAsync.isLoading) return null;
      final user = authAsync.value;
      
      final isLoggingIn = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/' ||
                          state.matchedLocation == '/about' ||
                          state.matchedLocation == '/contact' ||
                          state.matchedLocation == '/privacy';

      if (user == null) {
        // Not logged in: allow only landing/auth pages
        if (isLoggingIn) return null;
        
        
        return '/';
      }

      // Logged in: if on landing/auth pages, go to dashboard
      if (isLoggingIn && state.matchedLocation != '/') {
        return '/dashboard';
      }


      // Don't redirect if already logged in and going to dashboard/other protected routes
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
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      // App Routes
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) => CatalogScreen(
              initialFilter: state.uri.queryParameters['filter'],
            ),
          ),
          GoRoute(
            name: 'course_details',
            path: '/courses/:courseSlug',
            builder: (context, state) {
              final slug = state.pathParameters['courseSlug']!;
              return CourseOverviewScreen(slug: slug);
            },
          ),
          GoRoute(
            name: 'lesson_player',
            path: '/courses/:courseSlug/:lessonSlug',
            builder: (context, state) {
              final courseSlug = state.pathParameters['courseSlug']!;
              final lessonSlug = state.pathParameters['lessonSlug']!;
              return LessonPlayerScreen(
                courseSlug: courseSlug,
                lessonSlug: lessonSlug,
              );
            },
          ),
          GoRoute(
            name: 'lesson_part',
            path: '/courses/:courseSlug/:lessonSlug/:partSlug',
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
              GoRoute(
                path: 'settings',
                builder: (context, state) => const AccountSettingsScreen(),
              ),
              GoRoute(
                path: 'language',
                builder: (context, state) => const LanguageSelectionScreen(),
              ),
              GoRoute(
                path: 'support',
                builder: (context, state) => const SupportFaqScreen(),
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
});
