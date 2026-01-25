import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mishkat_admin_dashboard/src/features/payments/domain/admin_payment_model.dart';

part 'admin_payment_repository.g.dart';

class AdminPaymentRepository {
  final FirebaseFirestore _firestore;

  AdminPaymentRepository(this._firestore);

  Stream<List<AdminPaymentModel>> watchPayments({int limit = 20, String? status}) {
    Query query = _firestore.collection('payments').orderBy('createdAt', descending: true);

    if (status != null && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AdminPaymentModel.fromFirestore(doc)).toList();
    });
  }

  Future<AdminPaymentModel> getPayment(String id) async {
    final doc = await _firestore.collection('payments').doc(id).get();
    if (!doc.exists) {
      throw Exception('Payment not found');
    }
    return AdminPaymentModel.fromFirestore(doc);
  }
}

@riverpod
AdminPaymentRepository adminPaymentRepository(Ref ref) {
  return AdminPaymentRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<AdminPaymentModel>> adminPaymentList(Ref ref, {int limit = 50, String? status}) {
  return ref.watch(adminPaymentRepositoryProvider).watchPayments(limit: limit, status: status);
}

@riverpod
Future<AdminPaymentModel> adminPaymentDetails(Ref ref, String id) {
  return ref.watch(adminPaymentRepositoryProvider).getPayment(id);
}
