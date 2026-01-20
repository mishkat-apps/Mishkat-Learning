import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import 'package:mishkat_learning_app/src/features/courses/data/course_repository.dart';
import 'package:mishkat_learning_app/src/features/courses/data/progress_repository.dart';
import 'package:mishkat_learning_app/src/features/courses/domain/models.dart';
import 'package:mishkat_learning_app/src/features/auth/data/auth_repository.dart';
import 'package:flutter/services.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final String courseSlug;
  final String? lessonSlug;

  const LessonPlayerScreen({
    super.key,
    required this.courseSlug,
    this.lessonSlug,
  });

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _activeLessonId;
  LessonPart? _activePart;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPartSelected(LessonPart part, String lessonId, String courseId) {
    setState(() {
      _activePart = part;
      _activeLessonId = lessonId;
    });
    
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      ref.read(progressRepositoryProvider).updateLessonProgress(
        uid: user.uid,
        courseId: courseId,
        lessonId: lessonId,
        progress: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1100;
    
    final courseAsync = ref.watch(courseBySlugProvider(widget.courseSlug));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Lesson Player',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.slateGrey),
      ),
      body: courseAsync.when(
        data: (course) {
          if (course == null) return const Center(child: Text('Course not found'));
          
          final lessonsAsync = ref.watch(lessonsProvider(course.id));
          
          return lessonsAsync.when(
            data: (lessons) {
              if (lessons.isEmpty) return const Center(child: Text('No lessons found'));
              
              if (_activeLessonId == null && lessons.isNotEmpty) {
                _activeLessonId = lessons.first.id;
              }

              return isWide 
                ? _buildWideLayout(course.id, lessons)
                : _buildMobileLayout(course.id, lessons);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading lessons: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildWideLayout(String courseId, List<Lesson> lessons) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildVideoPlayer(),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.deepEmerald,
                      unselectedLabelColor: AppTheme.slateGrey,
                      indicatorColor: AppTheme.deepEmerald,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Resources'),
                        Tab(text: 'Discussion'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverview(),
                          const Center(child: Text('Resources coming soon...')),
                          const Center(child: Text('Discussion coming soon...')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 380,
          border: const Border(left: BorderSide(color: Color(0xFFF0F0F0))),
          child: _buildPlaylist(courseId, lessons),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(String courseId, List<Lesson> lessons) {
    return Column(
      children: [
        _buildVideoPlayer(),
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.deepEmerald,
          unselectedLabelColor: AppTheme.slateGrey,
          indicatorColor: AppTheme.deepEmerald,
          tabs: const [
            Tab(text: 'Lessons'),
            Tab(text: 'Overview'),
            Tab(text: 'Resources'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPlaylist(courseId, lessons),
              _buildOverview(),
              const Center(child: Text('Resources coming soon...')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_activePart == null || _activePart!.videoUrl == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Select a lesson to start learning',
                  style: GoogleFonts.montserrat(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VimeoVideoPlayer(
        vimeoPlayerModel: VimeoPlayerModel(
          url: _activePart!.videoUrl!,
          deviceOrientation: DeviceOrientation.landscapeLeft,
          systemUiOverlay: const [],
        ),
      ),
    );
  }

  Widget _buildPlaylist(String courseId, List<Lesson> lessons) {
    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return ExpansionTile(
          initiallyExpanded: lesson.id == _activeLessonId,
          title: Text(
            lesson.title,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.slateGrey,
            ),
          ),
          subtitle: Text(
            lesson.duration,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          children: [
            _LessonPartList(
              courseId: courseId,
              lessonId: lesson.id,
              activePartId: _activePart?.id,
              onPartSelected: (part) => _onPartSelected(part, lesson.id, courseId),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _activePart?.title ?? 'Select a lesson',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.slateGrey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'In this lesson, we cover essential concepts of Islamic theology. Follow along with the video and use the resources provided in the next tab.',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: AppTheme.slateGrey.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonPartList extends ConsumerWidget {
  final String courseId;
  final String lessonId;
  final String? activePartId;
  final Function(LessonPart) onPartSelected;

  const _LessonPartList({
    required this.courseId,
    required this.lessonId,
    required this.activePartId,
    required this.onPartSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(lessonPartsProvider((courseId: courseId, lessonId: lessonId)));

    return partsAsync.when(
      data: (parts) {
        return Column(
          children: parts.map((part) {
            final isActive = part.id == activePartId;
            return ListTile(
              leading: Icon(
                isActive ? Icons.play_circle_fill : Icons.play_circle_outline,
                color: isActive ? AppTheme.deepEmerald : Colors.grey,
              ),
              title: Text(
                part.title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? AppTheme.deepEmerald : AppTheme.slateGrey,
                ),
              ),
              trailing: Text(part.duration, style: const TextStyle(fontSize: 11)),
              onTap: () => onPartSelected(part),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading parts'),
    );
  }
}
