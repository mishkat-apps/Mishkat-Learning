import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MishkatUser {
  final String id;
  final String displayName;
  final String? photoUrl;
  final String email;
  final int enrolledCoursesCount;
  final int studyTimeMinutes;
  final List<String> certificates;
  final String rank;
  final String role;
  final DateTime? createdAt;

  MishkatUser({
    required this.id,
    required this.displayName,
    this.photoUrl,
    required this.email,
    this.enrolledCoursesCount = 0,
    this.studyTimeMinutes = 0,
    this.certificates = const [],
    this.rank = 'Seeker',
    this.role = 'student',
    this.createdAt,
  });

  factory MishkatUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MishkatUser(
      id: doc.id,
      displayName: data['displayName'] ?? 'Seeker',
      photoUrl: data['photoUrl'],
      email: data['email'] ?? '',
      enrolledCoursesCount: data['enrolledCoursesCount'] ?? 0,
      studyTimeMinutes: data['studyTimeMinutes'] ?? 0,
      certificates: List<String>.from(data['certificates'] ?? []),
      rank: data['rank'] ?? 'Seeker',
      role: data['role'] ?? 'student',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Stream<MishkatUser?> watchProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? MishkatUser.fromFirestore(doc) : null);
  }

  Future<MishkatUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? MishkatUser.fromFirestore(doc) : null;
  }

  Future<void> createUserProfile(MishkatUser user) async {
    await _firestore.collection('users').doc(user.id).set({
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'email': user.email,
      'enrolledCoursesCount': 0,
      'studyTimeMinutes': 0,
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfile(MishkatUser user) async {
    await _firestore.collection('users').doc(user.id).set({
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'email': user.email,
      'enrolledCoursesCount': user.enrolledCoursesCount,
      'studyTimeMinutes': user.studyTimeMinutes,
      'certificates': user.certificates,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> uploadProfilePicture(String uid, dynamic file) async {
    // Stub for image upload - in a real app this would use Firebase Storage
    debugPrint('Uploading profile picture for $uid...');
    return ''; // Return dummy URL or handle as needed
  }

}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final userProfileProvider = StreamProvider.family<MishkatUser?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).watchProfile(uid);
});

final userCourseCountProvider = StreamProvider.family<int, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('enrollments')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});
