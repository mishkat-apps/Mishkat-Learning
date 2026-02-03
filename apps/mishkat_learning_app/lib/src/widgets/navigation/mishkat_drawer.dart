import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class MishkatDrawer extends StatelessWidget {
  const MishkatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 300,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.secondaryNavy.withValues(alpha: 0.9),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Drawer Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.radiantGold.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.radiantGold.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.radiantGold,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'MISHKAT LEARNING',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.radiantGold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Navigation Links
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.school_outlined,
                        label: 'COURSES',
                        onTap: () {
                          context.pop(); // Close drawer
                          context.go('/login');
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.info_outline,
                        label: 'ABOUT',
                        onTap: () {
                          context.pop();
                          context.go('/about');
                        },
                      ),
                    ],
                  ),
                ),

                // Auth Buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.pop();
                            context.go('/login');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                          ),
                          child: const Text('SIGN IN'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                            context.go('/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.radiantGold,
                            foregroundColor: AppTheme.secondaryNavy,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                            shadowColor: AppTheme.radiantGold.withValues(alpha: 0.4),
                          ),
                          child: const Text('JOIN NOW'),
                        ),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.radiantGold.withValues(alpha: 0.9)),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
