import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLesson {
  final String id;
  final String slug;
  final int order;
  final String duration;

  AdminLesson({
    required this.id,
    required this.title,
    required this.slug,
    required this.order,
    this.duration = '0m',
  });

  factory AdminLesson.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Auto-generate slug if missing
    String slug = data['slug'] ?? '';
    if (slug.isEmpty) {
      slug = (data['title'] as String).toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
    }

    return AdminLesson(
      id: doc.id,
      title: data['title'] ?? '',
      slug: slug,
      order: data['order'] ?? 0,
      duration: data['duration'] ?? '0m',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'slug': slug,
      'order': order,
      'duration': duration,
    };
  }
}

class AdminLessonPart {
  final String id;
  final String title;
  final String slug;
  final int order;
  final String type; // video, reading, quiz
  final String? videoUrl;
  final String? content; // Markdown/Article content
  final String duration;
  final String? transcript;

  AdminLessonPart({
    required this.id,
    required this.title,
    required this.slug,
    required this.order,
    required this.type,
    this.videoUrl,
    this.content,
    this.duration = '0m',
    this.transcript,
  });

  factory AdminLessonPart.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Auto-generate slug if missing from title
    String slug = data['slug'] ?? '';
    if (slug.isEmpty) {
      slug = (data['title'] as String).toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
    }

    return AdminLessonPart(
      id: doc.id,
      title: data['title'] ?? '',
      slug: slug,
      order: data['order'] ?? 0,
      type: data['type'] ?? 'video',
      videoUrl: data['videoUrl'],
      content: data['content'],
      duration: data['duration'] ?? '0m',
      transcript: data['transcript'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'slug': slug,
      'order': order,
      'type': type,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (content != null) 'content': content,
      'duration': duration,
      if (transcript != null) 'transcript': transcript,
    };
  }
}
