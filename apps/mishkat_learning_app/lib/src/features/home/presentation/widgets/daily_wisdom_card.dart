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
      child: Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppTheme.surfaceSand.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.format_quote,
              color: AppTheme.accentGold,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              quote,
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: AppTheme.primaryEmerald,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              width: 80,
              color: AppTheme.accentGold.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              source,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryNavy,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
