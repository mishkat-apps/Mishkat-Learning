import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentModel {
  final String id;
  final String uid;
  final String courseId;
  final double amount;
  final String currency;
  final String status;
  final String orderId;
  final String? paymentId;
  final DateTime createdAt;
  final String? method;
  final String? email;
  final String? contact;
  final String? signature;

  AdminPaymentModel({
    required this.id,
    required this.uid,
    required this.courseId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.orderId,
    this.paymentId,
    required this.createdAt,
    this.method,
    this.email,
    this.contact,
    this.signature,
  });

  factory AdminPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminPaymentModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      courseId: data['courseId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'INR',
      status: data['status'] ?? 'pending',
      orderId: data['razorpay_order_id'] ?? data['orderId'] ?? '',
      paymentId: data['razorpay_payment_id'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      method: data['method'],
      email: data['email'],
      contact: data['contact'],
      signature: data['razorpay_signature'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'courseId': courseId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'method': method,
      'email': email,
      'contact': contact,
    };
  }
}
