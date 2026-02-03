import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/data/admin_enrollment_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/domain/admin_enrollment_model.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/presentation/widgets/grant_access_dialog.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/dashboard_header.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/presentation/widgets/kpi_card.dart';

class EnrollmentManagementScreen extends ConsumerStatefulWidget {
  const EnrollmentManagementScreen({super.key});

  @override
  ConsumerState<EnrollmentManagementScreen> createState() => _EnrollmentManagementScreenState();
}

class _EnrollmentManagementScreenState extends ConsumerState<EnrollmentManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final enrollmentListAsync = ref.watch(adminEnrollmentListProvider());

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      body: Column(
        children: [
          DashboardHeader(
            title: 'Enrollments & Access',
            subtitle: 'Manage course permissions and student progress',
            action: ElevatedButton.icon(
              onPressed: () => _showGrantAccessDialog(context),
              icon: const Icon(Icons.add_moderator_outlined),
              label: const Text('Grant Manual Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.zinc900,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
          
          Expanded(
            child: enrollmentListAsync.when(
              data: (enrollments) {
                // Filter logic
                final filtered = enrollments.where((e) {
                  final matchesSearch = e.uid.contains(_searchQuery) || e.courseId.contains(_searchQuery);
                  final matchesStatus = _statusFilter == 'all' || e.status == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                // Stats
                final totalEnrollments = enrollments.length;
                final activeEnrollments = enrollments.where((e) => e.status == 'active').length;
                final completedEnrollments = enrollments.where((e) => e.status == 'completed').length;
                final manualEnrollments = enrollments.where((e) => e.accessType == 'manual').length;

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // KPI Row
                    Row(
                      children: [
                        Expanded(child: KPICard(label: 'Total Enrollments', value: '$totalEnrollments', icon: Icons.assignment_outlined)),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(label: 'Active Path', value: '$activeEnrollments', icon: Icons.play_circle_outline, color: AdminTheme.primaryEmerald)),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(label: 'Completions', value: '$completedEnrollments', icon: Icons.verified_outlined, color: Colors.blue)),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(label: 'Manual Access', value: '$manualEnrollments', icon: Icons.shield_outlined, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Filter & Search Row
                    Row(
                      children: [
                        _StatusFilterChip(
                          label: 'All', 
                          isSelected: _statusFilter == 'all', 
                          onSelected: () => setState(() => _statusFilter = 'all')
                        ),
                        const SizedBox(width: 8),
                        _StatusFilterChip(
                          label: 'Active', 
                          isSelected: _statusFilter == 'active', 
                          onSelected: () => setState(() => _statusFilter = 'active')
                        ),
                        const SizedBox(width: 8),
                        _StatusFilterChip(
                          label: 'Completed', 
                          isSelected: _statusFilter == 'completed', 
                          onSelected: () => setState(() => _statusFilter = 'completed')
                        ),
                        const SizedBox(width: 8),
                        _StatusFilterChip(
                          label: 'Revoked', 
                          isSelected: _statusFilter == 'revoked', 
                          onSelected: () => setState(() => _statusFilter = 'revoked')
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search User ID or Course ID...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Table
                    _buildEnrollmentTable(context, filtered),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentTable(BuildContext context, List<AdminEnrollment> enrollments) {
    if (enrollments.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Center(child: Text('No enrollments found matching criteria.')),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowHeight: 56,
        dataRowMaxHeight: 72,
        horizontalMargin: 24,
        headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
        columns: const [
          DataColumn(label: Text('USER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('COURSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('PROGRESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
        rows: enrollments.map((enrollment) {
          return DataRow(cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(enrollment.uid.length > 8 ? '${enrollment.uid.substring(0, 8)}...' : enrollment.uid, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Geist Mono')),
                  const Text('Student', style: TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
                ],
              )
            ),
            DataCell(Text(enrollment.courseId, style: const TextStyle(fontSize: 13))),
            DataCell(Text(DateFormat('MMM dd, yyyy').format(enrollment.enrolledAt), style: const TextStyle(fontSize: 13))),
            DataCell(_buildTypeBadge(enrollment.accessType)),
            DataCell(_buildStatusBadge(enrollment.status)),
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${enrollment.progress}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: LinearProgressIndicator(
                      value: enrollment.progress / 100,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        enrollment.progress == 100 ? Colors.green : AdminTheme.primaryEmerald
                      ),
                    ),
                  ),
                ],
              )
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                    onPressed: () {}, // View details
                  ),
                  if (enrollment.status == 'active')
                    IconButton(
                      icon: const Icon(Icons.block, color: Colors.red, size: 20),
                      tooltip: 'Revoke Access',
                      onPressed: () => _confirmRevoke(enrollment),
                    ),
                ],
              ),
            ),
          ]);
        }).toList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color = type == 'manual' ? Colors.orange : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  void _showGrantAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GrantAccessDialog(),
    );
  }

  Future<void> _confirmRevoke(AdminEnrollment enrollment) async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access revoked successfully')),
        );
      }
    }
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AdminTheme.zinc900,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AdminTheme.zinc900,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!),
      ),
      showCheckmark: false,
    );
  }
}
