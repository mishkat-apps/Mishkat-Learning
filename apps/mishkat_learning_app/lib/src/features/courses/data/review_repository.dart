import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository(this._firestore);

  Stream<CourseReview?> watchUserReview(String courseId, String uid) {
    return _firestore
        .collection('reviews')
        .doc('${uid}_$courseId')
        .snapshots()
        .map((doc) => doc.exists ? CourseReview.fromFirestore(doc) : null);
  }

  Stream<List<CourseReview>> watchReviews(String courseId) {
    return _firestore
        .collection('reviews')
        .where('courseId', isEqualTo: courseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CourseReview.fromFirestore(doc)).toList();
    });
  }

  Future<void> addReview(CourseReview review) async {
    final batch = _firestore.batch();
    final reviewId = '${review.uid}_${review.courseId}';
    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    final courseRef = _firestore.collection('courses').doc(review.courseId);

    final reviewDoc = await reviewRef.get();
    final courseDoc = await courseRef.get();

    if (!courseDoc.exists) return;

    final courseData = courseDoc.data()!;
    int totalReviews = courseData['reviews'] ?? 0;
    double currentRating = (courseData['rating'] ?? 0.0).toDouble();

    if (!reviewDoc.exists) {
      // New review/rating
      final newTotalReviews = totalReviews + 1;
      final newAverageRating = ((currentRating * totalReviews) + review.rating) / newTotalReviews;

      batch.set(reviewRef, review.toFirestore());
      batch.update(courseRef, {
        'reviews': newTotalReviews,
        'rating': newAverageRating,
      });
    } else {
      // Updating existing review/rating
      final oldRating = (reviewDoc.data()!['rating'] ?? 0.0).toDouble();
      
      // Calculate new average by removing old rating and adding new one
      // (avg * count - old + new) / count
      final newAverageRating = totalReviews > 0 
          ? ((currentRating * totalReviews) - oldRating + review.rating) / totalReviews
          : review.rating;

      batch.set(reviewRef, review.toFirestore(), SetOptions(merge: true));
      batch.update(courseRef, {
        'rating': newAverageRating,
      });
    }

    await batch.commit();
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(FirebaseFirestore.instance);
});

final courseReviewsProvider = StreamProvider.family<List<CourseReview>, String>((ref, courseId) {
  return ref.watch(reviewRepositoryProvider).watchReviews(courseId);
});

final userReviewProvider = StreamProvider.family<CourseReview?, ({String courseId, String uid})>((ref, arg) {
  return ref.watch(reviewRepositoryProvider).watchUserReview(arg.courseId, arg.uid);
});
