import 'package:flutter/material.dart';
import '../../../../widgets/common/mishkat_progress_bar.dart';
import '../../../../theme/app_theme.dart';

class ContinueLearningCard extends StatelessWidget {
  final String courseTitle;
  final String currentLesson;
  final double progress;

  const ContinueLearningCard({
    super.key,
    required this.courseTitle,
    required this.currentLesson,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              image: DecorationImage(
                image: NetworkImage('https://placeholder.com/600x200'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
              color: AppTheme.primaryEmerald,
            ),
            child: const Center(
              child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONTINUE LEARNING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  courseTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                ),
                Text(
                  'Current: $currentLesson',
                  style: const TextStyle(color: AppTheme.textGrey),
                ),
                const SizedBox(height: 20),
                MishkatProgressBar(progress: progress, showLabel: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Resume Study'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
