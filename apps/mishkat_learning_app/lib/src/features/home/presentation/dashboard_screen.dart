import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/features/auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/data/progress_repository.dart';
import 'package:go_router/go_router.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/daily_wisdom_card.dart';
import 'widgets/mishkat_course_card.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final coursesAsync = ref.watch(coursesStreamProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.radiantGold.withValues(alpha: 0.5), width: 2),
                    ),
                    child: authState.when(
                      data: (user) {
                        final profileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : const AsyncValue.loading();
                        return profileAsync.when(
                          data: (profile) => CircleAvatar(
                            radius: 28,
                            backgroundImage: (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty)
                              ? NetworkImage(profile.photoUrl!) 
                              : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(profile?.displayName ?? 'User')}&background=004D40&color=fff'),
                          ),
                          loading: () => const CircleAvatar(radius: 28, child: CircularProgressIndicator()),
                          error: (_, __) => const CircleAvatar(radius: 28, child: Icon(Icons.error)),
                        );
                      },
                      loading: () => const CircleAvatar(radius: 28, child: CircularProgressIndicator()),
                      error: (_, __) => const CircleAvatar(radius: 28, child: Icon(Icons.error)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Greeting & App Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MISHKAT LEARNING',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.radiantGold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      authState.when(
                        data: (user) {
                          final profileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : const AsyncValue.loading();
                          return profileAsync.when(
                            data: (profile) => Text(
                              'Salam Alaykum, ${profile?.displayName.split(' ')[0] ?? 'Seeker'}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            loading: () => const Text('Salam Alaykum...'),
                            error: (_, __) => const Text('Salam Alaykum'),
                          );
                        },
                        loading: () => const Text('Salam Alaykum...'),
                        error: (_, __) => const Text('Salam Alaykum'),
                      ),
                    ],
                  ),
                ),

                // Notification Icon with Badge
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.deepEmerald,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.black.withValues(alpha: 0.05), thickness: 1),
            const SizedBox(height: 24),

            // Continue Learning Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Continue Learning',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                  ),
                ),
                Text(
                  'In Progress',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    color: AppTheme.deepEmerald,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Continue Learning Card
            authState.when(
              data: (user) {
                if (user == null) {
                  return _buildLoginPrompt(context);
                }

                final enrollmentsAsync = ref.watch(userEnrollmentsProvider(user.uid));
                return enrollmentsAsync.when(
                  data: (enrollments) {
                    if (enrollments.isEmpty) {
                      return _buildEmptyProgress(context);
                    }

                    // Get the latest enrollment
                    final latest = enrollments.first;
                    final courseId = latest['id'] as String;
                    final completedParts = latest['completedParts'] as List? ?? [];

                    return ref.watch(specificCourseProvider(courseId)).when(
                          data: (course) {
                            if (course == null) return const SizedBox.shrink();
                            
                            // Calculate progress
                            final progress = course.lessonCount > 0 
                                ? (completedParts.length / course.lessonCount) // This is a bit naive if lessonCount is lesson parts
                                : 0.0;
                            // For now, let's just assume we have parts. But we need total parts.
                            // Better: Fetch total parts for the course.
                            
                            return ContinueLearningCard(
                              courseTitle: course.title,
                              currentLesson: 'Next Part', // Placeholder for now
                              progress: progress,
                              imageUrl: course.imageUrl,
                              onPressed: () => context.push('/courses/${course.slug}'),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => const SizedBox.shrink(),
                        );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox.shrink(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),

            // Daily Wisdom Section Header
            Text(
              'Daily Wisdom',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Daily Wisdom Card
            const DailyWisdomCard(
              quote: 'The most complete gift of God is a life based on knowledge.',
              source: 'Nahj al-Balagha',
            ),
            const SizedBox(height: 40),

            // Featured Courses
            _buildSectionHeader(context, 'Explore More Categories', 'Browse All'),
            const SizedBox(height: 16),
            coursesAsync.when(
              data: (courses) => SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length > 5 ? 5 : courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return MishkatCourseCard(
                      title: course.title,
                      instructor: course.instructor,
                      rating: course.rating,
                      reviews: course.reviews,
                      duration: course.duration,
                      imageUrl: course.imageUrl,
                      category: course.category,
                      slug: course.slug,
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Text('Error loading courses: $err'),
            ),
            const SizedBox(height: 40),

            // New Additions
            _buildSectionHeader(context, 'New Additions', 'See all'),
            const SizedBox(height: 16),
            coursesAsync.when(
              data: (courses) => SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length > 3 ? 3 : courses.length,
                  reverse: true, // Just to show something different
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return MishkatCourseCard(
                      title: course.title,
                      instructor: course.instructor,
                      rating: course.rating,
                      reviews: course.reviews,
                      duration: course.duration,
                      imageUrl: course.imageUrl,
                      level: course.level,
                      lessonCount: '${course.lessonCount} Lessons',
                      slug: course.slug,
                    );
                  },
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeader(BuildContext context, String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.deepEmerald,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            actionText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.deepEmerald.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.deepEmerald.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: AppTheme.deepEmerald, size: 40),
          const SizedBox(height: 16),
          Text(
            'Sign in to track your progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.radiantGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.radiantGold.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.explore_outlined, color: AppTheme.radiantGold, size: 40),
          const SizedBox(height: 16),
          Text(
            'Start your learning journey',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't enrolled in any courses yet.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.go('/courses'),
            child: const Text('Browse Courses'),
          ),
        ],
      ),
    );
  }
}
