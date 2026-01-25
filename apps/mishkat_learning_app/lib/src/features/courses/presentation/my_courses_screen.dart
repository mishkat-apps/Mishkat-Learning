import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../data/course_repository.dart';
import '../domain/models.dart';
import '../../auth/data/auth_repository.dart';
import '../../../widgets/common/mishkat_badge.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    // Watch only the courses the user is enrolled in
    final coursesAsync = ref.watch(enrolledCoursesProvider);
    final enrollmentsAsync = ref.watch(userEnrollmentsProvider(user.uid));

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
        centerTitle: true,
        title: Text(
          'MY COURSES',
          style: GoogleFonts.roboto(
            color: AppTheme.radiantGold, 
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
      ),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.school_outlined, size: 64, color: AppTheme.slateGrey),
                   const SizedBox(height: 16),
                   Text('No courses enrolled yet', style: GoogleFonts.roboto(fontSize: 18, color: AppTheme.slateGrey)),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => context.go('/courses'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppTheme.deepEmerald,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     child: const Text('Explore Catalog'),
                   ),
                ],
              ),
            );
          }
          
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isWide 
                ? GridView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: courses.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      mainAxisExtent: 420,
                    ),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final enrollment = enrollmentsAsync.value?.firstWhere(
                        (e) => e.courseId == course.id, 
                        orElse: () => Enrollment(uid: '', courseId: '', enrolledAt: DateTime.now(), progress: 0, status: '', accessType: '')
                      );
                      return _CourseEnrollmentCard(
                        course: course,
                        progress: enrollment?.progress ?? 0.0,
                        isGrid: true,
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final enrollment = enrollmentsAsync.value?.firstWhere(
                        (e) => e.courseId == course.id, 
                        orElse: () => Enrollment(uid: '', courseId: '', enrolledAt: DateTime.now(), progress: 0, status: '', accessType: '')
                      );
                      return _CourseEnrollmentCard(
                        course: course,
                        progress: enrollment?.progress ?? 0.0,
                      );
                    },
                  ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.deepEmerald)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CourseEnrollmentCard extends StatelessWidget {
  final Course course;
  final double progress;
  final bool isGrid;
  const _CourseEnrollmentCard({
    required this.course, 
    required this.progress,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/courses/${course.slug}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 21 / 9,
                    child: Image.network(
                      course.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.slateGrey.withValues(alpha: 0.1),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: MishkatBadge(
                      type: progress >= 100 
                          ? MishkatBadgeType.completed 
                          : MishkatBadgeType.inProgress,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slateGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.instructorName,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppTheme.slateGrey.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress / 100, // progress is 0-100
                              backgroundColor: const Color(0xFFF0F0F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.softGold),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${progress.toInt()}%',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slateGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/courses/${course.slug}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepEmerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue Learning',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
