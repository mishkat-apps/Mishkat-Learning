import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/domain/models.dart';
import '../../courses/data/subject_area_repository.dart';
import '../../courses/domain/subject_area.dart';
import '../../../widgets/common/mishkat_badge.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const CatalogScreen({super.key, this.initialFilter});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class CatalogState {
  final String searchQuery;
  final String selectedCategory;
  final double maxPrice;
  final bool showFreeOnly;
  final bool showNewOnly;
  final bool showFeaturedOnly;

  CatalogState({
    required this.searchQuery,
    required this.selectedCategory,
    required this.maxPrice,
    required this.showFreeOnly,
    required this.showNewOnly,
    required this.showFeaturedOnly,
  });

  factory CatalogState.initial() => CatalogState(
        searchQuery: '',
        selectedCategory: 'All',
        maxPrice: 200.0,
        showFreeOnly: false,
        showNewOnly: false,
        showFeaturedOnly: false,
      );

  CatalogState copyWith({
    String? searchQuery,
    String? selectedCategory,
    double? maxPrice,
    bool? showFreeOnly,
    bool? showNewOnly,
    bool? showFeaturedOnly,
  }) {
    return CatalogState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      maxPrice: maxPrice ?? this.maxPrice,
      showFreeOnly: showFreeOnly ?? this.showFreeOnly,
      showNewOnly: showNewOnly ?? this.showNewOnly,
      showFeaturedOnly: showFeaturedOnly ?? this.showFeaturedOnly,
    );
  }
}

class CatalogNotifier extends Notifier<CatalogState> {
  @override
  CatalogState build() => CatalogState.initial();

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setSelectedCategory(String category) => state = state.copyWith(selectedCategory: category);
  void setMaxPrice(double price) => state = state.copyWith(maxPrice: price);
  void setShowFreeOnly(bool show) => state = state.copyWith(showFreeOnly: show);
  void setShowNewOnly(bool show) => state = state.copyWith(showNewOnly: show);
  void setShowFeaturedOnly(bool show) => state = state.copyWith(showFeaturedOnly: show);
}

final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(CatalogNotifier.new);

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialFilter == 'new') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(catalogProvider.notifier).setShowNewOnly(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1100;
    final catalogState = ref.watch(catalogProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.secondaryNavy),
          onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
        ), 
        centerTitle: true,
        title: Text(
          'COURSE CATALOG', 
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.secondaryNavy),
            onPressed: () {}, 
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            _SidebarFilters(
              state: catalogState,
              onCategoryChanged: (cat) => ref.read(catalogProvider.notifier).setSelectedCategory(cat),
              onPriceChanged: (val) => ref.read(catalogProvider.notifier).setMaxPrice(val),
              onFreeOnlyChanged: (val) => ref.read(catalogProvider.notifier).setShowFreeOnly(val ?? false),
              onNewOnlyChanged: (val) => ref.read(catalogProvider.notifier).setShowNewOnly(val ?? false),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 40 : 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context, ref, isWide),
                      const SizedBox(height: 32),
                      
                      if (!isWide) ...[
                        _buildCategoryScroll(catalogState, ref),
                        const SizedBox(height: 24),
                      ],
                      
                      _buildResultsHeader(context, catalogState),
                      const SizedBox(height: 24),
                      
                      _buildCourseGrid(ref.watch(coursesStreamProvider), width, catalogState),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: TextField(
        onChanged: (val) => ref.read(catalogProvider.notifier).setSearchQuery(val),
        decoration: InputDecoration(
          hintText: 'What do you want to learn today?',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.radiantGold),
          suffixIcon: isWide 
            ? null 
            : IconButton(
                onPressed: () {
                   showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => _buildFilterBottomSheet(ref),
                   );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                ),
              ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryScroll(CatalogState state, WidgetRef ref) {
    final subjectAreasAsync = ref.watch(subjectAreasProvider);

    return SizedBox(
      height: 40,
      child: subjectAreasAsync.when(
        data: (subjectAreas) {
           return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // All Filter
              _CategoryTile(
                label: 'All',
                isSelected: state.selectedCategory == 'All' && !state.showNewOnly && !state.showFeaturedOnly,
                onTap: () {
                  ref.read(catalogProvider.notifier).setSelectedCategory('All');
                  ref.read(catalogProvider.notifier).setShowNewOnly(false);
                  ref.read(catalogProvider.notifier).setShowFeaturedOnly(false);
                },
              ),
              const SizedBox(width: 8),

              // New Filter
              _CategoryTile(
                label: 'New',
                isSelected: state.showNewOnly,
                showDot: false, // Don't show dot for special filters if desired
                onTap: () {
                   // Toggle logic or exclusive logic?
                   // Requirement: <All> <New> <Featured> <Subjects...>
                   // Let's make "New" act like a filter toggle that also deselects category/featured to avoid confusion, 
                   // OR just toggles the property. The user request implies a list of filters.
                   // If I click "New", I expect to see New books. If I click "Aqaid", I expect Aqaid books.
                   // So it acts like a category.
                   ref.read(catalogProvider.notifier).setSelectedCategory('All');
                   ref.read(catalogProvider.notifier).setShowNewOnly(true);
                   ref.read(catalogProvider.notifier).setShowFeaturedOnly(false);
                },
              ),
              const SizedBox(width: 8),

              // Featured Filter
              _CategoryTile(
                label: 'Featured',
                isSelected: state.showFeaturedOnly,
                showDot: false,
                onTap: () {
                   ref.read(catalogProvider.notifier).setSelectedCategory('All');
                   ref.read(catalogProvider.notifier).setShowNewOnly(false);
                   ref.read(catalogProvider.notifier).setShowFeaturedOnly(true);
                },
              ),
              const SizedBox(width: 8),

              // Subject Areas
              ...subjectAreas.map((subject) {
                final isSelected = state.selectedCategory == subject.name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: subject.alternativeName ?? subject.name,
                    child: _CategoryTile(
                      label: subject.name,
                      isSelected: isSelected,
                      onTap: () {
                         ref.read(catalogProvider.notifier).setSelectedCategory(subject.name);
                         ref.read(catalogProvider.notifier).setShowNewOnly(false);
                         ref.read(catalogProvider.notifier).setShowFeaturedOnly(false);
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context, CatalogState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.selectedCategory == 'All' ? 'All Courses' : state.selectedCategory,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
            if (state.searchQuery.isNotEmpty)
              Text(
                'Showing results for "${state.searchQuery}"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseGrid(AsyncValue<List<Course>> coursesAsync, double width, CatalogState state) {
    return coursesAsync.when(
      data: (courses) {
        final filtered = courses.where((c) {
          final matchSearch = c.title.toLowerCase().contains(state.searchQuery.toLowerCase());
          final matchCat = state.selectedCategory == 'All' || c.category == state.selectedCategory;
          final matchPrice = c.price <= state.maxPrice;
          final matchFree = !state.showFreeOnly || c.isFree;
          final matchNew = !state.showNewOnly || c.isNew;
          final matchFeatured = !state.showFeaturedOnly || c.isPopular;
          return matchSearch && matchCat && matchPrice && matchFree && matchNew && matchFeatured;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No courses found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              ],
            ),
          );
        }

        // Calculate dynamic height
        final isWide = width >= 1100;
        final horizontalPadding = isWide ? 80.0 : 48.0;
        final availableWidth = (width - horizontalPadding).clamp(0.0, 1000.0);
        final crossAxisCount = (availableWidth / 350).ceil();
        // Avoid division by zero if width is extremely small
        final count = crossAxisCount > 0 ? crossAxisCount : 1;
        final cardWidth = (availableWidth - (24 * (count - 1))) / count;
        final imageHeight = cardWidth / 1.5;
        // Content height approx: Padding(16+16) + Cat(12) + Space(8) + Title(40) + Space(12) + Row(20) = ~124
        // Add a bit of buffer
        final mainAxisExtent = imageHeight + 135;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            mainAxisExtent: mainAxisExtent,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _ModernCourseCard(course: filtered[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildFilterBottomSheet(WidgetRef ref) {
    final state = ref.watch(catalogProvider);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTERS',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppTheme.radiantGold,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Price Range',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: state.maxPrice,
            min: 0,
            max: 200,
            activeColor: AppTheme.radiantGold,
            inactiveColor: Colors.grey.withValues(alpha: 0.1),
            onChanged: (val) => ref.read(catalogProvider.notifier).setMaxPrice(val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$0', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey)),
              Text('${state.maxPrice.toInt()} USD', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text('Free Only', style: GoogleFonts.roboto(fontSize: 14)),
            value: state.showFreeOnly,
            onChanged: (val) => ref.read(catalogProvider.notifier).setShowFreeOnly(val ?? false),
            activeColor: AppTheme.radiantGold,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _SidebarFilters extends ConsumerWidget {
  final CatalogState state;
  final Function(String) onCategoryChanged;
  final Function(double) onPriceChanged;
  final Function(bool?) onFreeOnlyChanged;
  final Function(bool?) onNewOnlyChanged;

  const _SidebarFilters({
    required this.state,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onFreeOnlyChanged,
    required this.onNewOnlyChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAreasAsync = ref.watch(subjectAreasProvider);

    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FILTERS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                color: AppTheme.radiantGold,
              ),
            ),
            const SizedBox(height: 32),
            
            _FilterSection(
              title: 'Subject Areas',
              child: subjectAreasAsync.when(
                data: (subjectAreas) => Column(
                  children: [
                    _CategoryTile(
                      label: 'All',
                      isSelected: state.selectedCategory == 'All',
                      onTap: () => onCategoryChanged('All'),
                    ),
                    ...subjectAreas.map((subject) {
                      final isSelected = state.selectedCategory == subject.name;
                      return Tooltip(
                        message: subject.alternativeName ?? subject.name,
                        child: _CategoryTile(
                          label: subject.name,
                          isSelected: isSelected,
                          onTap: () => onCategoryChanged(subject.name),
                        ),
                      );
                    }),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => const SizedBox(),
              ),
            ),
            
            _FilterSection(
              title: 'Price Range',
              child: Column(
                children: [
                  Slider(
                    value: state.maxPrice,
                    min: 0,
                    max: 200,
                    activeColor: AppTheme.radiantGold,
                    inactiveColor: Colors.grey.withValues(alpha: 0.1),
                    onChanged: (val) => onPriceChanged(val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$0', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey)),
                      Text('${state.maxPrice.toInt()} USD', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CheckboxListTile(
                    title: Text('Free Only', style: GoogleFonts.roboto(fontSize: 14)),
                    value: state.showFreeOnly,
                    onChanged: onFreeOnlyChanged,
                    activeColor: AppTheme.radiantGold,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: Text('New Only', style: GoogleFonts.roboto(fontSize: 14)),
                    value: state.showNewOnly,
                    onChanged: onNewOnlyChanged,
                    activeColor: AppTheme.radiantGold,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool showDot;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.isSelected,
    this.showDot = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryNavy.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (showDot) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.radiantGold : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.secondaryNavy : AppTheme.slateGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        const SizedBox(height: 16),
        child,
        const SizedBox(height: 40),
      ],
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          if (course.slug.isNotEmpty) {
            context.goNamed(
              'course_details',
              pathParameters: {'courseSlug': course.slug},
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course details currently unavailable.')),
            );
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(course.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                if (course.isPopular)
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: MishkatBadge(type: MishkatBadgeType.popular),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.category.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: AppTheme.radiantGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        course.isFree ? 'FREE' : '${course.price.toInt()} USD',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.deepEmerald,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
