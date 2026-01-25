import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCourseModel {
  final String id;
  final String title;
  final String? subtitle;
  final String status; // draft, active, archived
  final String accessType; // free, paid
  final double? price;
  final double? salePrice;
  final String type; // online, onsite
  final String? instructorId;
  final String? instructorName;
  final String? instructorTitle;
  final String? instructorQuote;
  final int enrolledCount;
  final String slug;
  final String category;
  final String description;
  final String? imageUrl;
  final String? tagline;
  final String? videoUrl;
  final String? duration;
  final String? level;
  final List<String> objectives;
  final List<String> subjectAreas;
  final List<String> features;
  final DateTime? publishedAt;
  final DateTime createdAt;

  AdminCourseModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.status,
    required this.accessType,
    this.price,
    this.salePrice,
    required this.type,
    this.instructorId,
    this.instructorName,
    this.instructorTitle,
    this.instructorQuote,
    this.enrolledCount = 0,
    required this.slug,
    required this.category,
    required this.description,
    this.imageUrl,
    this.tagline,
    this.videoUrl,
    this.duration,
    this.level,
    this.objectives = const [],
    this.subjectAreas = const [],
    this.features = const [],
    this.publishedAt,
    required this.createdAt,
  });

  factory AdminCourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // IMPORTANT: Learning app defaults missing status to 'published'
    String rawStatus = data['status'] ?? 'published';
    // Map 'published' to 'active' for admin UI consistency
    String mappedStatus = rawStatus == 'published' ? 'active' : rawStatus;

    String? imageUrl = data['imageUrl'] ?? data['image'];
    
    // Safety check: Filter out gs:// URLs which are not supported by Image.network
    if (imageUrl != null && imageUrl.startsWith('gs://')) {
      imageUrl = null; 
    }

    return AdminCourseModel(
      id: doc.id,
      title: data['title'] ?? 'Untitled Course',
      subtitle: data['subtitle'],
      status: mappedStatus,
      accessType: data['accessType'] ?? (data['isFree'] == true ? 'free' : 'paid'),
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['salePrice'] as num?)?.toDouble(),
      type: data['type'] ?? 'online',
      instructorId: data['instructorId'],
      instructorName: data['instructorName'] ?? data['instructor'],
      instructorTitle: data['instructorTitle'],
      instructorQuote: data['instructorQuote'],
      enrolledCount: data['enrolledCount'] ?? data['studentsCount'] ?? 0,
      slug: data['slug'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? data['about'] ?? '',
      imageUrl: imageUrl,
      tagline: data['tagline'],
      videoUrl: data['videoUrl'],
      duration: data['duration'],
      level: data['level'],
      objectives: List<String>.from(data['objectives'] ?? []),
      subjectAreas: List<String>.from(data['subjectAreas'] ?? []),
      features: List<String>.from(data['features'] ?? []),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
