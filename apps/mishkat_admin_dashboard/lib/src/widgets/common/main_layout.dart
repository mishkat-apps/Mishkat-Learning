import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/auth/data/auth_repository.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/notification_popover.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/user_profile_menu.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final userEmail = user?.email ?? '';

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: AdminTheme.sidebarBackground,
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, color: AdminTheme.radiantGold, size: 32),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MISHKAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 2,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'ADMIN',
                          style: TextStyle(
                            color: AdminTheme.radiantGold,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 4,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  onTap: () => context.go('/'),
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  label: 'Users',
                  onTap: () => context.go('/users'),
                ),
                _SidebarItem(
                  icon: Icons.book_outlined,
                  label: 'Courses',
                  onTap: () => context.go('/courses'),
                ),
                _SidebarItem(
                  icon: Icons.assignment_ind_outlined,
                  label: 'Enrollments',
                  onTap: () => context.go('/enrollments'),
                ),
                _SidebarItem(
                  icon: Icons.payments_outlined,
                  label: 'Payments',
                  onTap: () => context.go('/payments'),
                ),
                _SidebarItem(
                  icon: Icons.campaign_outlined,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Technical Admin',
                  onTap: () => context.go('/technical'),
                ),
                if (userEmail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => context.go('/settings'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AdminTheme.secondaryNavy,
                        ),
                      ),
                      const Spacer(),
                      const NotificationPopover(),
                      const SizedBox(width: 16),
                      const UserProfileMenu(),
                    ],
                  ),
                ),
                // Main Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 22),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        hoverColor: AdminTheme.sidebarHover,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      ),
    );
  }
}
