import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_admin_dashboard/src/features/enrollments/data/admin_enrollment_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/users/data/admin_user_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/data/admin_course_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/users/domain/admin_user_model.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/domain/admin_course_model.dart';

class GrantAccessDialog extends ConsumerStatefulWidget {
  const GrantAccessDialog({super.key});

  @override
  ConsumerState<GrantAccessDialog> createState() => _GrantAccessDialogState();
}

class _GrantAccessDialogState extends ConsumerState<GrantAccessDialog> {
  AdminUserModel? _selectedUser;
  AdminCourseModel? _selectedCourse;
  String _userSearch = '';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUserListProvider);
    final coursesAsync = ref.watch(adminCourseListProvider);

    // Filter users based on search
    final filteredUsers = usersAsync.asData?.value.where((u) => 
      u.email.toLowerCase().contains(_userSearch.toLowerCase()) || 
      u.displayName.toLowerCase().contains(_userSearch.toLowerCase())
    ).toList() ?? [];

    return AlertDialog(
      title: const Text('Grant Manual Access'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search User', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_selectedUser == null)
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter name or email...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _userSearch = val),
              )
            else
              ListTile(
                title: Text(_selectedUser!.displayName),
                subtitle: Text(_selectedUser!.email),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedUser = null),
                ),
                tileColor: Colors.blue.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            
            if (_selectedUser == null && _userSearch.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      title: Text(user.displayName),
                      subtitle: Text(user.email),
                      onTap: () => setState(() {
                        _selectedUser = user;
                        _userSearch = '';
                      }),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            const Text('Select Course', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            coursesAsync.when(
              data: (courses) => DropdownButtonFormField<AdminCourseModel>(
                initialValue: _selectedCourse,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Choose a course'),
                items: courses.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.title),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCourse = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading courses: $err'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_selectedUser == null || _selectedCourse == null || _isSubmitting)
              ? null
              : _handleSubmit,
          child: _isSubmitting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Grant Access'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminEnrollmentRepositoryProvider).grantManualAccess(
        uid: _selectedUser!.uid,
        courseId: _selectedCourse!.id,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access granted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
