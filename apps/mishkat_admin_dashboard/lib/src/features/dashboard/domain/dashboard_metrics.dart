import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardMetrics {
  final int newUsers7d;
  final int activeLearners7d;
  final double revenue7d;
  final int failedPayments7d;
  final int supportAlerts;
  final List<TopCourseMetric> topCourses;
  final List<DailyRevenue> revenueHistory;

  DashboardMetrics({
    required this.newUsers7d,
    required this.activeLearners7d,
    required this.revenue7d,
    required this.failedPayments7d,
    required this.supportAlerts,
    required this.topCourses,
    required this.revenueHistory,
  });

  factory DashboardMetrics.empty() {
    return DashboardMetrics(
      newUsers7d: 0,
      activeLearners7d: 0,
      revenue7d: 0.0,
      failedPayments7d: 0,
      supportAlerts: 0,
      topCourses: [],
      revenueHistory: [],
    );
  }
}

class TopCourseMetric {
  final String courseId;
  final String title;
  final int enrollments;
  final double revenue;

  TopCourseMetric({
    required this.courseId,
    required this.title,
    required this.enrollments,
    required this.revenue,
  });
}

class DailyRevenue {
  final DateTime date;
  final double amount;

  DailyRevenue(this.date, this.amount);
}

class AdminAction {
  final String id;
  final String title;
  final String category; // 'publish_pending', 'failed_webhook', 'flagged'
  final String description;
  final DateTime createdAt;
  final String targetRef;

  AdminAction({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.targetRef,
  });

  factory AdminAction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminAction(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetRef: data['targetRef'] ?? '',
    );
  }
}
