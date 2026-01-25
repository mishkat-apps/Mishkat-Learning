import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dashboard_metrics.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepository(this._firestore);

  // Streams for real-time Action Center
  Stream<List<AdminAction>> watchAdminActions() {
    return _firestore
        .collection('admin_actions')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdminAction.fromFirestore(doc))
            .toList());
  }

  // Fetch real metrics from Firestore
  Future<DashboardMetrics> getDashboardMetrics() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    // 1. New Users (Last 7 Days)
    final newUsersQuery = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThan: sevenDaysAgo)
        .count()
        .get();
    final newUsersCount = newUsersQuery.count ?? 0;

    // 2. Active Learners (Total Enrollments for now, or active status)
    final activeLearnersQuery = await _firestore
        .collection('enrollments')
        .where('status', isEqualTo: 'active')
        .count()
        .get();
    final activeLearnersCount = activeLearnersQuery.count ?? 0;

    // 3. Payments (Last 7 Days)
    final paymentsSnapshot = await _firestore
        .collection('payments')
        .where('createdAt', isGreaterThan: sevenDaysAgo)
        .get();

    double revenue7d = 0;
    int failedPaymentsCount = 0;
    List<DailyRevenue> revenueHistory = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DailyRevenue(date, 0);
    });

    for (var doc in paymentsSnapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? 'pending';
      final currency = data['currency'] as String? ?? 'USD';
      final amount = (data['amount'] as num? ?? 0).toDouble();

      if (status == 'captured' || status == 'success') {
        final usdAmount = _convertToUsd(amount, currency);
        revenue7d += usdAmount;

        // Add to history bucket
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        // Simple bucket finding: match day/month/year
        final bucketIndex = revenueHistory.indexWhere((r) => 
          r.date.day == createdAt.day && 
          r.date.month == createdAt.month && 
          r.date.year == createdAt.year
        );
        if (bucketIndex != -1) {
          revenueHistory[bucketIndex] = DailyRevenue(
            revenueHistory[bucketIndex].date,
            revenueHistory[bucketIndex].amount + usdAmount,
          );
        }
      } else if (status == 'failed') {
        failedPaymentsCount++;
      }
    }

    // 4. Top Courses (Aggregate from recent successful payments or enrollments)
    // For MVP efficiency: Query last 30 enrolled courses
    final recentEnrollments = await _firestore
        .collection('enrollments')
        .orderBy('enrolledAt', descending: true)
        .limit(50)
        .get();
    
    // Map courseId -> details
    final Map<String, _CourseStats> courseStats = {};
    for (var doc in recentEnrollments.docs) {
      final data = doc.data();
      final courseId = data['courseId'] as String;
      // We don't have revenue in enrollment directly usually, unless we link it.
      // For now, we count enrollments.
      courseStats.putIfAbsent(courseId, () => _CourseStats(enrollments: 0));
      courseStats[courseId]!.enrollments++;
    }

    // Fetch titles for top courses
    List<TopCourseMetric> topCourses = [];
    final sortedCourseIds = courseStats.keys.toList()
      ..sort((a, b) => courseStats[b]!.enrollments.compareTo(courseStats[a]!.enrollments));
    
    final top5Ids = sortedCourseIds.take(5);
    for (var id in top5Ids) {
      final courseDoc = await _firestore.collection('courses').doc(id).get();
      final title = courseDoc.data()?['title'] as String? ?? 'Unknown Course';
      final stats = courseStats[id]!;
      // Estimate revenue if we can't link precise payments easily here without join
      // For MVP, we'll leave revenue in TopCourseMetric as 0 if not easily available, or estimate.
      // Better: Retrieve price from course doc and multiply by enrollments (approx)
      final price = (courseDoc.data()?['price'] as num? ?? 0).toDouble();
      topCourses.add(TopCourseMetric(
        courseId: id,
        title: title,
        enrollments: stats.enrollments,
        revenue: price * stats.enrollments, // Approximation
      ));
    }

    return DashboardMetrics(
      newUsers7d: newUsersCount,
      activeLearners7d: activeLearnersCount,
      revenue7d: revenue7d,
      failedPayments7d: failedPaymentsCount,
      supportAlerts: 0, // Placeholder
      topCourses: topCourses,
      revenueHistory: revenueHistory,
    );
  }

  double _convertToUsd(double amount, String currency) {
    if (currency.toUpperCase() == 'USD') return amount;
    if (currency.toUpperCase() == 'INR') return amount * 0.012; // Approx rate
    return amount; // Fallback
  }
}

class _CourseStats {
  int enrollments;
  _CourseStats({required this.enrollments});
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(FirebaseFirestore.instance);
});

final adminActionsProvider = StreamProvider<List<AdminAction>>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchAdminActions();
});

final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) {
  return ref.watch(dashboardRepositoryProvider).getDashboardMetrics();
});
