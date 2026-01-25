import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/domain/admin_enrollment_model.dart';

part 'admin_enrollment_repository.g.dart';

class AdminEnrollmentRepository {
  final FirebaseFirestore _firestore;

  AdminEnrollmentRepository(this._firestore);

  Stream<List<AdminEnrollment>> watchEnrollments({String? uid, String? courseId}) {
    Query query = _firestore.collection('enrollments').orderBy('enrolledAt', descending: true);

    if (uid != null && uid.isNotEmpty) {
      query = query.where('uid', isEqualTo: uid);
    }
    if (courseId != null && courseId.isNotEmpty) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    return query.limit(100).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AdminEnrollment.fromFirestore(doc)).toList();
    });
  }

  Future<void> grantManualAccess({
    required String uid,
    required String courseId,
  }) async {
    final enrollmentId = '${uid}_$courseId';
    final now = DateTime.now();

    await _firestore.collection('enrollments').doc(enrollmentId).set({
      'uid': uid,
      'courseId': courseId,
      'enrolledAt': Timestamp.fromDate(now),
      'lastUpdated': Timestamp.fromDate(now),
      'status': 'active',
      'accessType': 'manual',
      'progress': 0,
      'completedParts': [],
    }, SetOptions(merge: true));
  }

  Future<void> revokeAccess(String enrollmentId) async {
    await _firestore.collection('enrollments').doc(enrollmentId).update({
      'status': 'revoked',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}

@riverpod
AdminEnrollmentRepository adminEnrollmentRepository(Ref ref) {
  return AdminEnrollmentRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<AdminEnrollment>> adminEnrollmentList(Ref ref, {String? uid, String? courseId}) {
  final repository = ref.watch(adminEnrollmentRepositoryProvider);
  return repository.watchEnrollments(uid: uid, courseId: courseId);
}
