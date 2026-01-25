import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String slug;
  final String category;
  final int lessonCount;
  final String description;
  final String imageUrl;
  final String instructorId;
  final String instructorName;
  String get instructor => instructorName;
  final double rating;
  final int reviews;
  final int studentsCount;
  final String duration;
  final String level;
  final List<String> objectives;
  final List<String> subjectAreas;
  final String accessType; // 'free' | 'paid'
  bool get isFree => accessType == 'free';
  final double price;
  final bool isPopular;
  final bool isNew;
  final String? videoUrl;
  final int totalParts;
  final String tagline;
  final String instructorTitle;
  final String instructorQuote;
  final List<String> features;
  final String status; // 'draft' | 'published' | 'archived'
  final DateTime? publishedAt;
  final DateTime? updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.lessonCount,
    required this.description,
    required this.imageUrl,
    required this.instructorId,
    required this.instructorName,
    required this.rating,
    required this.reviews,
    required this.studentsCount,
    required this.duration,
    required this.level,
    required this.objectives,
    required this.subjectAreas,
    required this.accessType,
    required this.price,
    this.isPopular = false,
    this.isNew = false,
    this.videoUrl,
    this.totalParts = 0,
    required this.tagline,
    required this.instructorTitle,
    required this.instructorQuote,
    required this.features,
    this.status = 'published',
    this.publishedAt,
    this.updatedAt,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    String imageUrl = data['imageUrl'] ?? '';
    if (imageUrl.startsWith('gs://')) {
      imageUrl = '';
    }

    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      slug: data['slug'] ?? '',
      category: data['category'] ?? '',
      lessonCount: data['lessonCount'] ?? 0,
      description: data['about'] ?? data['description'] ?? '',
      imageUrl: imageUrl,
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? data['instructor'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: data['reviews'] ?? 0,
      studentsCount: data['studentsCount'] ?? 0,
      duration: data['duration'] ?? '',
      level: data['level'] ?? '',
      objectives: List<String>.from(data['objectives'] ?? []),
      subjectAreas: List<String>.from(data['subjectAreas'] ?? []),
      accessType: data['accessType'] ?? (data['isFree'] == true ? 'free' : 'paid'),
      price: (data['price'] ?? 0.0).toDouble(),
      isPopular: data['isPopular'] ?? false,
      isNew: data['isNew'] ?? false,
      videoUrl: data['videoUrl'],
      totalParts: data['totalParts'] ?? data['lessonCount'] ?? 0,
      tagline: data['tagline'] ?? '',
      instructorTitle: data['instructorTitle'] ?? '',
      instructorQuote: data['instructorQuote'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      status: data['status'] ?? 'published',
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static String? extractVimeoId(String? url) {
    if (url == null) return null;
    final regExp = RegExp(r'vimeo\.com\/(?:.*#|.*videos\/)?([0-9]+)');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}

class CourseReview {
  final String id;
  final String courseId;
  final String uid;
  final String userName;
  final String? userPhoto;
  final double rating;
  final String comment;
  final DateTime createdAt;

  CourseReview({
    required this.id,
    required this.courseId,
    required this.uid,
    required this.userName,
    this.userPhoto,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory CourseReview.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CourseReview(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      uid: data['uid'] ?? '',
      userName: data['userName'] ?? 'Anonymous Seeker',
      userPhoto: data['userPhoto'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'uid': uid,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
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
  final String slug;
  final int order;
  final String duration;
  final String? videoUrl;
  final String type; // 'video', 'quiz', 'reading'
  final String? transcript;

  LessonPart({
    required this.id,
    required this.title,
    required this.slug,
    required this.order,
    required this.duration,
    this.videoUrl,
    required this.type,
    this.transcript,
  });

  factory LessonPart.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return LessonPart(
      id: doc.id,
      title: data['title'] ?? '',
      slug: data['slug'] ?? '',
      order: data['order'] ?? 0,
      duration: data['duration'] ?? '',
      videoUrl: data['videoUrl'],
      type: data['type'] ?? 'video',
      transcript: data['transcript'],
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
