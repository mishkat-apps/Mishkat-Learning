import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_admin_dashboard/src/features/curriculum/data/curriculum_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/curriculum/domain/curriculum_models.dart';

class LessonPartEditor extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final AdminLessonPart? part; // If null, we are creating
  final int? nextOrder;

  const LessonPartEditor({
    super.key,
    required this.courseId,
    required this.lessonId,
    this.part,
    this.nextOrder,
  });

  @override
  State<LessonPartEditor> createState() => _LessonPartEditorState();
}

class _LessonPartEditorState extends State<LessonPartEditor> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _contentController = TextEditingController();
  String _type = 'video';

  @override
  void initState() {
    super.initState();
    if (widget.part != null) {
      _titleController.text = widget.part!.title;
      _durationController.text = widget.part!.duration;
      _videoUrlController.text = widget.part!.videoUrl ?? '';
      _contentController.text = widget.part!.content ?? '';
      _type = widget.part!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.part == null ? 'Add Lesson Part' : 'Edit Lesson Part'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Historical Context'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: ['video', 'reading', 'quiz'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(labelText: 'Duration (e.g., 10m)', hintText: '10m'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_type == 'video')
                TextField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(labelText: 'Video URL (Vimeo/YouTube)', hintText: 'https://vimeo.com/...'),
                ),
              if (_type == 'reading')
                TextField(
                  controller: _contentController,
                  maxLines: 15,
                  decoration: const InputDecoration(
                    labelText: 'Content (Markdown Supported)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_type == 'quiz')
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Quiz Editor is under development. Please use the "Reading" type for basic quiz instructions for now.', 
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orange)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        Consumer(
          builder: (context, ref, child) => ElevatedButton(
            onPressed: () async {
              final repo = ref.read(curriculumRepositoryProvider);
              final part = AdminLessonPart(
                id: widget.part?.id ?? '',
                title: _titleController.text,
                order: widget.part?.order ?? widget.nextOrder ?? 0,
                type: _type,
                duration: _durationController.text,
                videoUrl: _type == 'video' ? _videoUrlController.text : null,
                content: _type == 'reading' ? _contentController.text : null,
              );

              if (widget.part == null) {
                await repo.addPart(widget.courseId, widget.lessonId, part);
              } else {
                await repo.updatePart(widget.courseId, widget.lessonId, widget.part!.id, part.toFirestore());
              }
              
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(widget.part == null ? 'Add Part' : 'Save Changes'),
          ),
        ),
      ],
    );
  }
}
