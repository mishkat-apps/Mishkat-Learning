import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:typed_data';
import '../domain/admin_course_model.dart';

part 'admin_course_repository.g.dart';

class AdminCourseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AdminCourseRepository(this._firestore);

  Stream<List<AdminCourseModel>> watchCourses() {
    Query<Map<String, dynamic>> query = _firestore.collection('courses');
    
    return query.snapshots().map((snapshot) {
      final courses = snapshot.docs
          .map((doc) => AdminCourseModel.fromFirestore(doc))
          .toList();
      
      courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return courses;
    });
  }

  Future<String> uploadCourseThumbnail(Uint8List bytes, String fileName) async {
    final ref = _storage.ref().child('courses/thumbnails/$fileName');
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<void> createCourse(Map<String, dynamic> data) async {
    final docRef = _firestore.collection('courses').doc();
    final finalData = Map<String, dynamic>.from(data);
    
    // Auto-calculate access type
    final price = finalData['price'] as num? ?? 0.0;
    finalData['accessType'] = price == 0 ? 'free' : 'paid';

    // Map 'description' to 'about' for learning app compatibility
    if (finalData.containsKey('description')) {
      finalData['about'] = finalData['description'];
    }

    await docRef.set({
      ...finalData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'enrolledCount': 0,
      'studentsCount': 0,
      'status': 'published', // Learning app looks for published
    });
  }

  Future<void> updateCourseMetadata(String id, Map<String, dynamic> data) async {
    final finalData = Map<String, dynamic>.from(data);
    
    // Auto-calculate access type
    if (finalData.containsKey('price')) {
      final price = finalData['price'] as num? ?? 0.0;
      finalData['accessType'] = price == 0 ? 'free' : 'paid';
    }

    // Map 'description' to 'about' for learning app compatibility
    if (finalData.containsKey('description')) {
      finalData['about'] = finalData['description'];
    }

    await _firestore.collection('courses').doc(id).update({
      ...finalData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String id, String status) async {
    final Map<String, dynamic> updates = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (status == 'active') {
      updates['publishedAt'] = FieldValue.serverTimestamp();
    }
    
    await _firestore.collection('courses').doc(id).update(updates);
  }
}

@riverpod
AdminCourseRepository adminCourseRepository(Ref ref) {
  return AdminCourseRepository(FirebaseFirestore.instance);
}



@riverpod
Stream<List<AdminCourseModel>> adminCourseList(Ref ref) {
  return ref.watch(adminCourseRepositoryProvider).watchCourses();
}
