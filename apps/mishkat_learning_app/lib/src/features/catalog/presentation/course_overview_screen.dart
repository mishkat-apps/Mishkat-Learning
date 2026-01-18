import 'package:flutter/material.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Hero Segment
                  _buildVideoHero(context),
                  
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'The Great Prophets: Story of Lady Maryam',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.accentGold, size: 20),
                            const SizedBox(width: 4),
                            const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text('(124 reviews)', style: TextStyle(color: AppTheme.textGrey)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Stats Grid
                        _buildStatsGrid(),
                        const SizedBox(height: 32),

                        // About Section
                        const Text(
                          'About this Course',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Dive deep into the life and spiritual significance of Lady Maryam (as), as presented in the Quran and Shia traditions. This course explores her piety, miracles, and her status as one of the four greatest women of paradise.',
                          style: TextStyle(height: 1.6, color: AppTheme.textNavy),
                        ),
                        const SizedBox(height: 32),

                        // What you will learn
                        _buildChecklistSection(),
                        const SizedBox(height: 32),

                        // Instructor Bio
                        _buildInstructorBio(),
                        const SizedBox(height: 32),

                        // Syllabus Accordion
                        const Text(
                          'Syllabus',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildSyllabus(),
                        const SizedBox(height: 100), // Space for sticky bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildStickyBottomBar(context),
    );
  }

  Widget _buildVideoHero(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            'https://placeholder.com/1280x720',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black26),
          IconButton(
            icon: const Icon(Icons.play_circle_fill, size: 80, color: Colors.white),
            onPressed: () {},
          ),
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatBox(Icons.timer_outlined, '4.5 Hours', 'Duration'),
        const SizedBox(width: 12),
        _buildStatBox(Icons.bar_chart_outlined, 'Beginner', 'Level'),
        const SizedBox(width: 12),
        _buildStatBox(Icons.verified_outlined, 'Certificate', 'Credential'),
      ],
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.textGrey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accentGold, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection() {
    final items = [
      'Understand the Quranic narrative of Maryam (as)',
      'Learn about the spiritual virtues and miracles',
      'Explore the significance in Shia traditions',
      'Practical lessons for modern spiritual growth'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What you will learn',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.primaryEmerald, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(item)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildInstructorBio() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.textGrey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 32, backgroundImage: NetworkImage('https://placeholder.com/150')),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Sheikh Ali Rizvi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: AppTheme.primaryEmerald, size: 16),
                  ],
                ),
                const Text('Professor of Islamic Studies', style: TextStyle(color: AppTheme.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabus() {
    return Column(
      children: [
        _buildModuleTile('Module 1: The Divine Beginning', ['The Lineage of Maryam', 'The Vow of Hannah']),
        _buildModuleTile('Module 2: The Sanctuary', ['Spiritual Service', 'The Miraculous Provisions']),
        _buildModuleTile('Module 3: The Annunciation', ['The Meeting with Jabrail', 'The Divine Decree']),
      ],
    );
  }

  Widget _buildModuleTile(String title, List<String> lessons) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: lessons.map((l) => ListTile(
        leading: const Icon(Icons.lock_outline, size: 18),
        title: Text(l, style: const TextStyle(fontSize: 14)),
        trailing: const Text('15:00', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      )).toList(),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Added from the requested change
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10, // Original blurRadius
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FREE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy)),
                Text('Full lifetime access', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              ),
              child: const Row(
                children: [
                  Text('Enroll Now'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
