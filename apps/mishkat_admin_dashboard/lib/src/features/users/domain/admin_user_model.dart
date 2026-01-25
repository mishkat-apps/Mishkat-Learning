import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // admin, teacher, student
  final String rank;
  final DateTime createdAt;
  final bool isActive;
  final int enrolledCoursesCount;

  AdminUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.rank,
    required this.createdAt,
    this.isActive = true,
    this.enrolledCoursesCount = 0,
  });

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'No Name',
      photoUrl: data['photoUrl'],
      role: (data['role'] as String?)?.toLowerCase() ?? 'student',
      rank: data['rank'] ?? 'Seeker',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      enrolledCoursesCount: data['enrolledCoursesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'role': role,
      'rank': rank,
      'isActive': isActive,
    };
  }
}
