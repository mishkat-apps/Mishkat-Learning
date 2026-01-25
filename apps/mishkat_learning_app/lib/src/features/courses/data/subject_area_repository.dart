
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/subject_area.dart';

class SubjectAreaRepository {
  final FirebaseFirestore _firestore;

  SubjectAreaRepository(this._firestore);

  Stream<List<SubjectArea>> watchSubjectAreas() {
    return _firestore
        .collection('subject_areas')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SubjectArea.fromFirestore(doc)).toList();
    });
  }

  Future<void> seedSubjectAreas() async {
    final subjects = [
      {'name': 'Aqaid', 'alternativeName': 'Worldview', 'order': 1},
      {'name': 'Akhlaq', 'alternativeName': 'Spirituality', 'order': 2},
      {'name': 'Ahkam', 'alternativeName': 'Islamic Laws', 'order': 3},
      {'name': 'Quran', 'alternativeName': 'Divine Book', 'order': 4},
      {'name': 'Ahl al-Bayt & Role Models', 'alternativeName': null, 'order': 5},
      {'name': 'Life Skills', 'alternativeName': null, 'order': 6},
      {'name': 'Basirah', 'alternativeName': 'Socio-political Awareness', 'order': 7},
      {'name': 'Miscellaneous', 'alternativeName': null, 'order': 8},
    ];

    final batch = _firestore.batch();
    for (var subject in subjects) {
      final docRef = _firestore.collection('subject_areas').doc();
      batch.set(docRef, subject);
    }
    await batch.commit();
  }
}

final subjectAreaRepositoryProvider = Provider<SubjectAreaRepository>((ref) {
  return SubjectAreaRepository(FirebaseFirestore.instance);
});

final subjectAreasProvider = StreamProvider<List<SubjectArea>>((ref) {
  return ref.watch(subjectAreaRepositoryProvider).watchSubjectAreas();
});
