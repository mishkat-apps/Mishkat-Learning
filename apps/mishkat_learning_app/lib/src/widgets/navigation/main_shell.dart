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
              appBar: !isDesktop
                  ? AppBar(
                      title: const Text('Mishkat'),
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.secondaryNavy,
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage('https://placeholder.com/150'),
                          ),
                        ),
                      ],
                    )
                  : null,
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
      color: AppTheme.secondaryNavy,
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lightbulb, color: AppTheme.accentGold, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'MISHKAT',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _NavTile(label: 'Home', icon: Icons.home_outlined, path: '/dashboard'),
          const _NavTile(label: 'Browse', icon: Icons.book_outlined, path: '/courses'),
          const _NavTile(label: 'My Courses', icon: Icons.bookmark_outline, path: '/library'),
          const Spacer(),
          const _NavTile(label: 'Profile', icon: Icons.person_outline, path: '/profile'),
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
      selectedItemColor: AppTheme.primaryEmerald,
      unselectedItemColor: AppTheme.textGrey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Browse'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'My Courses'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (index) {
        final paths = ['/dashboard', '/courses', '/library', '/profile'];
        context.go(paths[index]);
      },
    );
  }
}
