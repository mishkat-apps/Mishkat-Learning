import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../data/auth_repository.dart';
import '../../../widgets/common/geometric_background.dart';
import '../../../widgets/navigation/mishkat_navbar.dart';
import '../../../widgets/navigation/mishkat_drawer.dart';
import '../../../widgets/common/mishkat_footer.dart';
import '../../courses/domain/models.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Give some time for the app to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 768 && width < 1024;
    final isMobile = width < 768;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const MishkatNavbar(),
      drawer: const MishkatDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHero(context, width, isDesktop, isTablet),
            _buildFeatures(context, isDesktop, isTablet),
            _buildFeaturedCourses(context, isDesktop, isTablet),
            _buildStats(context, isDesktop),
            _buildFooter(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, double width, bool isDesktop, bool isTablet) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isDesktop ? 800 : (isTablet ? 700 : 600),
      ),
      child: SizedBox(
        width: double.infinity,
      child: GeometricBackground(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 40),
            child: isDesktop || isTablet
                ? Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroText(isDesktop, isTablet),
                            const SizedBox(height: 40),
                            _buildHeroButtons(context, false),
                          ],
                        ),
                      ),
                      if (isDesktop)
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: _buildHeroGraphic(width),
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      _buildHeroGraphic(width),
                      const SizedBox(height: 40),
                      _buildHeroText(isDesktop, isTablet),
                      const SizedBox(height: 40),
                      _buildHeroButtons(context, true),
                    ],
                  ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeroText(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: isDesktop || isTablet ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'QUEST FOR WISDOM',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: AppTheme.radiantGold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Illuminating the\nPath of Knowledge',
          textAlign: isDesktop || isTablet ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: isDesktop ? 64 : (isTablet ? 48 : 36),
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Join an elite community of seekers dedicated to scholarly Shia teachings and spiritual excellence. Experience deep learning through high-quality video content and expert-led discussions.',
            textAlign: isDesktop || isTablet ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroGraphic(double screenWidth) {
    final isMobile = screenWidth < 768;
    final size = isMobile ? 220.0 : 300.0; // Reduced size for mobile
    final iconSize = isMobile ? 100.0 : 140.0; // Reduced icon size

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.radiantGold.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.radiantGold.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: iconSize,
          color: AppTheme.radiantGold,
        ),
      ),
    );
  }

  Widget _buildHeroButtons(BuildContext context, bool isFullWidth) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: isFullWidth ? WrapAlignment.center : WrapAlignment.start,
      children: [
        SizedBox(
          width: isFullWidth ? double.infinity : 200,
          child: ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.radiantGold,
              foregroundColor: AppTheme.secondaryNavy,
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'START LEARNING',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ),
        SizedBox(
          width: isFullWidth ? double.infinity : 200,
          child: OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'EXPLORE COURSES',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context, bool isDesktop, bool isTablet) {
    final features = [
      {
        'icon': Icons.video_library_rounded,
        'title': 'Premium Video Content',
        'desc': 'High-definition lectures delivered by renowned scholars and experts.',
      },
      {
        'icon': Icons.menu_book_rounded,
        'title': 'Structured Curriculum',
        'desc': 'Courses designed to take you from fundamentals to advanced concepts.',
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'title': 'Verified Certificates',
        'desc': 'Earn recognition for your dedication and complete your learning path.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isDesktop ? 100 : 40),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'WHY MISHKAT LEARNING?',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppTheme.radiantGold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Gateway to Authentic Wisdom',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 60),
          isDesktop || isTablet
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: features.map((f) => Expanded(child: _buildFeatureCard(f))).toList(),
                )
              : Column(
                  children: features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: _buildFeatureCard(f),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.deepEmerald.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(feature['icon'] as IconData, size: 40, color: AppTheme.deepEmerald),
          ),
          const SizedBox(height: 24),
          Text(
            feature['title'] as String,
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
          ),
          const SizedBox(height: 12),
          Text(
            feature['desc'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontSize: 15, color: AppTheme.slateGrey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourses(BuildContext context, bool isDesktop, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100, horizontal: isDesktop ? 100 : 40),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FEATURED COURSES',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryNavy,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/courses'),
                child: Row(
                  children: [
                    Text('View All', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: AppTheme.radiantGold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.radiantGold),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          // Here we would ideally fetch the actual courses
          _buildStaticCourseGrid(isDesktop, isTablet),
        ],
      ),
    );
  }

  Widget _buildStaticCourseGrid(bool isDesktop, bool isTablet) {
    // Placeholder courses for the landing page
    final mockCourses = [
      Course(
        id: '1',
        title: 'Fundamentals of Islamic Philosophy',
        category: 'Aqeedah',
        imageUrl: 'https://images.unsplash.com/photo-1542810634-71277d95dcbb?auto=format&fit=crop&q=80&w=800',
        price: 49.99,
        rating: 4.8,
        slug: 'islamic-philosophy',
        description: 'Explore the depths of Islamic philosophical thought.',
        instructorId: 'placeholder',
        instructorName: 'Dr. Scholar',
        lessonCount: 12,
        reviews: 120,
        studentsCount: 2500,
        duration: '10h 30m',
        level: 'Intermediate',
        objectives: ['Understand core concepts', 'Analyze historical texts'],
        subjectAreas: ['Philosophy', 'Theology'],
        accessType: 'paid',
        tagline: 'Explore the depths of Islamic philosophical thought.',
        instructorTitle: 'Senior Scholar',
        instructorQuote: 'Wisdom is the lost property of the believer.',
        features: ['HD Video', 'Certificate'],
      ),
      Course(
        id: '2',
        title: 'Mastering Arabic Grammar (Nahw)',
        category: 'Language',
        imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=800',
        price: 0,
        rating: 4.9,
        slug: 'arabic-grammar',
        description: 'A comprehensive guide to Arabic grammar.',
        instructorId: 'placeholder',
        instructorName: 'Ustadh Arabic',
        lessonCount: 20,
        reviews: 350,
        studentsCount: 5000,
        duration: '15h 45m',
        level: 'Beginner',
        objectives: ['Master sentence structure', 'Learn common rules'],
        subjectAreas: ['Language', 'Grammar'],
        accessType: 'free',
        tagline: 'A comprehensive guide to Arabic grammar.',
        instructorTitle: 'Language Expert',
        instructorQuote: 'Arabic is the key to the Quran.',
        features: ['HD Video', 'Certificate'],
      ),
      Course(
        id: '3',
        title: 'The Life of Imam Ali (as)',
        category: 'History',
        imageUrl: 'https://images.unsplash.com/photo-1614850523296-d8c1af93d400?auto=format&fit=crop&q=80&w=800',
        price: 29.99,
        rating: 5.0,
        slug: 'life-of-imam-ali',
        description: 'A deep dive into the life and legacy of the Commander of the Faithful.',
        instructorId: 'placeholder',
        instructorName: 'Sheikh History',
        lessonCount: 15,
        reviews: 500,
        studentsCount: 8000,
        duration: '12h 00m',
        level: 'All Levels',
        objectives: ['Understand historical context', 'Learn from moral examples'],
        subjectAreas: ['History', 'Biography'],
        accessType: 'paid',
        tagline: 'Explore the depths of Islamic philosophical thought.',
        instructorTitle: 'Senior Scholar',
        instructorQuote: 'Wisdom is the lost property of the believer.',
        features: ['HD Video', 'Certificate'],
      ),
    ];

    if (isDesktop) {
      return Row(
        children: mockCourses.map((c) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _ModernCourseCardPlaceholder(course: c),
          ),
        )).toList(),
      );
    } else {
      return Column(
        children: mockCourses.take(2).map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _ModernCourseCardPlaceholder(course: c),
        )).toList(),
      );
    }
  }

  Widget _buildStats(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: const BoxDecoration(
        color: AppTheme.secondaryNavy,
      ),
      child: Center(
        child: Wrap(
          spacing: 100,
          runSpacing: 40,
          alignment: WrapAlignment.center,
          children: [
            _buildStatItem('2k+', 'Active Students'),
            _buildStatItem('50+', 'Expert Courses'),
            _buildStatItem('15+', 'Lead Scholars'),
            _buildStatItem('100%', 'Spiritual Growth'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.radiantGold),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white60, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    return const MishkatFooter();
  }
}
// Minimal placeholder for the course card to avoid importing the whole catalog world
class _ModernCourseCardPlaceholder extends StatelessWidget {
  final Course course;
  const _ModernCourseCardPlaceholder({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(course.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.category.toUpperCase(),
                  style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.radiantGold, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(course.rating.toString(), style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(
                      course.isFree ? 'FREE' : '${course.price.toInt()} USD',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: AppTheme.deepEmerald),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

