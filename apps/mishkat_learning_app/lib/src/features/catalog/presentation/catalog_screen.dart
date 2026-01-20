import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import 'package:mishkat_learning_app/src/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_learning_app/src/features/courses/data/course_repository.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = AppConstants.subjectAreas;

  final List<Map<String, dynamic>> _allCourses = [
    {
      'title': 'The Great Prophets: Story of Lady Maryam',
      'instructor': 'Sheikh Ali Rizvi',
      'rating': 4.8,
      'reviews': 124,
      'duration': '4h 30m',
      'imageUrl': 'https://images.unsplash.com/photo-1549675583-93361848bb44?w=400&h=300&fit=crop',
      'category': 'History',
    },
    {
      'title': 'Introduction to Shia Theology',
      'instructor': 'Seyyed Hossein Nasr',
      'rating': 4.9,
      'reviews': 89,
      'duration': '6h 15m',
      'imageUrl': 'https://images.unsplash.com/photo-1595126730953-2947a24c75ca?w=400&h=300&fit=crop',
      'category': 'Theology',
    },
    {
      'title': 'Nahjul Balagha: Wisdom of Ali (as)',
      'instructor': 'Dr. Ahmad Vaezi',
      'rating': 5.0,
      'reviews': 56,
      'duration': '10h 0m',
      'imageUrl': 'https://images.unsplash.com/photo-1524312674251-872e616c6838?w=400&h=300&fit=crop',
      'category': 'Spirituality',
    },
    {
      'title': 'Spirituality in Daily Life',
      'instructor': 'Ustadha Fatima Abbas',
      'rating': 4.7,
      'reviews': 210,
      'duration': '3h 45m',
      'imageUrl': 'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6?w=400&h=300&fit=crop',
      'category': 'Spirituality',
    },
    {
      'title': 'Principles of Islamic Jurisprudence',
      'instructor': 'Sheikh Muhammad Taqi',
      'rating': 4.9,
      'reviews': 167,
      'duration': '8h 20m',
      'imageUrl': 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=300&fit=crop',
      'category': 'Jurisprudence',
    },
    {
      'title': 'The Lives of the Fourteen Infallibles',
      'instructor': 'Dr. Fatima Zahra',
      'rating': 4.8,
      'reviews': 203,
      'duration': '12h 0m',
      'imageUrl': 'https://images.unsplash.com/photo-1515266591878-5a146e9f21f1?w=400&h=300&fit=crop',
      'category': 'History',
    },
    {
      'title': 'Quranic Exegesis: Surah Al-Fatiha',
      'instructor': 'Sheikh Hassan Qazwini',
      'rating': 5.0,
      'reviews': 98,
      'duration': '5h 30m',
      'imageUrl': 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=400&h=300&fit=crop',
      'category': 'Quranic Studies',
    },
    {
      'title': 'Islamic Ethics and Moral Philosophy',
      'instructor': 'Dr. Reza Hajj',
      'rating': 4.6,
      'reviews': 142,
      'duration': '7h 15m',
      'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=300&fit=crop',
      'category': 'Ethics',
    },
  ];

  // We will now use the stream provided by Riverpod

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 4 : (width > 800 ? 3 : (width > 600 ? 2 : 1));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Explore Courses',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_allCourses.length} courses available',
              style: const TextStyle(color: AppTheme.slateGrey),
            ),
            const SizedBox(height: 32),

            // Search Bar
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.deepEmerald),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.deepEmerald, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.deepEmerald,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.slateGrey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.deepEmerald
                            : AppTheme.slateGrey.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            // Course Grid
            ref.watch(coursesStreamProvider).when(
                  data: (courses) {
                    final filtered = courses.where((course) {
                      final matchesCategory = _selectedCategory == 'All' || course.category == _selectedCategory;
                      final matchesSearch = course.title.toLowerCase().contains(_searchQuery.toLowerCase());
                      return matchesCategory && matchesSearch;
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filtered.length} ${filtered.length == 1 ? 'course' : 'courses'} found',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slateGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (filtered.isEmpty)
                          Center(child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text('No courses found matching your criteria.', style: TextStyle(color: AppTheme.slateGrey)),
                          ))
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final course = filtered[index];
                              return _GridCourseCard(
                                title: course.title,
                                instructor: course.instructor,
                                rating: course.rating,
                                reviews: course.reviews,
                                duration: course.duration,
                                imageUrl: course.imageUrl,
                                slug: course.slug,
                              );
                            },
                          ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
          ],
        ),
      ),
    ),
  );
}
}

// Grid-optimized course card without fixed width
class _GridCourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final double rating;
  final int reviews;
  final String duration;
  final String imageUrl;
  final String slug;

  const _GridCourseCard({
    required this.title,
    required this.instructor,
    required this.rating,
    required this.reviews,
    required this.duration,
    required this.imageUrl,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/browse/$slug'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                       style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.slateGrey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.slateGrey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppTheme.radiantGold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviews)',
                          style: const TextStyle(fontSize: 11, color: AppTheme.slateGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
