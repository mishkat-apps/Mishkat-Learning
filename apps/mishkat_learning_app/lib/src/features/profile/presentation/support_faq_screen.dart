import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class SupportFaqScreen extends StatelessWidget {
  const SupportFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I access my certificates?',
        'answer': 'Once you complete a course with 100% progress, your certificate will automatically appear in your Profile section under "Earned Certificates".'
      },
      {
        'question': 'How can I reset my progress?',
        'answer': 'Currently, progress resetting is only available through our support team. Please contact us via the email below.'
      },
      {
        'question': 'Can I watch lessons offline?',
        'answer': 'Offline mode is currently in development and will be available in a future update.'
      },
      {
        'question': 'What payment methods are supported?',
        'answer': 'We support various payment methods through Razorpay, including Credit/Debit Cards, UPI, and Digital Wallets.'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Support & FAQ',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.secondaryNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            ...faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faq['answer']!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.slateGrey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.deepEmerald.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                   const Icon(Icons.mail_outline, color: AppTheme.deepEmerald, size: 32),
                   const SizedBox(height: 16),
                   Text(
                     'Still need help?',
                     style: GoogleFonts.montserrat(
                       fontWeight: FontWeight.bold,
                       fontSize: 16,
                       color: AppTheme.secondaryNavy,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     'Our support team is available 24/7 to assist you on your journey.',
                     textAlign: TextAlign.center,
                     style: GoogleFonts.inter(color: AppTheme.slateGrey, fontSize: 13),
                   ),
                   const SizedBox(height: 16),
                   TextButton(
                     onPressed: () {},
                     child: Text(
                       'support@mishkatlearning.com',
                       style: GoogleFonts.inter(
                         fontWeight: FontWeight.bold,
                         color: AppTheme.deepEmerald,
                       ),
                     ),
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
