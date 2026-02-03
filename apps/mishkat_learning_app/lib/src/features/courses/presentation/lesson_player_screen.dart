import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import '../../../theme/app_theme.dart';
import '../data/course_repository.dart';
import '../data/progress_repository.dart';
import '../domain/models.dart';
import '../../ai/data/ai_repository.dart';
import '../../auth/data/auth_repository.dart';
import 'widgets/universal_video_player.dart';

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
  String? _expandedLessonId;
  bool _isTranscribing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didUpdateWidget(LessonPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lessonSlug != oldWidget.lessonSlug || widget.partSlug != oldWidget.partSlug) {
      setState(() {
         // Force re-resolution
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
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 1100;
    
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
            _expandedLessonId ??= activeLesson.id;

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(
                  course.title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
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
    return Row(
      children: [
        // Left Column: Video + Details + Tabs (Transcript/Resources)
        Expanded(
          flex: 65,
          child: Column(
            children: [
              _buildVideoPlayer(course.id, activeLesson),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLessonHeader(course, lessons, activeLesson),
                      const SizedBox(height: 24),
                      _buildTabsSection(course, activeLesson, excludeLessons: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Right Column: Sticky Playlist
        Expanded(
          flex: 35,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(Icons.list_alt_rounded, color: AppTheme.deepEmerald),
                      const SizedBox(width: 12),
                      Text(
                        'Course Content',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildPlaylist(course.id, lessons, activeLesson.id, course.totalParts),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Course course, List<Lesson> lessons, Lesson activeLesson) {
    return Column(
      children: [
        _buildVideoPlayer(course.id, activeLesson),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLessonHeader(course, lessons, activeLesson),
                const SizedBox(height: 24),
                _buildTabsSection(course, activeLesson, excludeLessons: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonHeader(Course course, List<Lesson> lessons, Lesson activeLesson) {
    final partsAsync = ref.watch(lessonPartsProvider((courseId: course.id, lessonId: activeLesson.id)));
    final user = ref.watch(authRepositoryProvider).currentUser;
    final progressAsync = user != null 
        ? ref.watch(userCourseProgressProvider((uid: user.uid, courseId: course.id)))
        : const AsyncValue<Map<String, dynamic>>.data(<String, dynamic>{});

    return partsAsync.when(
      data: (lessonParts) {
        final currentLesson = _getCurrentLesson(lessonParts);
        final partIndex = lessons.indexOf(activeLesson) + 1;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentLesson != null) ...[
                Text(
                  'Lesson ${lessonParts.indexOf(currentLesson) + 1}: ${currentLesson.title}',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Part $partIndex: ${activeLesson.title}',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.slateGrey.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              _buildModuleProgress(lessonParts, progressAsync.value ?? <String, dynamic>{}),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text('Error: $e'),
      ),
    );
  }

  Widget _buildTabsSection(Course course, Lesson activeLesson, {required bool excludeLessons}) {
    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];

    if (!excludeLessons) {
      tabs.add(const Tab(text: 'Lessons'));
      tabViews.add(
        ref.watch(lessonsProvider(course.id)).when(
          data: (lessons) => _buildPlaylist(course.id, lessons, activeLesson.id, course.totalParts),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      );
    }

    tabs.add(const Tab(text: 'Transcript'));
    tabViews.add(_buildTranscript(course.id, activeLesson));

    tabs.add(const Tab(text: 'Resources'));
    tabViews.add(const Center(child: Text('Resources coming soon...')));

    // We need a temporary controller if the count changed or isn't 3
    final controller = excludeLessons 
        ? TabController(length: tabs.length, vsync: this)
        : _tabController;

    return Column(
      children: [
        TabBar(
          controller: controller,
          labelColor: AppTheme.deepEmerald,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.deepEmerald,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.grey.withValues(alpha: 0.1),
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: tabs,
        ),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: controller,
            children: tabViews,
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
    
    final percent = lessons.isEmpty ? 0.0 : (completedCount / lessons.length);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryNavy.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLLECTION PROGRESS',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.radiantGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.radiantGold),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completedCount of ${lessons.length} lessons completed',
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
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
    if (videoUrl == null || videoUrl.isEmpty) return _buildPlaceholder();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: UniversalVideoPlayer(
        key: ValueKey(videoUrl),
        videoUrl: videoUrl,
        autoPlay: false,
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

  Widget _buildPlaylist(String courseId, List<Lesson> lessons, String activePartId, int totalParts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isExpanded = _expandedLessonId == lesson.id;
        
        return Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedLessonId = isExpanded ? null : lesson.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                color: isExpanded ? AppTheme.deepEmerald.withValues(alpha: 0.05) : Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Part ${index + 1}: ${lesson.title}',
                            style: GoogleFonts.roboto(
                              fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                              color: AppTheme.slateGrey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.duration,
                            style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
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
                totalParts: totalParts,
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
        if (currentPart == null) return const SizedBox.shrink();

        final hasTranscript = currentPart.transcript != null && currentPart.transcript!.isNotEmpty;

        if (!hasTranscript) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.softGold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppTheme.softGold, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Transcript Yet',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We can generate a high-quality transcript using AI in real-time.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: AppTheme.slateGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isTranscribing ? null : () async {
                      setState(() => _isTranscribing = true);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref.read(aiRepositoryProvider).generateTranscript(
                          courseId: courseId,
                          lessonId: activePart.id,
                          partId: currentPart.id,
                          videoUrl: currentPart.videoUrl ?? '',
                        );
                        // The stream will automatically update once Firestore changes
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Failed to generate transcript: $e')),
                        );
                      } finally {
                        if (mounted) setState(() => _isTranscribing = false);
                      }
                    },
                    icon: _isTranscribing 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(_isTranscribing ? 'Generating...' : 'Generate with AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.deepEmerald.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppTheme.deepEmerald),
                    const SizedBox(width: 6),
                    Text(
                      'AI Generated Transcript',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepEmerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentPart.transcript!,
                style: GoogleFonts.roboto(
                  height: 1.8,
                  fontSize: 15,
                  color: AppTheme.slateGrey,
                ),
              ),
            ],
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
  final int totalParts;

  const _LessonPartList({
    required this.courseId,
    required this.lesson,
    required this.activePartSlug,
    required this.onPartSelected,
    required this.courseSlug,
    required this.totalParts,
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
          color: const Color(0xFFE8F3EF).withValues(alpha: 0.5),
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
                            color: isCompleted ? const Color(0xFF006B4D) : Colors.grey.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          color: isCompleted ? const Color(0xFF006B4D) : Colors.transparent,
                        ),
                        child: Center(
                          child: isCompleted 
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '$index',
                                style: GoogleFonts.roboto(
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
                              style: GoogleFonts.roboto(
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
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  isActive ? 'Now Playing' : (isCompleted ? 'Completed' : ''),
                                  style: GoogleFonts.roboto(
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
                                  totalParts: totalParts,
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
