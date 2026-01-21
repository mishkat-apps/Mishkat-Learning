import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import '../../../courses/domain/models.dart';

class MishkatCourseCard extends StatelessWidget {
  final Course course;
  final double? width;

  const MishkatCourseCard({
    super.key,
    required this.course,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/courses/${course.slug}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              AspectRatio(
                aspectRatio: 1.2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      course.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to gradient background if image fails
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.deepEmerald.withValues(alpha: 0.3),
                                AppTheme.radiantGold.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: AppTheme.slateGrey,
                            ),
                          ),
                        );
                      },
                    ),
                    // Category Badge (if provided)
                    if (course.category.isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            course.category.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: AppTheme.deepEmerald,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.slateGrey,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Instructor with icon
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                                color: AppTheme.slateGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            course.instructorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: AppTheme.slateGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Bottom Row - Level/Lesson Count
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          size: 14,
                                color: AppTheme.slateGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.lessonCount} Parts',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppTheme.slateGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (course.level.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getLevelColor(course.level).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              course.level.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getLevelColor(course.level),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
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

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppTheme.deepEmerald;
    }
  }
}
