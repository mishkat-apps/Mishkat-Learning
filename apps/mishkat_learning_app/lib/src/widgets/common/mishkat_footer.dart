import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class MishkatFooter extends StatelessWidget {
  const MishkatFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.footerEmerald,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          _buildFooterMain(context),
          const SizedBox(height: 60),
          const Divider(color: Colors.white10),
          const SizedBox(height: 40),
          _buildFooterBottom(context),
        ],
      ),
    );
  }

  Widget _buildFooterMain(BuildContext context) {
    if (MediaQuery.of(context).size.width < 768) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFooterLogo(),
          const SizedBox(height: 40),
          _buildFooterLinks(context),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildFooterLogo()),
        const Spacer(),
        _buildFooterLinks(context),
      ],
    );
  }

  Widget _buildFooterLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, color: AppTheme.radiantGold, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 16),
        Text(
          'Illuminating knowledge for the modern seeker.',
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildFooterBottom(BuildContext context) {
    return Row(
      children: [
        Text(
          '© ${DateTime.now().year} Mishkat Learning. All rights reserved.',
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.white38),
        ),
        const Spacer(),
        Row(
          children: [
            _buildSocialIcon(Icons.discord),
            const SizedBox(width: 20),
            _buildSocialIcon(Icons.telegram),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFooterColumn(context, 'PLATFORM', [
          {'label': 'Courses', 'path': '/login'},
          {'label': 'About Us', 'path': '/about'},
        ]),
        const SizedBox(width: 60),
        _buildFooterColumn(context, 'SUPPORT', [
          {'label': 'Contact Us', 'path': '/contact'},
          {'label': 'Privacy Policy', 'path': '/privacy'},
        ]),
      ],
    );
  }

  Widget _buildFooterColumn(BuildContext context, String title, List<Map<String, String>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.go(link['path']!),
            child: Text(
              link['label']!,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(icon, color: Colors.white38, size: 20);
  }
}
