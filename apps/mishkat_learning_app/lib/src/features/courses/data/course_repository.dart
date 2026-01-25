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

  Future<void> seedCourses() async {
    final batch = _firestore.batch();
    final coursesRef = _firestore.collection('courses');
    
    // 1. Philosophy of Karbala
    final karbalaSnapshot = await coursesRef.where('title', isEqualTo: 'The Philosophy of Karbala').get();
    for (var doc in karbalaSnapshot.docs) {
      batch.update(doc.reference, {
        'category': 'Ahl al-Bayt & Role Models',
        'tagline': 'Uncovering the spiritual and intellectual foundations of the greatest sacrifice.',
        'instructorTitle': 'Senior Scholar & Philosopher',
        'instructorQuote': 'Karbala is not just a historical event; it is a timeless map for the soul seeking liberation.',
        'features': [
          '8.5 hours of high-definition video',
          'Detailed English transcripts',
          'Interactive discussion forums',
          'Certificate of completion',
          'Lifetime access to updates',
        ],
        'videoUrl': 'https://vimeo.com/1156003980',
        'duration': '8.5 Hours',
        'level': 'Intermediate',
        'reviews': 0,
        'rating': 0.0,
      });
    }

    // 2. Introduction to Shia Theology
    final theologySnapshot = await coursesRef.where('title', isEqualTo: 'Introduction to Shia Theology').get();
    for (var doc in theologySnapshot.docs) {
      batch.update(doc.reference, {
        'category': 'Aqaid',
        'tagline': 'A comprehensive journey into the core tenets of Shia Islamic thought.',
        'instructorTitle': 'Professor of Islamic Philosophy',
        'instructorQuote': 'Truth is a shoreless ocean; theology is our attempt to navigate its depths with the light of reason.',
        'features': [
          '12 progressive lessons',
          '5 Graded assessments',
          'Downloadable reading materials',
          'Direct Q&A with instructor',
          'Recognized digital badge',
        ],
        'videoUrl': 'https://vimeo.com/1156003980',
        'duration': '12 Hours',
        'level': 'Beginner',
        'reviews': 0,
        'rating': 0.0,
      });
    }

    await batch.commit();
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
