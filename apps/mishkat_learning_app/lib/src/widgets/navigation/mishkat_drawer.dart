import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class MishkatDrawer extends StatelessWidget {
  const MishkatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.secondaryNavy,
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.secondaryNavy,
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.radiantGold,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MISHKAT LEARNING',
                    style: GoogleFonts.montserrat(
                      color: AppTheme.radiantGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
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
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'SIGN IN',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
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
                    ),
                    child: Text(
                      'JOIN NOW',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.radiantGold.withValues(alpha: 0.8)),
      title: Text(
        label,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
