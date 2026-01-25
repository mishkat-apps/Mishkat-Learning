import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/features/auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../courses/data/course_repository.dart';
import 'package:go_router/go_router.dart';
import '../../home/data/hadith_repository.dart';
import '../../home/domain/hadith.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/daily_wisdom_card.dart';
import 'widgets/mishkat_course_card.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import '../../courses/domain/models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final coursesAsync = ref.watch(coursesStreamProvider);
    final dailyHadithAsync = ref.watch(dailyHadithProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  _buildHeader(context, ref, authState),
                  const SizedBox(height: 32),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Learning & Wisdom)
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildContinueLearning(context, ref, authState),
                              const SizedBox(height: 32),
                              _buildDailyWisdom(dailyHadithAsync),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Right Column (Course Lists)
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeaturedCourses(context, coursesAsync),
                              const SizedBox(height: 32),
                              _buildNewAdditions(context, coursesAsync),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContinueLearning(context, ref, authState),
                        const SizedBox(height: 32),
                        _buildDailyWisdom(dailyHadithAsync),
                        const SizedBox(height: 40),
                        _buildFeaturedCourses(context, coursesAsync),
                        const SizedBox(height: 40),
                        _buildNewAdditions(context, coursesAsync),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AsyncValue authState) {
    return Row(
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
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MISHKAT LEARNING',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 2),
              authState.when(
                data: (user) {
                  final profileAsync = user != null ? ref.watch(userProfileProvider(user.uid)) : const AsyncValue.loading();
                  return profileAsync.when(
                    data: (profile) => Text(
                      'Salam Alaykum, ${profile?.displayName.split(' ')[0] ?? 'Seeker'}',
                      style: Theme.of(context).textTheme.titleLarge,
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

        // Notification Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.secondaryNavy),
        ),
      ],
    );
  }

  Widget _buildContinueLearning(BuildContext context, WidgetRef ref, AsyncValue authState) {
    return authState.when(
      data: (user) {
        if (user == null) return _buildAuthPrompt(context);
        final enrollmentsAsync = ref.watch(userEnrollmentsProvider(user.uid));

        return enrollmentsAsync.when(
          data: (enrollments) {
            if (enrollments.isEmpty) return _buildNoEnrollments(context);

            // Sort by enrolledAt descending to get the most recent one
            final sortedEnrollments = List<Enrollment>.from(enrollments)
              ..sort((a, b) => b.enrolledAt.compareTo(a.enrolledAt));
            
            final recentEnrollment = sortedEnrollments.first;
            final courseId = recentEnrollment.courseId;
            final progress = recentEnrollment.progress.toDouble();

            final courseAsync = ref.watch(specificCourseProvider(courseId));

            return courseAsync.when(
              data: (course) {
                if (course == null) return const SizedBox.shrink();
                return ContinueLearningCard(
                  course: course,
                  progress: progress,
                  onPressed: () => context.push('/courses/${course.slug}'),
                );
              },
              loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
              error: (err, __) => Text('Error: $err'),
            );
          },
          loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
          error: (err, __) => Text('Error: $err'),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDailyWisdom(AsyncValue<Hadith?> dailyHadithAsync) {
    return dailyHadithAsync.when(
      data: (hadith) {
        if (hadith == null) {
          // Fallback static or empty
             return const DailyWisdomCard(
              quote: 'The seeking of knowledge is obligatory for every Muslim.',
              quoteAr: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
              source: 'Prophet Muhammad (saw)',
              reference: 'Al-Kafi',
            );
        }
        return DailyWisdomCard(
          quote: hadith.englishText,
          quoteAr: hadith.arabicText,
          source: hadith.narrator,
          reference: hadith.reference,
        );
      },
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFeaturedCourses(BuildContext context, AsyncValue<List<Course>> coursesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Explore More', 'Browse All'),
        const SizedBox(height: 16),
        coursesAsync.when(
          data: (courses) => SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length > 5 ? 5 : courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 200,
                    child: MishkatCourseCard(
                      course: course,
                    ),
                  ),
                );
              },
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildNewAdditions(BuildContext context, AsyncValue<List<Course>> coursesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'New Additions', 'See All'),
        const SizedBox(height: 16),
        coursesAsync.when(
          data: (courses) {
            final newCourses = courses.where((c) => c.isNew).toList();
            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newCourses.length > 5 ? 5 : newCourses.length,
                itemBuilder: (context, index) {
                  final course = newCourses[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 200,
                      child: MishkatCourseCard(
                        course: course,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        TextButton(
          onPressed: () {
            if (title == 'New Additions') {
               context.go(Uri(path: '/courses', queryParameters: {'filter': 'new'}).toString());
            } else {
               context.go('/courses');
            }
          },
          child: Text(
            action,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: AppTheme.radiantGold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.deepEmerald.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: AppTheme.deepEmerald, size: 40),
          const SizedBox(height: 16),
          Text(
            'Sign in to track your progress',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepEmerald,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEnrollments(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.radiantGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.radiantGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.explore_outlined, color: AppTheme.radiantGold, size: 40),
          const SizedBox(height: 16),
          Text(
            'Start your learning journey',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't enrolled in any courses yet.",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: AppTheme.slateGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.go('/courses'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.radiantGold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Browse Courses', style: TextStyle(color: AppTheme.radiantGold)),
          ),
        ],
      ),
    );
  }
}
