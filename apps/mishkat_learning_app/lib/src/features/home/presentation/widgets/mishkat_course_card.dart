import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class MishkatCourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final double rating;
  final int reviews;
  final String duration;
  final String imageUrl;
  final String? category;
  final String? level;
  final String? lessonCount;
  final String slug;
  final double? width;

  const MishkatCourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.reviews,
    required this.duration,
    required this.imageUrl,
    this.category,
    this.level,
    this.lessonCount,
    required this.slug,
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
          onTap: () => context.push('/courses/$slug'),
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
                      imageUrl,
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
                    if (category != null)
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
                            category!.toUpperCase(),
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
                      title,
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
                            instructor,
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
                    if (level != null || lessonCount != null)
                      Row(
                        children: [
                          if (lessonCount != null) ...[
                            const Icon(
                              Icons.play_circle_outline,
                              size: 14,
                                    color: AppTheme.slateGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lessonCount!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: AppTheme.slateGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (lessonCount != null && level != null)
                            const SizedBox(width: 12),
                          if (level != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getLevelColor(level!).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                level!.toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(level!),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      // Rating row (fallback)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppTheme.radiantGold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviews)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: AppTheme.slateGrey,
                            ),
                          ),
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
