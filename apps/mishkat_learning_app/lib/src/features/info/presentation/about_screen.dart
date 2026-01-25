import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/navigation/mishkat_navbar.dart';
import '../../../widgets/common/mishkat_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MishkatNavbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildMission(context),
            _buildValues(context),
            const MishkatFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      decoration: const BoxDecoration(
        color: AppTheme.secondaryNavy,
      ),
      child: Column(
        children: [
          Text(
            'ABOUT US',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.radiantGold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Illuminating the Path\nof Authentic Wisdom',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'Mishkat Learning is a premium educational platform dedicated to preserving and disseminating scholarly Shia teachings through modern technology and spiritual excellence.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 18,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMission(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OUR MISSION',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.radiantGold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'To empower unauthenticated seekers with verified knowledge and spiritual depth.',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'We believe that true education goes beyond information—it is a transformation of the heart and mind. Our platform bridges the gap between traditional scholarship and contemporary learning needs.',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: AppTheme.slateGrey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 80),
            if (MediaQuery.of(context).size.width > 800)
              Expanded(
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: AppTheme.radiantGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.radiantGold.withValues(alpha: 0.2)),
                  ),
                  child: const Center(
                    child: Icon(Icons.school_rounded, size: 100, color: AppTheme.radiantGold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildValues(BuildContext context) {
    final values = [
      {'title': 'Scholarly Accuracy', 'desc': 'Content verified by recognized scholars and narrators.'},
      {'title': 'Spiritual Excellence', 'desc': 'Focus on the inner dimension of learning and taqwa.'},
      {'title': 'Modern Accessibility', 'desc': 'High-definition video production for the modern digital age.'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      color: AppTheme.sacredCream.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text(
            'OUR CORE VALUES',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.radiantGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: values.map((v) => Container(
              width: 300,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    v['title']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    v['desc']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AppTheme.slateGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
