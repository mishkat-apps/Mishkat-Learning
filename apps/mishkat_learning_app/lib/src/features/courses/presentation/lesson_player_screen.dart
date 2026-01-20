import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import '../../../theme/app_theme.dart';
import '../data/course_repository.dart';
import '../data/progress_repository.dart';
import '../domain/models.dart';
import '../../auth/data/auth_repository.dart';
import 'package:flutter/services.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final String courseSlug;
  final String? lessonSlug;
  final String? partSlug;

  const LessonPlayerScreen({
    super.key,
    required this.courseSlug,
    this.lessonSlug,
    this.partSlug,
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
  void didUpdateWidget(LessonPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lessonSlug != oldWidget.lessonSlug || widget.partSlug != oldWidget.partSlug) {
      // Slugs changed (e.g. back button pressed), update state might be handled in build,
      // but we need to reset active items if the URL changed drastically.
      // Usually Riverpod + build logic handles this if we derive state from args.
      // We'll rely on build to resolve the slugs to IDs.
      setState(() {
         // Force re-resolution
         _activeLessonId = null;
         _activePart = null;
      });
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPartSelected(LessonPart part, String lessonId, String courseId, String lessonSlug) {
    // Navigate to the new URL to preserve history
    context.go('/courses/${widget.courseSlug}/$lessonSlug/${part.slug}');
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.slateGrey),
        leading: BackButton(
          onPressed: () {
            // If in a deep link, maybe go back to course overview?
            // Default back button usually works fine with GoRouter history.
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/courses/${widget.courseSlug}');
            }
          },
        ),
      ),
      body: courseAsync.when(
        data: (course) {
          if (course == null) return const Center(child: Text('Course not found'));
          
          final lessonsAsync = ref.watch(lessonsProvider(course.id));
          
          return lessonsAsync.when(
            data: (lessons) {
              if (lessons.isEmpty) return const Center(child: Text('No lessons found'));
              
              // Resolve active lesson from slug if not already set or if url param dictates it
              Lesson? activeLesson;
              if (widget.lessonSlug != null) {
                 activeLesson = lessons.where((l) => l.slug == widget.lessonSlug).firstOrNull;
              }
              // Fallback to first if slug invalid or missing
              activeLesson ??= lessons.first;
              _activeLessonId = activeLesson.id;

              return isWide 
                ? _buildWideLayout(course, lessons, activeLesson)
                : _buildMobileLayout(course, lessons, activeLesson);
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

  Widget _buildWideLayout(Course course, List<Lesson> lessons, Lesson activeLesson) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildVideoPlayer(course.id, activeLesson),
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
                          _buildOverview(course),
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
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFFF0F0F0))),
          ),
          child: _buildPlaylist(course.id, lessons, activeLesson.id),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Course course, List<Lesson> lessons, Lesson activeLesson) {
    return Column(
      children: [
        _buildVideoPlayer(course.id, activeLesson),
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
              _buildPlaylist(course.id, lessons, activeLesson.id),
              _buildOverview(course),
              const Center(child: Text('Resources coming soon...')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(String courseId, Lesson activeLesson) {
    // Watch parts for the active lesson
    return ref.watch(lessonPartsProvider((courseId: courseId, lessonId: activeLesson.id))).when(
      data: (parts) {
        if (parts.isEmpty) {
           return _buildPlaceholder();
        }

        // Determine active part
        // 1. If widget.partSlug is set, try to find it
        // 2. Else if _activePart is set (local state), use it (though usually we sync state -> url -> build)
        // 3. Else default to first part
        
        LessonPart? targetPart;
        
        if (widget.partSlug != null) {
          targetPart = parts.where((p) => p.slug == widget.partSlug).firstOrNull;
        }
        
        // If we haven't found a part yet (slug missing or invalid), fallback to first
        targetPart ??= parts.first;

        // If the calculated target part is different from state, valid to update state/Url?
        // Ideally we just render it. The _activePart state might be redundant now if we purely rely on URL + derived data.
        // But for "Play Sample Video" button we need local state or URL push.
        
        // Let's use targetPart for rendering
        if (targetPart.videoUrl == null) return _buildPlaceholder();
        
        return _buildPlayerContainer(targetPart.videoUrl);
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildPlaceholder(),
    );
  }

  Widget _buildPlayerContainer(String? videoUrl) {
    final videoId = Course.extractVimeoId(videoUrl);
    
    if (videoId == null || videoId.isEmpty) return _buildPlaceholder();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: VimeoVideoPlayer(
          key: ValueKey(videoId), // Force player refresh on ID change
          videoId: videoId,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
     return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: AppTheme.radiantGold)),
      ),
    );
  }

  Widget _buildPlaceholder() {
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _activePart = LessonPart(
                      id: 'placeholder',
                      title: 'Start Learning',
                      order: 0,
                      duration: '',
                      type: 'intro',
                      slug: 'intro',
                    );
                  });
                },
                icon: const Icon(Icons.science, color: AppTheme.radiantGold),
                label: Text('Play Sample Video', style: TextStyle(color: AppTheme.radiantGold)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white10,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylist(String courseId, List<Lesson> lessons, String activeLessonId) {
    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return ExpansionTile(
          initiallyExpanded: lesson.id == activeLessonId,
          title: Text(
            lesson.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
              lesson: lesson, 
              activePartSlug: lesson.id == activeLessonId ? widget.partSlug : null,
              onPartSelected: (part) => _onPartSelected(part, lesson.id, courseId, lesson.slug),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverview(Course course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.slateGrey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            course.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppTheme.slateGrey.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonPartList extends ConsumerWidget {
  final String courseId;
  final Lesson lesson;
  final String? activePartSlug;
  final Function(LessonPart) onPartSelected;

  const _LessonPartList({
    required this.courseId,
    required this.lesson,
    required this.activePartSlug,
    required this.onPartSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(lessonPartsProvider((courseId: courseId, lessonId: lesson.id)));

    return partsAsync.when(
      data: (parts) {
        return Column(
          children: parts.map((part) {
            // Determine active based on slug if provided
            final isActive = activePartSlug != null && part.slug == activePartSlug;
            
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
