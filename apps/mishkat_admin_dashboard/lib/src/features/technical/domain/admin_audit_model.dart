import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuditModel {
  final String id;
  final String actorUid;
  final String actionType;
  final String targetRef;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  AdminAuditModel({
    required this.id,
    required this.actorUid,
    required this.actionType,
    required this.targetRef,
    required this.metadata,
    required this.createdAt,
  });

  factory AdminAuditModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminAuditModel(
      id: doc.id,
      actorUid: data['actorUid'] ?? '',
      actionType: data['actionType'] ?? 'UNKNOWN',
      targetRef: data['targetRef'] ?? '',
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
