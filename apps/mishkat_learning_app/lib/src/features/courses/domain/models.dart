import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String imageUrl;
  final String instructorId;
  final String instructorName;
  final double rating;
  final int studentsCount;
  final String duration;
  final String level;
  final List<String> objectives;
  final List<String> subjectAreas;
  final bool isFree;
  final double price;
  final String? videoUrl;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.instructorId,
    required this.instructorName,
    required this.rating,
    required this.studentsCount,
    required this.duration,
    required this.level,
    required this.objectives,
    required this.subjectAreas,
    required this.isFree,
    required this.price,
    this.videoUrl,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      slug: data['slug'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      studentsCount: data['studentsCount'] ?? 0,
      duration: data['duration'] ?? '',
      level: data['level'] ?? '',
      objectives: List<String>.from(data['objectives'] ?? []),
      subjectAreas: List<String>.from(data['subjectAreas'] ?? []),
      isFree: data['isFree'] ?? false,
      price: (data['price'] ?? 0.0).toDouble(),
      videoUrl: data['videoUrl'],
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String slug;
  final int order;
  final String duration;

  Lesson({
    required this.id,
    required this.title,
    required this.slug,
    required this.order,
    required this.duration,
  });

  factory Lesson.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Lesson(
      id: doc.id,
      title: data['title'] ?? '',
      slug: data['slug'] ?? '',
      order: data['order'] ?? 0,
      duration: data['duration'] ?? '',
    );
  }
}

class LessonPart {
  final String id;
  final String title;
  final int order;
  final String duration;
  final String? videoUrl;
  final String type; // 'video', 'quiz', 'reading'

  LessonPart({
    required this.id,
    required this.title,
    required this.order,
    required this.duration,
    this.videoUrl,
    required this.type,
  });

  factory LessonPart.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return LessonPart(
      id: doc.id,
      title: data['title'] ?? '',
      order: data['order'] ?? 0,
      duration: data['duration'] ?? '',
      videoUrl: data['videoUrl'],
      type: data['type'] ?? 'video',
    );
  }
}

class Enrollment {
  final String uid;
  final String courseId;
  final DateTime enrolledAt;
  final double progress;
  final String status;
  final String accessType;

  Enrollment({
    required this.uid,
    required this.courseId,
    required this.enrolledAt,
    required this.progress,
    required this.status,
    required this.accessType,
  });

  factory Enrollment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Enrollment(
      uid: data['uid'] ?? '',
      courseId: data['courseId'] ?? '',
      enrolledAt: (data['enrolledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progress: (data['progress'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'active',
      accessType: data['accessType'] ?? 'free',
    );
  }
}
