import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository(this._firestore);

  Stream<bool> watchEnrollmentStatus(String uid, String courseId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<Map<String, dynamic>> watchUserProgress(String uid, String courseId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  Future<void> updateLessonProgress({
    required String uid,
    required String courseId,
    required String lessonId,
    required double progress,
    bool completed = false,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId);

    await docRef.set({
      'lastLessonId': lessonId,
      'lessons': {
        lessonId: {
          'progress': progress,
          'completed': completed,
          'lastUpdated': FieldValue.serverTimestamp(),
        }
      },
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updatePartProgress({
    required String uid,
    required String courseId,
    required String lessonId,
    required String partId,
    required bool completed,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId);

    await docRef.set({
      'parts': {
        partId: {
          'completed': completed,
          'lastUpdated': FieldValue.serverTimestamp(),
        }
      },
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> enrollUser({
    required String uid,
    required String courseId,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId);

    await docRef.set({
      'enrolledAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'progress': 0.0,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(FirebaseFirestore.instance);
});

final isEnrolledProvider = StreamProvider.family<bool, ({String uid, String courseId})>((ref, arg) {
  return ref.watch(progressRepositoryProvider).watchEnrollmentStatus(arg.uid, arg.courseId);
});

final userCourseProgressProvider = StreamProvider.family<Map<String, dynamic>, ({String uid, String courseId})>((ref, arg) {
  return ref.watch(progressRepositoryProvider).watchUserProgress(arg.uid, arg.courseId);
});
