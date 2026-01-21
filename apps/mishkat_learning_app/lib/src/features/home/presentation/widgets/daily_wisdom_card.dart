import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class DailyWisdomCard extends StatelessWidget {
  final String quote;
  final String? quoteAr;
  final String source;

  const DailyWisdomCard({
    super.key,
    required this.quote,
    this.quoteAr,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.radiantGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  source.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.slateGrey.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {},
                  color: AppTheme.slateGrey,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Arabic Quote (if present)
            if (quoteAr != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  quoteAr!,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepEmerald,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // English Quote
            Text(
              quote,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryNavy,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
