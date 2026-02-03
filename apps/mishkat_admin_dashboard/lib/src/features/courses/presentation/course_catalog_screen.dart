import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/data/admin_course_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/domain/admin_course_model.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/presentation/widgets/admin_course_editor.dart';

import 'package:mishkat_admin_dashboard/src/widgets/common/dashboard_header.dart'; // Add import

class CourseCatalogScreen extends ConsumerWidget {
  const CourseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: The parent MainLayout no longer provides a header.
    // We use DashboardHeader here to provide the unified title + actions + profile.
    
    final coursesAsync = ref.watch(adminCourseListProvider);

    return Column(
      children: [
        DashboardHeader(
          title: 'Course Catalog',
          subtitle: 'Manage your courses content',
          action: ElevatedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AdminCourseEditor(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.zinc900,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),
        
        // Course Grid
        Expanded(
          child: coursesAsync.when(
            data: (courses) => GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.85,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) => _CourseCard(course: courses[index]),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends ConsumerStatefulWidget {
  final AdminCourseModel course;

  const _CourseCard({required this.course});

  @override
  ConsumerState<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<_CourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Card(
        // Theme handles shape and border
        color: _isHovered ? AdminTheme.zinc50 : AdminTheme.background,
        child: InkWell(
          onTap: () {
            context.push('/courses/${course.id}/curriculum', extra: course.title);
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AdminTheme.zinc100,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                        ? Image.network(course.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: AdminTheme.zinc300))
                        : const Icon(Icons.image, color: AdminTheme.zinc300),
                    ),
                  ),
                  if (course.status != 'active')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AdminTheme.zinc100,
                          border: Border.all(color: AdminTheme.zinc300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DRAFT', 
                          style: TextStyle(
                            color: AdminTheme.zinc600, 
                            fontSize: 10, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructorName ?? 'No Instructor',
                      style: const TextStyle(color: AdminTheme.mutedForeground, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (course.accessType == 'free' || (course.price ?? 0) == 0) ? 'Free' : '\$${course.price?.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Row(
                          children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20, color: AdminTheme.zinc500),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 150),
                              onSelected: (value) async {
                                final repo = ref.read(adminCourseRepositoryProvider);
                                if (value == 'edit') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AdminCourseEditor(course: course),
                                  );
                                } else if (value == 'duplicate') {
                                  await repo.duplicateCourse(course);
                                } else if (value == 'delete') {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Course?'),
                                      content: const Text('This will permanently delete this course and all its content.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.destructive),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await repo.deleteCourse(course.id);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 12), Text('Edit Details')])),
                                const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy_outlined, size: 18), SizedBox(width: 12), Text('Duplicate')])),
                                const PopupMenuDivider(),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: AdminTheme.destructive, size: 18), SizedBox(width: 12), Text('Delete', style: TextStyle(color: AdminTheme.destructive))])),
                              ],
                            ),
                            if (_isHovered)
                              const Icon(Icons.arrow_forward, size: 16, color: AdminTheme.zinc400),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


