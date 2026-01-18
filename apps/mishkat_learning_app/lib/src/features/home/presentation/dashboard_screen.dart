import 'package:flutter/material.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/daily_wisdom_card.dart';
import 'widgets/mishkat_course_card.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

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
                    const Text(
                      'MISHKAT LEARNING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assalamu Alaikum, Ahmad',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                  color: AppTheme.secondaryNavy,
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Continue Learning Section Header
            const Text(
              'Continue Learning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
            const SizedBox(height: 16),

            // Continue Learning Card
            const ContinueLearningCard(
              courseTitle: 'Philosophy of Karbala',
              currentLesson: 'Lecture 4: Spiritual Dimensions',
              progress: 0.65,
              timeLeft: '32 mins left',
            ),
            const SizedBox(height: 32),

            // Daily Wisdom Section Header
            const Text(
              'Daily Wisdom',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
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
            _buildSectionHeader('Featured Courses', 'Explore All'),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  MishkatCourseCard(
                    title: 'Foundations of Shia Jurisprudence',
                    instructor: 'Sheikh Al-Amili',
                    rating: 4.9,
                    reviews: 245,
                    duration: '8h',
                    imageUrl: 'https://images.unsplash.com/photo-1604514570127-1b3ae0558b5f?w=400&h=300&fit=crop',
                    category: 'Jurisprudence',
                  ),
                  MishkatCourseCard(
                    title: 'Lives of the Ahlul Bayt',
                    instructor: 'Dr. Fatima Zahra',
                    rating: 5.0,
                    reviews: 189,
                    duration: '12h',
                    imageUrl: 'https://images.unsplash.com/photo-1519013196-4c6fbe1de8b6?w=400&h=300&fit=crop',
                    category: 'History',
                  ),
                  MishkatCourseCard(
                    title: 'Tawheed: Divine Unity',
                    instructor: 'Seyyed Hossein Nasr',
                    rating: 4.8,
                    reviews: 312,
                    duration: '6h',
                    imageUrl: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&h=300&fit=crop',
                    category: 'Theology',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // New Additions
            _buildSectionHeader('New Additions', 'See all'),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  MishkatCourseCard(
                    title: 'The Spiritual Secrets of Prayer',
                    instructor: 'Sheikh Hassan Qazwini',
                    rating: 4.9,
                    reviews: 156,
                    duration: '5h',
                    imageUrl: 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=400&h=300&fit=crop',
                    level: 'Beginner',
                    lessonCount: '12 Lessons',
                  ),
                  MishkatCourseCard(
                    title: 'Advanced Logic (Mantiq)',
                    instructor: 'Dr. Ahmad Vaezi',
                    rating: 4.7,
                    reviews: 89,
                    duration: '15h',
                    imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop',
                    level: 'Advanced',
                  ),
                  MishkatCourseCard(
                    title: 'Ethics in Daily Life',
                    instructor: 'Ustadha Fatima Abbas',
                    rating: 4.8,
                    reviews: 203,
                    duration: '4h',
                    imageUrl: 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=400&h=300&fit=crop',
                    level: 'Intermediate',
                    lessonCount: '8 Lessons',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
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
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
