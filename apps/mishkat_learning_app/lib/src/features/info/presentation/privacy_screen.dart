import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/navigation/mishkat_navbar.dart';
import '../../../widgets/common/mishkat_footer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MishkatNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(),
            const MishkatFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: const BoxDecoration(color: AppTheme.footerEmerald),
      child: Column(
        children: [
          Text(
            'PRIVACY POLICY',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.radiantGold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Trust is our Priority',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Information Collection',
              'We collect information that you provide directly to us, such as when you create an account, purchase a course, or contact support. This may include your name, email address, and payment information.',
            ),
            _buildSection(
              '2. Use of Information',
              'We use the information we collect to provide, maintain, and improve our services, including to process transactions and send you related information.',
            ),
            _buildSection(
              '3. Data Protection',
              'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
            ),
            _buildSection(
              '4. Third-Party Services',
              'We may use third-party service providers to help us operate our business and the platform, such as payment processors and analytics services.',
            ),
            _buildSection(
              '5. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at support@mishkatlearning.com.',
            ),
            const SizedBox(height: 40),
            Text(
              'Last Updated: January 21, 2026',
              style: GoogleFonts.roboto(fontSize: 12, color: AppTheme.slateGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.roboto(fontSize: 16, color: AppTheme.slateGrey, height: 1.6),
          ),
        ],
      ),
    );
  }
}
