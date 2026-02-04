import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/curriculum_models.dart';

class CurriculumRepository {
  final FirebaseFirestore _firestore;

  CurriculumRepository(this._firestore);

  // --- Lessons ---

  Stream<List<AdminLesson>> watchLessons(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => AdminLesson.fromFirestore(doc)).toList());
  }

  Future<void> reorderLessons(String courseId, List<AdminLesson> orderedLessons) async {
    final batch = _firestore.batch();
    for (int i = 0; i < orderedLessons.length; i++) {
      final docRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(orderedLessons[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  // --- Parts ---

  Stream<List<AdminLessonPart>> watchParts(String courseId, String lessonId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('parts')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => AdminLessonPart.fromFirestore(doc)).toList());
  }

  Future<void> reorderParts(String courseId, String lessonId, List<AdminLessonPart> orderedParts) async {
    final batch = _firestore.batch();
    for (int i = 0; i < orderedParts.length; i++) {
      final docRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('parts')
          .doc(orderedParts[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  // --- Actions ---

  Future<void> addLesson(String courseId, String title, int order) async {
    final slug = title.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
    await _firestore.collection('courses').doc(courseId).collection('lessons').add({
      'title': title,
      'slug': slug,
      'order': order,
      'duration': '0m',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLesson(String courseId, String lessonId, Map<String, dynamic> data) async {
    await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .update(data);
  }

  Future<void> deleteLesson(String courseId, String lessonId) async {
    // Note: In a real app, you'd want to delete sub-collections too
    await _firestore.collection('courses').doc(courseId).collection('lessons').doc(lessonId).delete();
  }

  Future<void> addPart(String courseId, String lessonId, AdminLessonPart part) async {
    await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('parts')
        .add(part.toFirestore()..remove('id'));
  }

  Future<void> updatePart(String courseId, String lessonId, String partId, Map<String, dynamic> data) async {
    await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('parts')
        .doc(partId)
        .update(data);
  }

  Future<void> deletePart(String courseId, String lessonId, String partId) async {
    await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('parts')
        .doc(partId)
        .delete();
  }
}

final curriculumRepositoryProvider = Provider((ref) {
  return CurriculumRepository(FirebaseFirestore.instance);
});

final lessonsListProvider = StreamProvider.family<List<AdminLesson>, String>((ref, courseId) {
  return ref.watch(curriculumRepositoryProvider).watchLessons(courseId);
});

final partsListProvider = StreamProvider.family<List<AdminLessonPart>, ({String courseId, String lessonId})>((ref, arg) {
  return ref.watch(curriculumRepositoryProvider).watchParts(arg.courseId, arg.lessonId);
});
