import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;
    final isTablet = width >= 600 && width <= 1024;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) const _Sidebar(),
          Expanded(
            child: Scaffold(
              appBar: null,
              body: child,
              bottomNavigationBar: !isDesktop ? const _BottomNav() : null,
              drawer: isTablet ? const Drawer(child: _Sidebar()) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppTheme.slateGrey,
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lightbulb, color: AppTheme.radiantGold, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'MISHKAT LEARNING',
                    style: TextStyle(
                      color: AppTheme.radiantGold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _NavTile(label: 'Dashboard', icon: Icons.dashboard_outlined, path: '/dashboard'),
          const _NavTile(label: 'Catalog', icon: Icons.menu_book_outlined, path: '/courses'),
          const _NavTile(label: 'My Courses', icon: Icons.school_outlined, path: '/my-courses'),
          const _NavTile(label: 'Style Guide', icon: Icons.palette_outlined, path: '/style-guide'),
          const Spacer(),
          const _NavTile(label: 'Profile', icon: Icons.account_circle_outlined, path: '/profile'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String path;
  const _NavTile({required this.label, required this.icon, required this.path});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => context.go(path),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.deepEmerald,
      unselectedItemColor: AppTheme.slateGrey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Catalog'),
        BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'My Courses'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
      ],
      onTap: (index) {
        final paths = ['/dashboard', '/courses', '/my-courses', '/profile'];
        context.go(paths[index]);
      },
    );
  }
}
