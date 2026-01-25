
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectArea {
  final String id;
  final String name;
  final String? alternativeName;
  final int order;

  SubjectArea({
    required this.id,
    required this.name,
    this.alternativeName,
    required this.order,
  });

  factory SubjectArea.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SubjectArea(
      id: doc.id,
      name: data['name'] ?? '',
      alternativeName: data['alternativeName'],
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'alternativeName': alternativeName,
      'order': order,
    };
  }
}
