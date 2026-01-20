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

    return courseAsync.when(
      data: (course) {
        if (course == null) return const Scaffold(body: Center(child: Text('Course not found')));
        
        final lessonsAsync = ref.watch(lessonsProvider(course.id));
        
        return lessonsAsync.when(
          data: (lessons) {
            if (lessons.isEmpty) return const Scaffold(body: Center(child: Text('No parts found')));
            
            Lesson? activeLesson;
            if (widget.lessonSlug != null) {
               activeLesson = lessons.where((l) => l.slug == widget.lessonSlug).firstOrNull;
            }
            activeLesson ??= lessons.first;
            _activeLessonId = activeLesson.id;

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(
                  course.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.slateGrey,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppTheme.slateGrey),
                    onPressed: () {},
                  ),
                ],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.slateGrey, size: 20),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/courses/${widget.courseSlug}');
                    }
                  },
                ),
              ),
              body: isWide 
                ? _buildWideLayout(course, lessons, activeLesson)
                : _buildMobileLayout(course, lessons, activeLesson),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, _) => Scaffold(body: Center(child: Text('Error loading parts: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildWideLayout(Course course, List<Lesson> lessons, Lesson activeLesson) {
    // Similar to mobile but with side playlist
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: _buildScrollableContent(course, lessons, activeLesson),
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
    return _buildScrollableContent(course, lessons, activeLesson);
  }

  Widget _buildScrollableContent(Course course, List<Lesson> lessons, Lesson activePart) {
    final partsAsync = ref.watch(lessonPartsProvider((courseId: course.id, lessonId: activePart.id)));
    final user = ref.watch(authRepositoryProvider).currentUser;
    final progressAsync = user != null 
        ? ref.watch(userCourseProgressProvider((uid: user.uid, courseId: course.id)))
        : const AsyncValue<Map<String, dynamic>>.data(<String, dynamic>{});

    return Column(
      children: [
        _buildVideoPlayer(course.id, activePart),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                partsAsync.when(
                  data: (lessonParts) {
                    final currentLesson = _getCurrentLesson(lessonParts);
                    final partIndex = lessons.indexOf(activePart) + 1;
                    
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentLesson != null) ...[
                            Text(
                              'Lesson ${lessonParts.indexOf(currentLesson) + 1}: ${currentLesson.title}',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slateGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'Part $partIndex: ${activePart.title}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.slateGrey.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildModuleProgress(lessonParts, progressAsync.value ?? <String, dynamic>{}),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(height: 100),
                  error: (e, _) => Text('Error: $e'),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.deepEmerald,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.deepEmerald,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Lessons'),
                    Tab(text: 'Transcript'),
                    Tab(text: 'Resources'),
                  ],
                ),
                SizedBox(
                  height: 600, // Fixed height or adjust based on content
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlaylist(course.id, lessons, activePart.id),
                      _buildTranscript(course.id, activePart),
                      const Center(child: Text('Resources coming soon...')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LessonPart? _getCurrentLesson(List<LessonPart> parts) {
    if (widget.partSlug != null) {
      return parts.where((p) => p.slug == widget.partSlug).firstOrNull ?? parts.firstOrNull;
    }
    return parts.firstOrNull;
  }

  Widget _buildModuleProgress(List<LessonPart> lessons, Map<String, dynamic> progress) {
    final completedParts = progress['parts'] as Map<String, dynamic>? ?? {};
    int completedCount = 0;
    for (var lesson in lessons) {
      if (completedParts[lesson.id]?['completed'] == true) {
        completedCount++;
      }
    }
    
    final percent = lessons.isEmpty ? 0 : (completedCount / lessons.length * 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MODULE PROGRESS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateGrey,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$percent% complete',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF006B4D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: const Color(0xFF006B4D).withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006B4D)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(String courseId, Lesson activeLesson) {
    return ref.watch(lessonPartsProvider((courseId: courseId, lessonId: activeLesson.id))).when(
      data: (parts) {
        if (parts.isEmpty) return _buildPlaceholder();
        LessonPart? targetPart = _getCurrentLesson(parts) ?? parts.first;
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
          key: ValueKey(videoId),
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
        child: const Center(
          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
        ),
      ),
    );
  }

  Widget _buildPlaylist(String courseId, List<Lesson> lessons, String activeLessonId) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isExpanded = lesson.id == activeLessonId;
        
        return Column(
          children: [
            InkWell(
              onTap: () {
                // If not expanded, navigate to first part of this lesson
                if (!isExpanded) {
                  context.go('/courses/${widget.courseSlug}/${lesson.slug}');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                color: isExpanded ? const Color(0xFFE8F3EF).withOpacity(0.5) : Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Part ${index + 1}: ${lesson.title}',
                            style: GoogleFonts.inter(
                              fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                              color: AppTheme.slateGrey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.duration,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              _LessonPartList(
                courseId: courseId,
                lesson: lesson, 
                activePartSlug: widget.partSlug,
                onPartSelected: (part) => _onPartSelected(part, lesson.id, courseId, lesson.slug),
                courseSlug: widget.courseSlug,
              ),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ],
        );
      },
    );
  }

  Widget _buildTranscript(String courseId, Lesson activePart) {
    final partsAsync = ref.watch(lessonPartsProvider((courseId: courseId, lessonId: activePart.id)));
    
    return partsAsync.when(
      data: (parts) {
        final currentPart = _getCurrentLesson(parts);
        if (currentPart == null || currentPart.transcript == null || currentPart.transcript!.isEmpty) {
          return const Center(child: Text('No transcript available for this lesson.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            currentPart.transcript!,
            style: GoogleFonts.inter(
              height: 1.6,
              fontSize: 15,
              color: AppTheme.slateGrey,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading transcript')),
    );
  }
}

class _LessonPartList extends ConsumerWidget {
  final String courseId;
  final Lesson lesson;
  final String? activePartSlug;
  final Function(LessonPart) onPartSelected;
  final String courseSlug;

  const _LessonPartList({
    required this.courseId,
    required this.lesson,
    required this.activePartSlug,
    required this.onPartSelected,
    required this.courseSlug,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(lessonPartsProvider((courseId: courseId, lessonId: lesson.id)));
    final user = ref.watch(authRepositoryProvider).currentUser;
    final progressAsync = user != null 
        ? ref.watch(userCourseProgressProvider((uid: user.uid, courseId: courseId)))
        : const AsyncValue<Map<String, dynamic>>.data(<String, dynamic>{});

    return partsAsync.when(
      data: (parts) {
        return Container(
          color: const Color(0xFFE8F3EF).withOpacity(0.5),
          child: Column(
            children: parts.map((part) {
              final index = parts.indexOf(part) + 1;
              final isActive = (activePartSlug == null && index == 1) || part.slug == activePartSlug;
              final completedParts = progressAsync.value?['parts'] as Map<String, dynamic>? ?? <String, dynamic>{};
              final isCompleted = completedParts[part.id]?['completed'] == true;
              
              return InkWell(
                onTap: () => onPartSelected(part),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted ? const Color(0xFF006B4D) : Colors.grey.withOpacity(0.3),
                            width: 1.5,
                          ),
                          color: isCompleted ? const Color(0xFF006B4D) : Colors.transparent,
                        ),
                        child: Center(
                          child: isCompleted 
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '$index',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$index. ${part.title}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: AppTheme.slateGrey,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${part.duration} • ',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  isActive ? 'Now Playing' : (isCompleted ? 'Completed' : ''),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isActive ? const Color(0xFF006B4D) : Colors.grey,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.bar_chart, color: Color(0xFF006B4D))
                      else if (isCompleted)
                         const Icon(Icons.play_circle_fill, color: Colors.grey)
                      else
                        const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                      
                      // MARK AS COMPLETE BUTTON (UI only for now, logic needs to be connected)
                      if (isActive && !isCompleted)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Color(0xFF006B4D)),
                          onPressed: () {
                            if (user != null) {
                              ref.read(progressRepositoryProvider).updatePartProgress(
                                uid: user.uid,
                                courseId: courseId,
                                lessonId: lesson.id,
                                partId: part.id,
                                completed: true,
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
