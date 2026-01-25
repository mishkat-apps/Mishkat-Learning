import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/navigation/mishkat_navbar.dart';
import '../../../widgets/common/mishkat_footer.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MishkatNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContactForm(),
            const MishkatFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: const BoxDecoration(color: AppTheme.secondaryNavy),
      child: Column(
        children: [
          Text(
            'CONTACT US',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.radiantGold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'We are here to help you\non your journey.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(label: 'Name', hint: 'Your full name'),
            const SizedBox(height: 24),
            _buildTextField(label: 'Email', hint: 'Your email address'),
            const SizedBox(height: 24),
            _buildTextField(label: 'Message', hint: 'How can we help?', maxLines: 5),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.radiantGold,
                  foregroundColor: AppTheme.secondaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                ),
                child: const Text('SEND MESSAGE'),
              ),
            ),
            const SizedBox(height: 60),
            const Divider(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email_outlined, color: AppTheme.radiantGold),
                const SizedBox(width: 12),
                Text(
                  'support@mishkatlearning.com',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600, color: AppTheme.secondaryNavy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.sacredCream.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
