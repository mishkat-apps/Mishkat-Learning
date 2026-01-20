import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../data/course_repository.dart';
import '../domain/models.dart';
import '../../auth/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    // In a real app, you'd have an enrolledCoursesStreamProvider
    // For now, we'll watch all courses and filter by whether they are enrolled
    // (This is a simplified version for restoration)
    final coursesAsync = ref.watch(coursesStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Courses',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppTheme.slateGrey,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.slateGrey),
      ),
      body: coursesAsync.when(
        data: (courses) {
          // TODO: Filter based on enrollment in Firestore
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _CourseEnrollmentCard(course: course);
            },
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
  const _CourseEnrollmentCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          onTap: () => context.go('/browse/${course.slug}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: const LinearProgressIndicator(
                              value: 0.0, // Replace with actual progress
                              backgroundColor: Color(0xFFF0F0F0),
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.softGold),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '0%', // Replace with actual progress
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
                        onPressed: () => context.go('/browse/${course.slug}'),
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
