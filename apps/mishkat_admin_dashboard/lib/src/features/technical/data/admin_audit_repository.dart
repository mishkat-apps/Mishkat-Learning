import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mishkat_admin_dashboard/src/features/technical/domain/admin_audit_model.dart';

part 'admin_audit_repository.g.dart';

class AdminAuditRepository {
  final FirebaseFirestore _firestore;

  AdminAuditRepository(this._firestore);

  Stream<List<AdminAuditModel>> watchAuditLogs({int limit = 50}) {
    return _firestore
        .collection('audit_logs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AdminAuditModel.fromFirestore(doc)).toList();
    });
  }
}

@riverpod
AdminAuditRepository adminAuditRepository(Ref ref) {
  return AdminAuditRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<AdminAuditModel>> adminAuditLogs(Ref ref, {int limit = 50}) {
  return ref.watch(adminAuditRepositoryProvider).watchAuditLogs(limit: limit);
}
