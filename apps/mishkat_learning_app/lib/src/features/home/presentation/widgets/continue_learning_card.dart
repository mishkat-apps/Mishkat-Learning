import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import 'package:mishkat_learning_app/src/widgets/common/mishkat_progress_bar.dart';
import '../../../courses/domain/models.dart';

class ContinueLearningCard extends StatelessWidget {
  final Course course;
  final double progress;
  final VoidCallback? onPressed;

  const ContinueLearningCard({
    super.key,
    required this.course,
    required this.progress,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              course.imageUrl,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // In Progress Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.deepEmerald.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'In Progress',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              const Spacer(),
              
              // Course Title
              Text(
                course.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Current Lesson
              Text(
                'by ${course.instructorName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              
              // Progress Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress * 100).toInt()}% COMPLETE',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                          const SizedBox(height: 8),
                          MishkatProgressBar(
                            progress: progress,
                            height: 10,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Resume Study Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.deepEmerald,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_filled, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Resume Study',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
