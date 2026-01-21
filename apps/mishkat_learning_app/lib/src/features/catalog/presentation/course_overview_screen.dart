import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/data/progress_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../courses/domain/models.dart';
import '../../payments/data/payment_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../widgets/common/mishkat_badge.dart';

class CourseOverviewScreen extends ConsumerStatefulWidget {
  final String slug;
  const CourseOverviewScreen({super.key, required this.slug});

  @override
  ConsumerState<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends ConsumerState<CourseOverviewScreen> {
  @override
  void initState() {
    super.initState();
    
    // Initialize Razorpay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentRepositoryProvider).init(
        onSuccess: _handlePaymentSuccess,
        onFailure: _handlePaymentError,
        onExternalWallet: _handleExternalWallet,
      );
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Payment successful! The webhook will handle the enrollment, 
    // but we can show a success message and trigger a refresh.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful! Processing your enrollment...')),
      );
      // Force refresh of enrollment status
      ref.invalidate(isEnrolledProvider);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}')),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
      );
    }
  }

  @override
  void dispose() {
    ref.read(paymentRepositoryProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseBySlugProvider(widget.slug));
    final user = ref.watch(authStateProvider).value;

    return courseAsync.when(
      data: (course) {
        if (course == null) {
          return const Scaffold(
            body: Center(
              child: Text('Course not found'),
            ),
          );
        }

        final isEnrolled = user != null 
            ? ref.watch(isEnrolledProvider((uid: user.uid, courseId: course.id))).value ?? false
            : false;

        return _buildMainLayout(context, course, isEnrolled);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, __) => Scaffold(
        body: Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildMainLayout(BuildContext context, Course course, bool isEnrolled) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Course Overview',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
      ),
      body: isWide 
        ? _buildWideLayout(context, course, isEnrolled)
        : _buildMobileLayout(context, course, isEnrolled),
      bottomSheet: isWide ? null : _buildStickyBottomBar(context, course, isEnrolled),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Course course, bool isEnrolled) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoHero(context, course),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCourseHeader(course),
                const SizedBox(height: 24),
                _buildStatsGrid(course),
                const SizedBox(height: 32),
                _buildAboutSection(course),
                const SizedBox(height: 32),
                _buildObjectivesSection(course),
                const SizedBox(height: 32),
                _buildInstructorBio(course),
                const SizedBox(height: 32),
                _buildSectionTitle('Course Outline'),
                const SizedBox(height: 16),
                _buildOutlineList(context, course),
                const SizedBox(height: 120), // Bottom padding for sticky bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, Course course, bool isEnrolled) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Content
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseHeader(course),
                    const SizedBox(height: 40),
                    _buildAboutSection(course),
                    const SizedBox(height: 40),
                    _buildObjectivesSection(course),
                    const SizedBox(height: 40),
                    _buildInstructorBio(course),
                    const SizedBox(height: 40),
                    _buildSectionTitle('Course Outline'),
                    const SizedBox(height: 24),
                    _buildOutlineList(context, course),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              // Sidebar
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoHero(context, course),
                      const SizedBox(height: 32),
                      _buildSidebarPricing(context, course, isEnrolled),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 32),
                      Text(
                        'COURSE INCLUDES',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.slateGrey.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSidebarIncludeItem(Icons.movie_outlined, '12 hours of core content'),
                      _buildSidebarIncludeItem(Icons.assignment_outlined, '8 Graded Quizzes'),
                      _buildSidebarIncludeItem(Icons.all_inclusive, 'Full lifetime access'),
                      _buildSidebarIncludeItem(Icons.smartphone, 'Access on mobile and web'),
                      _buildSidebarIncludeItem(Icons.card_membership, 'Certificate of completion'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarPricing(BuildContext context, Course course, bool isEnrolled) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           course.isFree ? 'FREE' : '\$${course.price.toStringAsFixed(2)}',
           style: GoogleFonts.inter(
             fontSize: 32,
             fontWeight: FontWeight.bold,
             color: AppTheme.deepEmerald,
           ),
         ),
         const SizedBox(height: 24),
         SizedBox(
           width: double.infinity,
           child: ElevatedButton(
                onPressed: () => _handleEnrollment(context, course, isEnrolled),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.deepEmerald,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEnrolled ? 'Continue Learning' : 'Enroll Now',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                  ],
                ),
              ),
         ),
         const SizedBox(height: 16),
         Center(
           child: Text(
             '30-Day Money-Back Guarantee',
             style: GoogleFonts.inter(
               fontSize: 12,
               color: AppTheme.slateGrey.withValues(alpha: 0.5),
             ),
           ),
         ),
       ],
     );
  }

  Widget _buildSidebarIncludeItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.slateGrey.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.secondaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  // Factor out enrollment logic
  Future<void> _handleEnrollment(BuildContext context, Course course, bool isEnrolled) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      context.push('/login');
      return;
    }

    if (isEnrolled) {
      final lessons = await ref.read(lessonsProvider(course.id).future);
      if (lessons.isNotEmpty && context.mounted) {
        context.push('/courses/${course.slug}/${lessons.first.slug}');
      }
    } else if (course.isFree) {
      await ref.read(progressRepositoryProvider).enrollUser(
        uid: user.uid,
        courseId: course.id,
        accessType: 'free',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully enrolled!')),
        );
      }
    } else {
      try {
        final price = course.price;
        final orderId = await ref.read(paymentRepositoryProvider).createOrder(
          amount: price,
          currency: 'USD',
          courseId: course.id,
        );
        
        if (mounted) {
          ref.read(paymentRepositoryProvider).openCheckout(
            orderId: orderId,
            amount: price,
            name: course.title,
            description: 'Course Enrollment: ${course.title}',
            email: user.email ?? '',
            contact: '',
          );
        }
      } catch (e) {
         if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error initiating payment: $e')),
          );
        }
      }
    }
  }

  // --- SECTION BUILDERS ---

  Widget _buildAboutSection(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 24,
              width: 4,
              decoration: BoxDecoration(
                color: AppTheme.deepEmerald,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'About this course',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          course.description,
          style: GoogleFonts.inter(
            height: 1.6,
            color: AppTheme.slateGrey.withValues(alpha: 0.8),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildObjectivesSection(Course course) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F5), // Light green background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT YOU WILL LEARN',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppTheme.deepEmerald,
            ),
          ),
          const SizedBox(height: 16),
          ...course.objectives.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.deepEmerald, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.4,
                          color: AppTheme.secondaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOutlineList(BuildContext context, Course course) {
    return ref.watch(lessonsProvider(course.id)).when(
      data: (lessons) {
        if (lessons.isEmpty) return const Center(child: Text('No lessons available yet.'));
        return Column(
          children: lessons.map((lesson) => _buildLessonTile(context, lesson, course, lessons)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Text('Error loading outline: $err'),
    );
  }

  // --- SHARED UI COMPONENTS ---

  Widget _buildCourseHeader(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (course.isPopular)
              const MishkatBadge(type: MishkatBadgeType.bestseller),
            if (course.isPopular) const SizedBox(width: 12),
            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 4),
            Text(
              course.rating.toString(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.secondaryNavy,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${course.reviews} reviews)',
              style: GoogleFonts.inter(
                color: AppTheme.slateGrey.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          course.title,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Master the foundational principles of Islamic law through the lens of the Ahlulbayt (as).',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.slateGrey.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoHero(BuildContext context, Course course) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            course.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppTheme.sacredCream, child: const Icon(Icons.image, size: 50, color: AppTheme.slateGrey)),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.deepEmerald,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Preview course',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Course course) {
    return Row(
      children: [
        _buildStatBox(Icons.timer_outlined, course.duration, 'Duration'),
        const SizedBox(width: 12),
        _buildStatBox(Icons.bar_chart_outlined, course.level, 'Level'),
        const SizedBox(width: 12),
        _buildStatBox(Icons.verified_outlined, 'Certificate', 'Credential'),
      ],
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Light grey
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.deepEmerald, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.slateGrey.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.secondaryNavy,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorBio(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Instructor Bio'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFDE68A), Color(0xFFFDBA74)], // Amber to Orange
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: DecorationImage(
                        image: NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(course.instructor)}&background=C29E53&color=fff'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.instructor,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.secondaryNavy,
                          ),
                        ),
                        Text(
                          'Senior Scholar, Hawza Ilmiya',
                          style: GoogleFonts.inter(
                            color: AppTheme.secondaryNavy.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified, color: AppTheme.deepEmerald, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Instructor',
                              style: GoogleFonts.inter(
                                color: AppTheme.deepEmerald,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '"Education is not the learning of facts, but the training of the mind to think through the light of faith."',
                style: GoogleFonts.inter(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.secondaryNavy.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLessonTile(BuildContext context, Lesson lesson, Course course, List<Lesson> lessons) {
    final user = ref.watch(authStateProvider).value;
    final isEnrolled = user != null
        ? ref.watch(isEnrolledProvider((uid: user.uid, courseId: course.id))).value ?? false
        : false;
    return ref.watch(lessonPartsProvider((courseId: course.id, lessonId: lesson.id))).when(
      data: (parts) => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              'Part ${lessons.indexOf(lesson) + 1}: ${lesson.title}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.secondaryNavy,
              ),
            ),
            subtitle: Text(
              '${parts.length} Lessons • ${lesson.duration}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.slateGrey.withValues(alpha: 0.6),
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F7F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_rounded, color: AppTheme.deepEmerald, size: 20),
            ),
            iconColor: AppTheme.slateGrey,
            children: parts.map((part) {
              final isQuiz = part.type == 'quiz';
              return ListTile(
                dense: true,
                leading: Icon(
                  isQuiz ? Icons.help_outline_rounded : Icons.play_circle_outline_rounded,
                  size: 18,
                  color: isQuiz ? AppTheme.radiantGold : AppTheme.slateGrey.withValues(alpha: 0.4),
                ),
                title: Text(
                  '${parts.indexOf(part) + 1}. ${part.title}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.secondaryNavy.withValues(alpha: 0.8),
                  ),
                ),
                trailing: Text(
                  isQuiz ? 'Graded' : part.duration,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.slateGrey.withValues(alpha: 0.5),
                  ),
                ),
                onTap: isEnrolled
                    ? () => context.push('/courses/${course.slug}/${lesson.slug}')
                    : null,
              );
            }).toList(),
          ),
        ),
      ),
      loading: () => ListTile(title: Text(lesson.title), trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      error: (err, __) => ListTile(title: Text(lesson.title), subtitle: Text('Error: $err')),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context, Course course, bool isEnrolled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                   course.isFree ? 'FREE' : '\$${course.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepEmerald,
                  ),
                ),
                Text(
                  'Full lifetime access',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.slateGrey.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleEnrollment(context, course, isEnrolled),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppTheme.deepEmerald,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEnrolled ? 'Continue Learning' : 'Enroll Now',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
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

