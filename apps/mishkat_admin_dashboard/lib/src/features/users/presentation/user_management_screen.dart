import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/users/data/admin_user_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/users/domain/admin_user_model.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/data/admin_course_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/data/admin_enrollment_repository.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/dashboard_header.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/presentation/widgets/kpi_card.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _selectedRole = 'all';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUserListProvider);

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      body: Column(
        children: [
          DashboardHeader(
            title: 'User Management',
            subtitle: 'Manage system access and student progress',
            action: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.zinc900,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
          
          Expanded(
            child: usersAsync.when(
              data: (users) {
                // Filter users based on selected role
                final filteredUsers = _selectedRole == 'all' 
                    ? users 
                    : users.where((u) => u.role.toLowerCase() == _selectedRole).toList();

                // Stats calculation
                final totalCount = users.length;
                final studentCount = users.where((u) => u.role == 'student').length;
                final teacherCount = users.where((u) => u.role == 'teacher').length;
                final adminCount = users.where((u) => u.role == 'admin').length;

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // KPI Row
                    Row(
                      children: [
                        Expanded(child: KPICard(label: 'Total Users', value: '$totalCount', icon: Icons.people_outline)),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(label: 'Students', value: '$studentCount', icon: Icons.school_outlined, color: Colors.blue)),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(label: 'Teachers', value: '$teacherCount', icon: Icons.person_outline, color: AdminTheme.primaryEmerald)),
                        const SizedBox(width: 20),
                        Expanded(child: KPICard(label: 'Admins', value: '$adminCount', icon: Icons.admin_panel_settings_outlined, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Filter & Search Row
                    Row(
                      children: [
                        _RoleFilterChip(
                          label: 'All Users', 
                          isSelected: _selectedRole == 'all', 
                          onSelected: () => setState(() => _selectedRole = 'all')
                        ),
                        const SizedBox(width: 8),
                        _RoleFilterChip(
                          label: 'Students', 
                          isSelected: _selectedRole == 'student', 
                          onSelected: () => setState(() => _selectedRole = 'student')
                        ),
                        const SizedBox(width: 8),
                        _RoleFilterChip(
                          label: 'Teachers', 
                          isSelected: _selectedRole == 'teacher', 
                          onSelected: () => setState(() => _selectedRole = 'teacher')
                        ),
                        const SizedBox(width: 8),
                        _RoleFilterChip(
                          label: 'Admins', 
                          isSelected: _selectedRole == 'admin', 
                          onSelected: () => setState(() => _selectedRole = 'admin')
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 300,
                          height: 40,
                          child: TextField(
                            onChanged: (val) => ref.read(userSearchTermProvider.notifier).set(val),
                            decoration: InputDecoration(
                              hintText: 'Search email or name...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // The Table
                    _UserTable(users: filteredUsers),
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
}

class _RoleFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _RoleFilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : AdminTheme.zinc600, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.white,
      selectedColor: AdminTheme.zinc900,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AdminTheme.zinc900 : AdminTheme.zinc200)),
      showCheckmark: false,
    );
  }
}

class _UserTable extends ConsumerWidget {
  final List<AdminUserModel> users;

  const _UserTable({required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.zinc200),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: AdminTheme.zinc300),
              SizedBox(height: 16),
              Text('No users found matching your filters.', style: TextStyle(color: AdminTheme.zinc500)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.zinc200),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        horizontalMargin: 20,
        columnSpacing: 20,
        headingRowHeight: 56,
        dataRowMaxHeight: 72,
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.zinc900, fontSize: 13),
        columns: const [
          DataColumn(label: Expanded(child: Text('User'))),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Spiritual Rank')),
          DataColumn(label: Text('Joined')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: users.map((user) => DataRow(
          cells: [
            DataCell(
              SizedBox(
                width: 240, // Fixed width for user cell to handle scaling
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AdminTheme.zinc100,
                      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                      child: user.photoUrl == null 
                        ? Text(user.displayName[0].toUpperCase(), style: const TextStyle(color: AdminTheme.zinc600, fontWeight: FontWeight.bold, fontSize: 12)) 
                        : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.displayName, 
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AdminTheme.zinc900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email, 
                            style: const TextStyle(fontSize: 12, color: AdminTheme.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DataCell(_RoleBadge(role: user.role)),
            DataCell(Text(user.rank, style: const TextStyle(fontSize: 13))),
            DataCell(Text(
              DateFormat('MMM dd, yyyy').format(user.createdAt),
              style: const TextStyle(fontSize: 12, color: AdminTheme.mutedForeground),
            )),
            DataCell(
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: user.isActive,
                  onChanged: (val) async {
                    await ref.read(adminUserRepositoryProvider).updateUser(user.uid, {'isActive': val});
                  },
                ),
              ),
            ),
            DataCell(
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AdminTheme.zinc500),
                onSelected: (value) => _handleAction(context, ref, value, user),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 16), SizedBox(width: 8), Text('View Profile')])),
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit Details')])),
                  const PopupMenuItem(value: 'grant', child: Row(children: [Icon(Icons.school_outlined, size: 16), SizedBox(width: 8), Text('Grant Course')])),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: user.isActive ? 'deactivate' : 'activate', 
                    child: Row(children: [
                      Icon(user.isActive ? Icons.block : Icons.check_circle_outline, size: 16, color: user.isActive ? AdminTheme.destructive : Colors.green), 
                      const SizedBox(width: 8), 
                      Text(user.isActive ? 'Deactivate' : 'Activate', style: TextStyle(color: user.isActive ? AdminTheme.destructive : Colors.green))
                    ])
                  ),
                ],
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String value, AdminUserModel user) {
    switch (value) {
      case 'view':
        _showDetailSheet(context, ref, user);
        break;
      case 'edit':
        _showEditDialog(context, ref, user);
        break;
      case 'grant':
        _showGrantCourseDialog(context, ref, user);
        break;
      case 'deactivate':
      case 'activate':
        ref.read(adminUserRepositoryProvider).updateUser(user.uid, {'isActive': value == 'activate'});
        break;
    }
  }

  void _showGrantCourseDialog(BuildContext context, WidgetRef ref, AdminUserModel user) {
    // We'll implement this properly below
    showDialog(
      context: context,
      builder: (context) => _GrantCourseDialog(user: user),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AdminTheme.zinc100,
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? Text(user.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 24)) : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(user.email, style: const TextStyle(fontSize: 16, color: AdminTheme.mutedForeground)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Account Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AdminTheme.zinc500, letterSpacing: 0.5)),
            const SizedBox(height: 20),
            _infoRow('Role', user.role.toUpperCase()),
            _infoRow('Spiritual Rank', user.rank),
            _infoRow('Member Since', DateFormat('MMMM dd, yyyy').format(user.createdAt)),
            _infoRow('Current Enrollments', user.enrolledCoursesCount.toString()),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.password_outlined, size: 18),
                    label: const Text('Reset Password'),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.zinc900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.school_outlined, size: 18),
                    label: const Text('Grant Access'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showGrantCourseDialog(context, ref, user);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AdminTheme.mutedForeground, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, AdminUserModel user) {
    final nameController = TextEditingController(text: user.displayName);
    String selectedRole = user.role;
    String selectedRank = user.rank;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit User: ${user.email}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['admin', 'teacher', 'student'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => selectedRole = val!),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: selectedRank,
                decoration: const InputDecoration(labelText: 'Spiritual Rank'),
                items: ['Seeker', 'Learner', 'Aspirant', 'Guide', 'Scholar', 'Master Seeker'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => selectedRank = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updates = {
                  'displayName': nameController.text,
                  'role': selectedRole,
                  'rank': selectedRank,
                };
                if (selectedRole != user.role) {
                  await ref.read(adminUserRepositoryProvider).setUserRole(user.uid, selectedRole);
                }
                await ref.read(adminUserRepositoryProvider).updateUser(user.uid, updates);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.zinc900, foregroundColor: Colors.white),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrantCourseDialog extends ConsumerStatefulWidget {
  final AdminUserModel user;
  const _GrantCourseDialog({required this.user});

  @override
  ConsumerState<_GrantCourseDialog> createState() => _GrantCourseDialogState();
}

class _GrantCourseDialogState extends ConsumerState<_GrantCourseDialog> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(adminCourseListProvider);

    return AlertDialog(
      title: const Text('Grant Course Access'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecting a course will instantly enroll ${widget.user.displayName}.', style: const TextStyle(fontSize: 13, color: AdminTheme.mutedForeground)),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: Icon(Icons.search, size: 18),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() => _searchTerm = val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: coursesAsync.when(
                data: (courses) {
                  final filtered = courses.where((c) => c.title.toLowerCase().contains(_searchTerm.toLowerCase())).toList();
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final course = filtered[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 50,
                            height: 30,
                            color: AdminTheme.zinc100,
                            child: course.imageUrl != null ? Image.network(course.imageUrl!, fit: BoxFit.cover) : const Icon(Icons.image, size: 16),
                          ),
                        ),
                        title: Text(course.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(course.instructorName ?? '', style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right, size: 16),
                        onTap: () async {
                          try {
                            await ref.read(adminEnrollmentRepositoryProvider).grantManualAccess(
                              uid: widget.user.uid,
                              courseId: course.id,
                            );
                            
                            // Optional: Increment local counter for immediate feedback
                            await ref.read(adminUserRepositoryProvider).updateUser(widget.user.uid, {
                              'enrolledCoursesCount': widget.user.enrolledCoursesCount + 1,
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Granted ${course.title} to ${widget.user.displayName}'),
                                  backgroundColor: AdminTheme.primaryEmerald,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: AdminTheme.destructive),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, __) => Text('Error: $err'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role.toLowerCase()) {
      case 'admin':
        color = Colors.red;
        break;
      case 'teacher':
        color = AdminTheme.primaryEmerald;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
