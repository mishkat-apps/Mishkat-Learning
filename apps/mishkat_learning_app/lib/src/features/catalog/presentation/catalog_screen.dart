import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/domain/models.dart';
import '../../../widgets/common/mishkat_badge.dart';

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

  CatalogState({
    required this.searchQuery,
    required this.selectedCategory,
    required this.maxPrice,
    required this.showFreeOnly,
  });

  factory CatalogState.initial() => CatalogState(
        searchQuery: '',
        selectedCategory: 'All',
        maxPrice: 200.0,
        showFreeOnly: false,
      );

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
  CatalogState build() => CatalogState.initial();

  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setSelectedCategory(String category) => state = state.copyWith(selectedCategory: category);
  void setMaxPrice(double price) => state = state.copyWith(maxPrice: price);
  void setShowFreeOnly(bool show) => state = state.copyWith(showFreeOnly: show);
}

final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(CatalogNotifier.new);

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
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
          style: GoogleFonts.montserrat(
            color: AppTheme.radiantGold, 
            fontWeight: FontWeight.w800, 
            fontSize: 16,
            letterSpacing: 2.0,
          ),
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
                      _buildSearchBar(ref),
                      const SizedBox(height: 32),
                      
                      if (!isWide) ...[
                        _buildCategoryScroll(catalogState.selectedCategory),
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

  Widget _buildSearchBar(WidgetRef ref) {
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
          hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.radiantGold),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryScroll(String selected) {
    final categories = ['All', 'Fiqh', 'Aqeedah', 'Hadith', 'History', 'Language'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => ref.read(catalogProvider.notifier).setSelectedCategory(cat),
              selectedColor: AppTheme.deepEmerald.withValues(alpha: 0.1),
              checkmarkColor: AppTheme.deepEmerald,
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.deepEmerald : AppTheme.slateGrey,
              ),
            ),
          );
        },
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
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
            if (state.searchQuery.isNotEmpty)
              Text(
                'Showing results for "${state.searchQuery}"',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
              ),
          ],
        ),
        Text(
          'Sort by: Popular',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.radiantGold,
          ),
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
          return matchSearch && matchCat && matchPrice && matchFree;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No courses found', style: GoogleFonts.inter(color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            mainAxisExtent: 360,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _ModernCourseCard(course: filtered[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}

class _SidebarFilters extends StatelessWidget {
  final CatalogState state;
  final Function(String) onCategoryChanged;
  final Function(double) onPriceChanged;
  final Function(bool?) onFreeOnlyChanged;

  const _SidebarFilters({
    required this.state,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onFreeOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppTheme.radiantGold,
              ),
            ),
            const SizedBox(height: 32),
            
            _FilterSection(
              title: 'Categories',
              child: Column(
                children: ['All', 'Fiqh', 'Aqeedah', 'Hadith', 'History', 'Language'].map((cat) {
                  final isSelected = state.selectedCategory == cat;
                  return _CategoryTile(
                    label: cat,
                    isSelected: isSelected,
                    onTap: () => onCategoryChanged(cat),
                  );
                }).toList(),
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
                      Text('\$0', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                      Text('${state.maxPrice.toInt()} USD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CheckboxListTile(
                    title: Text('Free Only', style: GoogleFonts.inter(fontSize: 14)),
                    value: state.showFreeOnly,
                    onChanged: onFreeOnlyChanged,
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
  final VoidCallback onTap;

  const _CategoryTile({required this.label, required this.isSelected, required this.onTap});

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
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.radiantGold : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
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
          style: GoogleFonts.montserrat(
            fontSize: 14,
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
        onTap: () => context.push('/courses/${course.slug}'),
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
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.radiantGold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
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
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        course.isFree ? 'FREE' : '${course.price.toInt()} USD',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
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
