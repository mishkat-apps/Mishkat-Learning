import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEnrollment {
  final String id; // uid_courseId
  final String uid;
  final String courseId;
  final DateTime enrolledAt;
  final DateTime lastUpdated;
  final String status; // active, revoked, completed
  final String accessType; // free, paid, manual
  final int progress;
  final List<String> completedParts;

  AdminEnrollment({
    required this.id,
    required this.uid,
    required this.courseId,
    required this.enrolledAt,
    required this.lastUpdated,
    required this.status,
    required this.accessType,
    this.progress = 0,
    this.completedParts = const [],
  });

  factory AdminEnrollment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminEnrollment(
      id: doc.id,
      uid: data['uid'] ?? '',
      courseId: data['courseId'] ?? '',
      enrolledAt: (data['enrolledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
      accessType: data['accessType'] ?? 'manual',
      progress: data['progress'] ?? 0,
      completedParts: List<String>.from(data['completedParts'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'courseId': courseId,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'status': status,
      'accessType': accessType,
      'progress': progress,
      'completedParts': completedParts,
    };
  }
}
