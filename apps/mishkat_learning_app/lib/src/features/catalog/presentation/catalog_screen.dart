import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/domain/models.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class CatalogState {
  final String searchQuery;
  final String selectedCategory;
  final double maxPrice;
  final bool showFreeOnly;

  const CatalogState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.maxPrice = 1000,
    this.showFreeOnly = false,
  });

  CatalogState copyWith({
    String? searchQuery,
    String? selectedCategory,
    double? maxPrice,
    bool? showFreeOnly,
  }) {
    return CatalogState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      maxPrice: maxPrice ?? this.maxPrice,
      showFreeOnly: showFreeOnly ?? this.showFreeOnly,
    );
  }
}

class CatalogNotifier extends Notifier<CatalogState> {
  @override
  CatalogState build() => const CatalogState();

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setSelectedCategory(String category) => state = state.copyWith(selectedCategory: category);
  void setMaxPrice(double price) => state = state.copyWith(maxPrice: price);
  void setShowFreeOnly(bool show) => state = state.copyWith(showFreeOnly: show);
}

final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(CatalogNotifier.new);

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _selectedLevel = 'All Levels';

  final List<String> _categories = [
    'All',
    'Aqaid',
    'Akhlaq',
    'Ahkam',
    'Quran',
    'Ahl al-Bayt & Role Models',
    'Life Skills',
    'Basirah',
    'Miscellenous',
  ];

  final Map<String, String> _categoryTooltips = {
    'Aqaid': 'Worldview',
    'Akhlaq': 'Spirituality',
    'Ahkam': 'Islamic Laws',
    'Quran': 'Divine Book',
    'Ahl al-Bayt & Role Models': 'Divine Guides',
    'Life Skills': 'Practical Skills',
    'Basirah': 'Socio-political Awareness',
    'Miscellenous': 'Other topics',
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final authState = ref.watch(authStateProvider);
    final catalogState = ref.watch(catalogProvider);
    final selectedCategory = catalogState.selectedCategory;
    final searchQuery = catalogState.searchQuery;
    final maxPrice = catalogState.maxPrice;
    final showFreeOnly = catalogState.showFreeOnly;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppTheme.backgroundLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ), 
        centerTitle: true,
        title: Text(
          'COURSE CATALOG', 
          style: GoogleFonts.inter(
            color: AppTheme.radiantGold, 
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
            onPressed: () {
              // Notification action
            }, 
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Desktop Sidebar for Filters
                  if (isDesktop) 
                    SizedBox(width: 280, child: _SidebarFilters(
                      onPriceChanged: (val) => ref.read(catalogProvider.notifier).setMaxPrice(val),
                      onFreeOnlyChanged: (val) => ref.read(catalogProvider.notifier).setShowFreeOnly(val ?? false),
                    )),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32.0 : 16.0, 
                        vertical: 24
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isDesktop) ...[
                            _MobileFilters(),
                            const SizedBox(height: 16),
                          ],
                          
                          // Search Bar replacing Categories
                          TextField(
                            onChanged: (val) => ref.read(catalogProvider.notifier).setSearchQuery(val),
                            decoration: InputDecoration(
                              hintText: 'Search courses...',
                              prefixIcon: const Icon(Icons.search, color: AppTheme.slateGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            ),
                          ),
                          
                          // Category Filter Bar (Restored)
                          _buildCategoryBar(selectedCategory),
                          const SizedBox(height: 24),
                          
                          // Results Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Featured Courses', 
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('See All', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Course Grid
                          _buildCourseGrid(ref.watch(coursesStreamProvider), width, selectedCategory, searchQuery, maxPrice, showFreeOnly),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _buildHeader method

  Widget _buildCategoryBar(String selectedCategory) {
     return SizedBox(
       height: 40,
       child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4), // Reduced padding as it's inside body
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = selectedCategory == category;
              
              Widget chip = ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppTheme.deepEmerald,
                disabledColor: Colors.white,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.slateGrey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  ),
                ),
                onSelected: (bool selected) {
                  if (selected) {
                    ref.read(catalogProvider.notifier).setSelectedCategory(category);
                  }
                },
              );

              // Wrap with Tooltip if available
              if (_categoryTooltips.containsKey(category)) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Tooltip(
                    message: _categoryTooltips[category]!,
                    child: chip,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: chip,
              );
            },
          ),
     );
  }

  // Removed _buildCategoryBar since it is replaced by Search Bar

  Widget _buildCourseGrid(AsyncValue<List<Course>> coursesAsync, double width, String selectedCategory, String searchQuery, double maxPrice, bool showFreeOnly) {
    return coursesAsync.when(
      data: (courses) {
        final filtered = courses.where((course) {
          final matchesCategory = selectedCategory == 'All' || course.category == selectedCategory;
          final matchesSearch = course.title.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesPrice = course.price <= maxPrice;
          final matchesFreeOnly = !showFreeOnly || course.isFree;

          return matchesCategory && matchesSearch && matchesPrice && matchesFreeOnly;
        }).toList();
        
        if (filtered.isEmpty) {
           return Center(child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text('No courses found matching your criteria.', style: TextStyle(color: AppTheme.slateGrey)),
          ));
        }

        // Responsive Grid Columns and Ratio
        int gridCols = 1;
        // Reset to 0.85 to allow card to be taller and accommodate the content without overflow
        double ratio = 0.85; 

        if (width >= 1280) {
          gridCols = 4;
          ratio = 0.85; // Desktop: Tall card
        } else if (width >= 1024) {
          gridCols = 3;
          ratio = 0.9;
        } else if (width >= 640) {
          gridCols = 2;
          ratio = 0.8;
        }

        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCols,
                childAspectRatio: ratio, 
                crossAxisSpacing: 16, 
                mainAxisSpacing: 16,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _ModernCourseCard(course: filtered[index]);
              },
            ),
            const SizedBox(height: 48),
            _Pagination(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.deepEmerald)),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _ModernCourseCard extends StatelessWidget {
  final Course course;
  const _ModernCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/courses/${course.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Badges
            AspectRatio(
              aspectRatio: 16 / 9, 
              child: Stack(
                fit: StackFit.expand,
                children: [
                   Image.network(
                    course.imageUrl, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                  
                  // Badges
                  if (course.isPopular)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.deepEmerald,
                        borderRadius: BorderRadius.circular(20), // Pill shape
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset:const Offset(0, 2))
                        ]
                      ),
                      child: Text('POPULAR', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                   if (course.isNew && !course.isPopular)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset:const Offset(0, 2))
                        ]
                      ),
                      child: Text('NEW', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metadata Row
                    Row(
                      children: [
                         const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                         const SizedBox(width: 4),
                         Text(
                           course.rating.toString(), 
                           style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.slateGrey)
                         ),
                         const SizedBox(width: 4),
                         Text(
                           '(${course.reviews})', 
                           style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)
                         ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter( // Revert to Inter (Standard Typography)
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        height: 1.2,
                        color: Colors.black87
                      ), 
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      course.instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: AppTheme.deepEmerald, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    
                    const Spacer(), 
                    
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          course.isFree ? 'Free' : '\$${course.price}', 
                          style: GoogleFonts.inter(
                            fontSize: 16, 
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937)
                          )
                        ),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.deepEmerald,
                            borderRadius: BorderRadius.circular(30), // Pill Button
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.deepEmerald.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          ),
                          child: const Text(
                            'Enroll Now', 
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarFilters extends StatelessWidget {
  final Function(double) onPriceChanged;
  final Function(bool?) onFreeOnlyChanged;
  
  const _SidebarFilters({required this.onPriceChanged, required this.onFreeOnlyChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Filters', style: Theme.of(context).textTheme.headlineSmall), // Removed Title
          const SizedBox(height: 24),
          
          _FilterSection(title: 'Price', child: Column(
            children: [
               Slider(
                 value: 50,
                 min: 0,
                 max: 200,
                 activeColor: AppTheme.deepEmerald,
                 onChanged: (val) => onPriceChanged(val),
               ),
               CheckboxListTile(
                 title: const Text('Free only'),
                 value: false,
                 activeColor: AppTheme.deepEmerald,
                 contentPadding: EdgeInsets.zero,
                 controlAffinity: ListTileControlAffinity.leading,
                 onChanged: onFreeOnlyChanged,
               ),
            ],
          )),
          
          _FilterSection(title: 'Level', child: Column(
            children: [
              CheckboxListTile(title: const Text('Beginner'), value: true, onChanged: (v){}, activeColor: AppTheme.deepEmerald, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading),
              CheckboxListTile(title: const Text('Intermediate'), value: false, onChanged: (v){}, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading),
              CheckboxListTile(title: const Text('Advanced'), value: false, onChanged: (v){}, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading),
            ],
          )),
        ],
      ),
    );
  }
}

class _MobileFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Icon(Icons.tune, color: AppTheme.deepEmerald), // Icon instead of Text 'Filters'
      iconColor: AppTheme.deepEmerald,
      collapsedIconColor: AppTheme.deepEmerald,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
               // Simplify mobile filters
               // const Text('Advanced filters (Price, Level, Duration) go here'), // Removed Text
               const SizedBox.shrink(),
            ],
          ),
        )
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _FilterSection({required this.title, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      child,
      const Divider(height: 32),
    ]);
  }
}

class _UserProfile extends ConsumerWidget {
  final String userId;
  const _UserProfile({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(userId));
    return userAsync.when(
      data: (user) => CircleAvatar(
        radius: 16,
        backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
        backgroundColor: AppTheme.deepEmerald,
        child: user?.photoUrl == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
      ),
      loading: () => const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
      error: (_, __) => const CircleAvatar(radius: 16, backgroundColor: Colors.red),
    );
  }
}

class _Pagination extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
        const SizedBox(width: 16),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.deepEmerald),
          child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
          child: const Text('2', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
         const SizedBox(width: 16),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
      ],
    );
  }
}
