import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models.dart';

class CourseRepository {
  final FirebaseFirestore _firestore;

  CourseRepository(this._firestore);

  Stream<List<Course>> watchCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
    });
  }

  Stream<Course?> watchCourseBySlug(String slug) {
    return _firestore
        .collection('courses')
        .where('slug', isEqualTo: slug)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Course.fromFirestore(snapshot.docs.first);
    });
  }

  Stream<List<Lesson>> watchLessons(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Lesson.fromFirestore(doc)).toList();
    });
  }

  Stream<List<LessonPart>> watchLessonParts(String courseId, String lessonId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('parts')
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LessonPart.fromFirestore(doc)).toList();
    });
  }

  Future<Course?> getCourseById(String id) async {
    final doc = await _firestore.collection('courses').doc(id).get();
    if (!doc.exists) return null;
    return Course.fromFirestore(doc);
  }

  Stream<List<Enrollment>> watchUserEnrollments(String uid) {
    return _firestore
        .collection('enrollments')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Enrollment.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Course>> watchCoursesByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    return _firestore
        .collection('courses')
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
    });
  }
}

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(FirebaseFirestore.instance);
});

final coursesStreamProvider = StreamProvider<List<Course>>((ref) {
  return ref.watch(courseRepositoryProvider).watchCourses();
});

final courseBySlugProvider = StreamProvider.family<Course?, String>((ref, slug) {
  return ref.watch(courseRepositoryProvider).watchCourseBySlug(slug);
});

final specificCourseProvider = FutureProvider.family<Course?, String>((ref, id) {
  return ref.watch(courseRepositoryProvider).getCourseById(id);
});

final lessonsProvider = StreamProvider.family<List<Lesson>, String>((ref, courseId) {
  return ref.watch(courseRepositoryProvider).watchLessons(courseId);
});

final lessonPartsProvider = StreamProvider.family<List<LessonPart>, ({String courseId, String lessonId})>((ref, arg) {
  return ref.watch(courseRepositoryProvider).watchLessonParts(arg.courseId, arg.lessonId);
});

final userEnrollmentsProvider = StreamProvider.family<List<Enrollment>, String>((ref, uid) {
  return ref.watch(courseRepositoryProvider).watchUserEnrollments(uid);
});

final enrolledCoursesProvider = StreamProvider<List<Course>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final enrollmentsAsync = ref.watch(userEnrollmentsProvider(user.uid));
  
  return enrollmentsAsync.when(
    data: (enrollments) {
      if (enrollments.isEmpty) return Stream.value([]);
      
      final courseIds = enrollments.map((e) => e.courseId).toList();
      return ref.watch(courseRepositoryProvider).watchCoursesByIds(courseIds);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
