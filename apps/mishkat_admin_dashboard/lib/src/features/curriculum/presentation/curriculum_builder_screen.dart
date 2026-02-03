import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/curriculum/presentation/widgets/lesson_part_editor.dart';
import '../data/curriculum_repository.dart';
import '../domain/curriculum_models.dart';

class CurriculumBuilderScreen extends ConsumerWidget {
  final String courseId;
  final String courseTitle;

  const CurriculumBuilderScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsListProvider(courseId));

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Curriculum Builder', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
            Text(courseTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddLessonDialog(context, ref, (lessonsAsync.value?.length ?? 0)),
              icon: const Icon(Icons.add),
              label: const Text('Add Lesson'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.primaryEmerald,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: lessonsAsync.when(
        data: (lessons) => _LessonListView(courseId: courseId, lessons: lessons),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context, WidgetRef ref, int nextOrder) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lesson'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Lesson Title', hintText: 'e.g., Introduction to the Topic'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(curriculumRepositoryProvider).addLesson(courseId, controller.text, nextOrder);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _LessonListView extends ConsumerWidget {
  final String courseId;
  final List<AdminLesson> lessons;

  const _LessonListView({required this.courseId, required this.lessons});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: lessons.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final items = List<AdminLesson>.from(lessons);
        final item = items.removeAt(oldIndex);
        items.insert(newIndex, item);
        ref.read(curriculumRepositoryProvider).reorderLessons(courseId, items);
      },
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _LessonCard(
          key: ValueKey(lesson.id),
          courseId: courseId,
          lesson: lesson,
        );
      },
    );
  }
}

class _LessonCard extends ConsumerStatefulWidget {
  final String courseId;
  final AdminLesson lesson;

  const _LessonCard({super.key, required this.courseId, required this.lesson});

  @override
  ConsumerState<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends ConsumerState<_LessonCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final partsAsync = ref.watch(partsListProvider((courseId: widget.courseId, lessonId: widget.lesson.id)));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // Theme handles shape/border. Use background color.
      color: AdminTheme.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AdminTheme.zinc200),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTheme.zinc100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.drag_indicator, size: 16, color: AdminTheme.zinc500),
            ),
            title: Text(widget.lesson.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(
              widget.lesson.duration, 
              style: const TextStyle(fontSize: 12, color: AdminTheme.mutedForeground)
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isExpanded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AdminTheme.zinc100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${ref.watch(partsListProvider((courseId: widget.courseId, lessonId: widget.lesson.id))).asData?.value.length ?? 0} PARTS',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AdminTheme.zinc500),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, size: 20, color: AdminTheme.zinc900),
                  tooltip: 'Add Part',
                  onPressed: () => _showAddPartDialog(context),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 20, color: AdminTheme.zinc500),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20, color: AdminTheme.zinc500),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Title')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Lesson', style: TextStyle(color: AdminTheme.destructive))),
                  ],
                  onSelected: (val) {
                    if (val == 'delete') _confirmDelete(context);
                  },
                ),
              ],
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AdminTheme.zinc200)),
                color: AdminTheme.zinc50,
              ),
              child: partsAsync.when(
                data: (parts) => _PartListView(
                  courseId: widget.courseId,
                  lessonId: widget.lesson.id,
                  parts: parts,
                ),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                error: (err, stack) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $err', style: const TextStyle(color: AdminTheme.destructive))),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddPartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final parts = ref.read(partsListProvider((courseId: widget.courseId, lessonId: widget.lesson.id))).asData?.value ?? [];
          return LessonPartEditor(
            courseId: widget.courseId,
            lessonId: widget.lesson.id,
            nextOrder: parts.length,
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson?'),
        content: Text('This will delete "${widget.lesson.title}" and all its parts. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(curriculumRepositoryProvider).deleteLesson(widget.courseId, widget.lesson.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PartListView extends ConsumerWidget {
  final String courseId;
  final String lessonId;
  final List<AdminLessonPart> parts;

  const _PartListView({required this.courseId, required this.lessonId, required this.parts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (parts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No parts in this lesson. Add one to get started.', style: TextStyle(fontStyle: FontStyle.italic)),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parts.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final items = List<AdminLessonPart>.from(parts);
        final item = items.removeAt(oldIndex);
        items.insert(newIndex, item);
        ref.read(curriculumRepositoryProvider).reorderParts(courseId, lessonId, items);
      },
      itemBuilder: (context, index) {
        final part = parts[index];
        return Container(
          key: ValueKey(part.id),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AdminTheme.zinc200)),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(_getPartIcon(part.type), size: 18, color: AdminTheme.zinc600),
            title: Text(part.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text('${part.type.toUpperCase()} • ${part.duration}', style: const TextStyle(fontSize: 11, color: AdminTheme.mutedForeground)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AdminTheme.zinc500),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => LessonPartEditor(
                      courseId: courseId,
                      lessonId: lessonId,
                      part: part,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: AdminTheme.destructive),
                  onPressed: () => ref.read(curriculumRepositoryProvider).deletePart(courseId, lessonId, part.id),
                ),
                const Icon(Icons.drag_handle, size: 16, color: AdminTheme.zinc300),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getPartIcon(String type) {
    switch (type) {
      case 'video': return Icons.play_circle_outline;
      case 'reading': return Icons.article_outlined;
      case 'quiz': return Icons.quiz_outlined;
      default: return Icons.help_outline;
    }
  }
}
