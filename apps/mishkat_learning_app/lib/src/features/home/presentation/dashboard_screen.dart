import 'package:flutter/material.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/daily_wisdom_card.dart';
import 'widgets/mishkat_course_card.dart';
import '../../../../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalamu Alaikum, Ahmad',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text(
                      'Ready to continue your journey for knowledge?',
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://placeholder.com/150'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Continue Learning
            const ContinueLearningCard(
              courseTitle: 'Principles of Islamic Jurisprudence',
              currentLesson: 'The Concept of Ijtihad',
              progress: 0.65,
            ),
            const SizedBox(height: 32),

            // Daily Wisdom
            const DailyWisdomCard(
              quote: 'The pursuit of knowledge is an obligation upon every Muslim. Verily, Allah loves those who seek knowledge.',
              source: 'PROPHET MUHAMMAD (SAW)',
            ),
            const SizedBox(height: 48),

            // Featured Courses
            _buildSectionHeader('Featured Courses'),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  MishkatCourseCard(
                    title: 'The Great Prophets: Story of Lady Maryam',
                    instructor: 'Sheikh Ali Rizvi',
                    rating: 4.8,
                    reviews: 124,
                    duration: '4h 30m',
                    imageUrl: 'https://placeholder.com/400x300',
                  ),
                  MishkatCourseCard(
                    title: 'Introduction to Shia Theology',
                    instructor: 'Seyyed Hossein Nasr',
                    rating: 4.9,
                    reviews: 89,
                    duration: '6h 15m',
                    imageUrl: 'https://placeholder.com/401x301',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // New Additions
            _buildSectionHeader('New Additions'),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  MishkatCourseCard(
                    title: 'Nahjul Balagha: Wisdom of Ali (as)',
                    instructor: 'Dr. Ahmad Vaezi',
                    rating: 5.0,
                    reviews: 56,
                    duration: '10h 0m',
                    imageUrl: 'https://placeholder.com/402x302',
                  ),
                  MishkatCourseCard(
                    title: 'Spirituality in Daily Life',
                    instructor: 'Ustadha Fatima Abbas',
                    rating: 4.7,
                    reviews: 210,
                    duration: '3h 45m',
                    imageUrl: 'https://placeholder.com/403x303',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('See All'),
        ),
      ],
    );
  }
}
