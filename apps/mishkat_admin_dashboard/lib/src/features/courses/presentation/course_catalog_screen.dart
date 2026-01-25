import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/data/admin_course_repository.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/domain/admin_course_model.dart';
import 'package:mishkat_admin_dashboard/src/features/courses/presentation/widgets/admin_course_editor.dart';

class CourseCatalogScreen extends ConsumerWidget {
  const CourseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(adminCourseListProvider);


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
                  'Course Catalog', 
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AdminTheme.secondaryNavy,
                  ),
                ),
                const Spacer(),

                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const AdminCourseEditor(),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text('CREATE COURSE', style: GoogleFonts.roboto(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

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
      ),
    );
  }
}

class _CourseCard extends StatefulWidget {
  final AdminCourseModel course;

  const _CourseCard({required this.course});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered 
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))]
            : [],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isHovered ? AdminTheme.primaryEmerald.withValues(alpha: 0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          elevation: _isHovered ? 4 : 1,
          child: InkWell(
            onTap: () {
              // Ensure we use the ID for routing
              context.push('/courses/${course.id}/curriculum', extra: course.title);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: AdminTheme.scaffoldBackground,
                        child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                          ? Image.network(course.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.school_outlined, size: 48, color: AdminTheme.textSecondary))
                          : const Icon(Icons.school_outlined, size: 48, color: AdminTheme.textSecondary),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                          padding: const EdgeInsets.all(8),
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AdminCourseEditor(course: course),
                        ),
                      ),
                    ),
                    if (course.status != 'active')
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('DRAFT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.instructorName ?? 'No Instructor Set',
                        style: GoogleFonts.roboto(color: AdminTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price', style: GoogleFonts.roboto(color: AdminTheme.textSecondary, fontSize: 11)),
                              Text(
                                (course.accessType == 'free' || (course.price ?? 0) == 0) ? 'FREE' : '\$${course.price?.toStringAsFixed(2)}',
                                style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: AdminTheme.primaryEmerald),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AdminTheme.primaryEmerald.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chevron_right, size: 16, color: AdminTheme.primaryEmerald),
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
      ),
    );
  }
}


