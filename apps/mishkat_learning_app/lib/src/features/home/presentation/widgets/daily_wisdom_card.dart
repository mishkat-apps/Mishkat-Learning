import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class DailyWisdomCard extends StatelessWidget {
  final String quote;
  final String source;

  const DailyWisdomCard({
    super.key,
    required this.quote,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slateGrey,
                    letterSpacing: 1,
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
            
            // Quote
            Text(
              quote,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: AppTheme.deepEmerald,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
