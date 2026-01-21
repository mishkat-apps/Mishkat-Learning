import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository(this._firestore);

  Stream<bool> watchEnrollmentStatus(String uid, String courseId) {
    return _firestore
        .collection('enrollments')
        .doc('${uid}_$courseId')
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
    required int totalParts,
  }) async {
    // 1. Update user-specific detailed progress
    final userProgressRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId);

    await userProgressRef.set({
      'parts': {
        partId: {
          'completed': completed,
          'lastUpdated': FieldValue.serverTimestamp(),
        }
      },
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Update global enrollment record for progress tracking
    final enrollmentRef = _firestore.collection('enrollments').doc('${uid}_$courseId');
    
    // Get existing enrollment to calculate new progress
    final enrollmentDoc = await enrollmentRef.get();
    List completedParts = [];
    
    if (enrollmentDoc.exists) {
      completedParts = List.from(enrollmentDoc.data()?['completedParts'] ?? []);
    }

    if (completed) {
      if (!completedParts.contains(partId)) {
        completedParts.add(partId);
      }
    } else {
      completedParts.remove(partId);
    }

    final newProgress = totalParts > 0 
        ? (completedParts.length / totalParts) * 100 
        : 0.0;

    await enrollmentRef.set({
      'completedParts': completedParts,
      'progress': newProgress,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> enrollUser({
    required String uid,
    required String courseId,
    String accessType = 'free',
  }) async {
    final userProgressRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId);

    await userProgressRef.set({
      'enrolledAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final enrollmentRef = _firestore.collection('enrollments').doc('${uid}_$courseId');
    await enrollmentRef.set({
      'uid': uid,
      'courseId': courseId,
      'enrolledAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'progress': 0.0,
      'completedParts': [],
      'accessType': accessType,
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
