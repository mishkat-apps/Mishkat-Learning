import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/data/admin_enrollment_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/domain/admin_enrollment_model.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/presentation/widgets/grant_access_dialog.dart';

class EnrollmentManagementScreen extends ConsumerWidget {
  const EnrollmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentListAsync = ref.watch(adminEnrollmentListProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollments & Access'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.icon(
              onPressed: () => _showGrantAccessDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Grant Access'),
            ),
          ),
        ],
      ),
      body: enrollmentListAsync.when(
        data: (enrollments) => _buildEnrollmentTable(context, ref, enrollments),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEnrollmentTable(BuildContext context, WidgetRef ref, List<AdminEnrollment> enrollments) {
    if (enrollments.isEmpty) {
      return const Center(child: Text('No enrollments found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('User ID')),
            DataColumn(label: Text('Course ID')),
            DataColumn(label: Text('Enrolled At')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Progress')),
            DataColumn(label: Text('Actions')),
          ],
          rows: enrollments.map((enrollment) {
            return DataRow(cells: [
              DataCell(Text(enrollment.uid.length > 8 ? '${enrollment.uid.substring(0, 8)}...' : enrollment.uid)),
              DataCell(Text(enrollment.courseId)),
              DataCell(Text(DateFormat('MMM dd, yyyy').format(enrollment.enrolledAt))),
              DataCell(_buildTypeBadge(enrollment.accessType)),
              DataCell(_buildStatusBadge(enrollment.status)),
              DataCell(Text('${enrollment.progress}%')),
              DataCell(
                enrollment.status == 'active'
                    ? IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        tooltip: 'Revoke Access',
                        onPressed: () => _confirmRevoke(context, ref, enrollment),
                      )
                    : const Icon(Icons.lock_outline, color: Colors.grey),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'revoked':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color = type == 'manual' ? Colors.orange : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showGrantAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GrantAccessDialog(),
    );
  }

  Future<void> _confirmRevoke(BuildContext context, WidgetRef ref, AdminEnrollment enrollment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Access?'),
        content: Text('Are you sure you want to revoke access for user ${enrollment.uid} to course ${enrollment.courseId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(adminEnrollmentRepositoryProvider).revokeAccess(enrollment.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access revoked successfully')),
        );
      }
    }
  }
}
