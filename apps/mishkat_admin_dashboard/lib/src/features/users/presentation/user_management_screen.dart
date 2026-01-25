import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/users/data/admin_user_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/users/domain/admin_user_model.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUserListProvider);

    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'User Management',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AdminTheme.secondaryNavy,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 320,
                  height: 48,
                  child: TextField(
                    style: GoogleFonts.roboto(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: GoogleFonts.roboto(color: AdminTheme.textSecondary.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.search, size: 20, color: AdminTheme.secondaryNavy),
                      filled: true,
                      fillColor: AdminTheme.scaffoldBackground.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AdminTheme.secondaryNavy, width: 1),
                      ),
                    ),
                    onChanged: (val) => ref.read(userSearchTermProvider.notifier).set(val),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('ADD USER', style: GoogleFonts.roboto(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // User Table
          Expanded(
            child: usersAsync.when(
              data: (users) => _UserTable(users: users),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTable extends ConsumerWidget {
  final List<AdminUserModel> users;

  const _UserTable({required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 24,
            columnSpacing: 40,
            headingRowColor: WidgetStateProperty.all(AdminTheme.scaffoldBackground),
            columns: [
              DataColumn(label: Text('User', style: GoogleFonts.roboto(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Role', style: GoogleFonts.roboto(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Rank', style: GoogleFonts.roboto(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Joined', style: GoogleFonts.roboto(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Status', style: GoogleFonts.roboto(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Actions', style: GoogleFonts.roboto(fontWeight: FontWeight.w700))),
            ],
          rows: users.map((user) => DataRow(
            cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AdminTheme.secondaryNavy.withValues(alpha: 0.1),
                        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                        child: user.photoUrl == null 
                          ? Text(user.displayName[0], style: const TextStyle(color: AdminTheme.secondaryNavy, fontWeight: FontWeight.bold)) 
                          : null,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.displayName, 
                              style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user.email, 
                              style: GoogleFonts.roboto(fontSize: 12, color: AdminTheme.textSecondary),
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
              DataCell(Text(user.rank, style: GoogleFonts.roboto(fontSize: 14))),
              DataCell(Text(
                DateFormat('MMM dd, yyyy').format(user.createdAt),
                style: GoogleFonts.roboto(fontSize: 13, color: AdminTheme.textSecondary),
              )),
              DataCell(
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: user.isActive,
                    activeThumbColor: AdminTheme.primaryEmerald, // Wait, if it says it's deprecated, I'll use activeTrackColor as fallback or check if I can use thumbColor
                    // In modern Flutter switch:
                    // activeColor is for the thumb.
                    // activeTrackColor is for the track.
                    activeTrackColor: AdminTheme.primaryEmerald.withValues(alpha: 0.5),
                    onChanged: (val) async {
                      try {
                        await ref.read(adminUserRepositoryProvider).updateUser(user.uid, {'isActive': val});
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update status: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AdminTheme.primaryEmerald),
                      onPressed: () => _showEditDialog(context, ref, user),
                      tooltip: 'Edit User',
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 20, color: AdminTheme.radiantGold),
                      onPressed: () => _showDetailSheet(context, user),
                      tooltip: 'View Details',
                    ),
                  ],
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    ),
    );
  }

  void _showDetailSheet(BuildContext context, AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                  radius: 40,
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? Text(user.displayName[0], style: const TextStyle(fontSize: 32)) : null,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(user.email, style: const TextStyle(fontSize: 18, color: AdminTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text('ACCOUNT OVERVIEW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AdminTheme.textSecondary)),
            const SizedBox(height: 16),
            _infoBox(context, 'Current Role', user.role.toUpperCase()),
            _infoBox(context, 'Spiritual Rank', user.rank),
            _infoBox(context, 'Member Since', DateFormat('MMMM dd, yyyy').format(user.createdAt)),
            _infoBox(context, 'Course Enrollments', user.enrolledCoursesCount.toString()),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('View Activity Logs'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(),
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
          title: Text('Edit User: ${user.email}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'System Role', border: OutlineInputBorder()),
                  items: ['admin', 'teacher', 'student'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                  onChanged: (val) => setState(() => selectedRole = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRank,
                  decoration: const InputDecoration(labelText: 'Spiritual Rank', border: OutlineInputBorder()),
                  items: ['Seeker', 'Learner', 'Aspirant', 'Guide'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => selectedRank = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryEmerald, foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  final updates = {
                    'displayName': nameController.text,
                    'role': selectedRole,
                    'rank': selectedRank,
                  };
                  
                  // If role changed, call custom claim function
                  if (selectedRole != user.role) {
                    await ref.read(adminUserRepositoryProvider).setUserRole(user.uid, selectedRole);
                  }
                  
                  // Update Firestore doc
                  await ref.read(adminUserRepositoryProvider).updateUser(user.uid, updates);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated successfully')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
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
        style: GoogleFonts.roboto(
          color: color, 
          fontSize: 11, 
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
