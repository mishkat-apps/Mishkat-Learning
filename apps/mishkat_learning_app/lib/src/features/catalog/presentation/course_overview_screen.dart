import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_learning_app/src/features/courses/data/course_repository.dart';
import 'package:mishkat_learning_app/src/features/courses/data/progress_repository.dart';
import 'package:mishkat_learning_app/src/features/auth/data/auth_repository.dart';
import 'package:mishkat_learning_app/src/features/courses/domain/models.dart';
import 'package:mishkat_learning_app/src/features/payments/data/payment_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CourseOverviewScreen extends ConsumerStatefulWidget {
  final String slug;
  const CourseOverviewScreen({super.key, required this.slug});

  @override
  ConsumerState<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends ConsumerState<CourseOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize Razorpay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentRepositoryProvider).init(
        _handlePaymentSuccess,
        _handlePaymentError,
        _handleExternalWallet,
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
    _tabController.dispose();
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 1100;
            if (isWide) {
              return _buildWideLayout(context, constraints, course, isEnrolled);
            }
            return _buildMobileLayout(context, course, isEnrolled);
          },
        );
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

  Widget _buildMobileLayout(BuildContext context, Course course, bool isEnrolled) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoHero(context, course),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseHeader(course),
                  const SizedBox(height: 24),
                  _buildStatsGrid(course),
                  const SizedBox(height: 32),
                  // Tabs for About and Objectives on Mobile
                  Material(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppTheme.deepEmerald,
                      unselectedLabelColor: AppTheme.slateGrey,
                      indicatorColor: AppTheme.deepEmerald,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 15),
                      tabs: const [
                        Tab(text: 'About'),
                        Tab(text: 'Objectives'),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250, // Fixed height for tabs in mobile scroll
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAboutSection(course),
                        _buildObjectivesSection(course),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Course Outline'),
                  const SizedBox(height: 16),
                  _buildOutlineList(context, course),
                  const SizedBox(height: 32),
                  _buildInstructorBio(course),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildStickyBottomBar(context, course, isEnrolled),
    );
  }

  Widget _buildWideLayout(BuildContext context, BoxConstraints constraints, Course course, bool isEnrolled) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Hero -> Header -> Stats -> Tabs -> Bio
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoHero(context, course),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCourseHeader(course),
                        const SizedBox(height: 24),
                        _buildStatsGrid(course),
                        const SizedBox(height: 32),
                        // Tabs for About and Objectives
                        Material(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelColor: AppTheme.deepEmerald,
                            unselectedLabelColor: AppTheme.slateGrey,
                            indicatorColor: AppTheme.deepEmerald,
                            indicatorWeight: 3,
                            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
                            tabs: const [
                              Tab(text: 'About'),
                              Tab(text: 'Objectives'),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildAboutSection(course),
                              _buildObjectivesSection(course),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildInstructorBio(course),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // Right Side: Outline
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    'Course Outline',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _buildOutlineList(context, course),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildStickyBottomBar(context, course, isEnrolled),
    );
  }

  // --- SECTION BUILDERS ---

  Widget _buildAboutSection(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this Course',
          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          course.about,
          style: const TextStyle(height: 1.6, color: AppTheme.slateGrey, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildObjectivesSection(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you will learn',
          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...course.objectives.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.deepEmerald, size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildOutlineList(BuildContext context, Course course) {
    return ref.watch(lessonsStreamProvider(course.id)).when(
      data: (lessons) {
        if (lessons.isEmpty) return const Center(child: Text('No lessons available yet.'));
        return Column(
          children: lessons.map((lesson) => _buildLessonTile(context, lesson, course)).toList(),
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
        Text(
          course.title,
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepEmerald,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: AppTheme.radiantGold, size: 20),
            const SizedBox(width: 4),
            Text(course.rating.toString(), style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('(${course.reviews} reviews)', style: const TextStyle(color: AppTheme.slateGrey)),
          ],
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
                onPressed: () => context.pop(),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.radiantGold, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: AppTheme.slateGrey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorBio(Course course) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 32, backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(course.instructor)}&background=C29E53&color=fff')),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(course.instructor, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: AppTheme.deepEmerald, size: 16),
                  ],
                ),
                const Text('Professor of Islamic Studies', style: TextStyle(color: AppTheme.slateGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLessonTile(BuildContext context, Lesson lesson, Course course) {
    return ref.watch(lessonPartsStreamProvider((courseId: course.id, lessonId: lesson.id))).when(
      data: (parts) => ExpansionTile(
        title: Text(lesson.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
        children: parts.map((part) {
          final isQuiz = part.isQuiz;
          return ListTile(
            leading: Icon(
              isQuiz ? Icons.quiz_outlined : Icons.lock_outline,
              size: 18,
              color: isQuiz ? AppTheme.radiantGold : AppTheme.slateGrey.withValues(alpha: 0.4),
            ),
            title: Text(
              part.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isQuiz ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Text(
              isQuiz ? 'Graded' : part.duration,
              style: const TextStyle(fontSize: 12, color: AppTheme.slateGrey),
            ),
            onTap: () {
              context.push('/browse/${course.slug}/lessons/${part.slug}');
            },
          );
        }).toList(),
      ),
      loading: () => ListTile(title: Text(lesson.title), trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      error: (err, __) => ListTile(title: Text(lesson.title), subtitle: Text('Error: $err')),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context, Course course, bool isEnrolled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
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
                  course.isFree ? 'FREE' : '\$${course.price?.toStringAsFixed(2) ?? "10.00"}',
                  style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.deepEmerald),
                ),
                const Text('Full lifetime access', style: TextStyle(fontSize: 12, color: AppTheme.slateGrey)),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(authStateProvider).value;
                if (user == null) {
                  context.push('/login');
                  return;
                }

                if (isEnrolled) {
                  // Navigate to the first lesson part
                  final lessons = await ref.read(lessonsStreamProvider(course.id).future);
                  if (lessons.isNotEmpty) {
                    final parts = await ref.read(lessonPartsStreamProvider((courseId: course.id, lessonId: lessons.first.id)).future);
                    if (parts.isNotEmpty) {
                      context.push('/browse/${course.slug}/lessons/${parts.first.slug}');
                    }
                  }
                } else if (course.isFree) {
                  // Enroll the user directly for free courses
                  await ref.read(progressRepositoryProvider).enrollUser(
                    uid: user.uid,
                    courseId: course.id,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully enrolled!')),
                    );
                  }
                } else {
                  // Process payment for paid courses
                  try {
                    final price = course.price ?? 10.0;
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
                        contact: '', // Optional
                      );
                    }
                  } catch (e) {
                     if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error initiating payment: $e')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              ),
              child: Row(
                children: [
                  Text(isEnrolled ? 'Continue Learning' : 'Enroll Now'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

