import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/technical/data/admin_audit_repository.dart';
import 'dart:convert';

class TechnicalDashboardScreen extends ConsumerWidget {
  const TechnicalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AdminTheme.scaffoldBackground,
        body: Column(
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Technical Admin', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AdminTheme.primaryEmerald,
                    unselectedLabelColor: AdminTheme.textSecondary,
                    indicatorColor: AdminTheme.primaryEmerald,
                    tabs: [
                      Tab(text: 'Audit Logs'),
                      Tab(text: 'System Health'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            Expanded(
              child: TabBarView(
                children: [
                   const _AuditLogsTab(),
                   const _SystemHealthTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditLogsTab extends ConsumerWidget {
  const _AuditLogsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(adminAuditLogsProvider());

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('No audit logs found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    _ActionBadge(action: log.actionType),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        log.targetRef,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'Geist Mono'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(log.actorUid, style: const TextStyle(fontSize: 11, fontFamily: 'Geist Mono')),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, HH:mm:ss').format(log.createdAt),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Metadata', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                         Text(
                          _prettyJson(log.metadata),
                          style: const TextStyle(fontFamily: 'Geist Mono', fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _prettyJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
}

class _ActionBadge extends StatelessWidget {
  final String action;
  
  const _ActionBadge({required this.action});
  
  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue;
    if (action.contains('DELETE') || action.contains('REVOKE')) color = Colors.red;
    if (action.contains('CREATE') || action.contains('GRANT')) color = Colors.green;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        action,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SystemHealthTab extends StatelessWidget {
  const _SystemHealthTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _HealthCard(
            title: 'Operational',
            message: 'All systems functioning normally.',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text('Recent Alerts (Mock)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Placeholder for alerts
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber, color: Colors.orange),
              title: const Text('High Latency detected in Asia-South1'),
              subtitle: const Text('2 hours ago'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _HealthCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: AdminTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
