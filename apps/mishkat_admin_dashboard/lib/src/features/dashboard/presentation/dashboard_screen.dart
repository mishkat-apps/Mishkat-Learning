import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/data/dashboard_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/presentation/widgets/action_center.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operational Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            
            // KPI Grid
            metricsAsync.when(
              data: (metrics) => GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
                children: [
                  KPICard(
                    label: 'New Users (7d)',
                    value: '${metrics.newUsers7d}',
                    icon: Icons.people_alt_outlined,
                    trend: '+12%',
                  ),
                  KPICard(
                    label: 'Total Revenue (7d)',
                    value: '\$${metrics.revenue7d.toInt()}',
                    icon: Icons.attach_money,
                    color: Colors.blueAccent,
                    trend: '+8%',
                  ),
                  KPICard(
                    label: 'Active Learners',
                    value: '${metrics.activeLearners7d}',
                    icon: Icons.school_outlined,
                    color: Colors.orange,
                  ),
                  KPICard(
                    label: 'Failed Payments',
                    value: '${metrics.failedPayments7d}',
                    icon: Icons.payment_outlined,
                    color: Colors.red,
                    trend: '-5%',
                    isTrendPositive: false,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading metrics: $err'),
            ),
            
            const SizedBox(height: 32),
            
            // Main Dashboard Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Charts
                Expanded(
                  flex: 2,
                  child: metricsAsync.when(
                    data: (metrics) => Column(
                      children: [
                        RevenueChart(data: metrics.revenueHistory),
                        const SizedBox(height: 24),
                        // Placeholder for Top Courses list or more charts
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Top Performing Courses', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 16),
                                ...metrics.topCourses.map((c) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(c.title),
                                  subtitle: Text('${c.enrollments} enrollments'),
                                  trailing: Text('\$${c.revenue.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(),
                    error: (err, stack) => const SizedBox(),
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column: Action Center
                const Expanded(
                  flex: 1,
                  child: ActionCenter(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
