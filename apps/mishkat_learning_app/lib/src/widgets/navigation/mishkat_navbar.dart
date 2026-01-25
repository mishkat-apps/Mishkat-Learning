import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class MishkatNavbar extends StatelessWidget implements PreferredSizeWidget {
  const MishkatNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo Section
          GestureDetector(
            onTap: () => context.go('/'),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.radiantGold,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISHKAT',
                      style: GoogleFonts.montserrat(
                        color: AppTheme.radiantGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 2,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'LEARNING',
                      style: GoogleFonts.montserrat(
                        color: AppTheme.radiantGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 4,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          
          if (!isMobile) ...[
            TextButton(
              onPressed: () => context.go('/login'), // Keeping same route as before
              child: Text(
                'COURSES',
                style: GoogleFonts.roboto(
                  color: Colors.white.withValues(alpha: 0.9), // Distinct from Auth buttons
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 32),
            TextButton(
              onPressed: () => context.go('/about'),
              child: Text(
                'ABOUT',
                style: GoogleFonts.roboto(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 32),
          ],

          // Auth Buttons
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          else ...[
            Container(
              height: 24,
              width: 1,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 32),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'SIGN IN',
                style: GoogleFonts.roboto(
                  color: AppTheme.radiantGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => context.go('/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.radiantGold,
                foregroundColor: AppTheme.secondaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'JOIN NOW',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
