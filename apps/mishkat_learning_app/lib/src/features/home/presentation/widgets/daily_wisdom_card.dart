import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class DailyWisdomCard extends StatelessWidget {
  final String quote;
  final String? quoteAr;
  final String source;
  final String? reference;

  const DailyWisdomCard({
    super.key,
    required this.quote,
    this.quoteAr,
    required this.source,
    this.reference,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.slateGrey.withValues(alpha: 0.6),
                        ),
                      ),
                      if (reference != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          reference!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () async {
                    final text = '$quote\n\n${quoteAr ?? ""}\n\n- $source\n${reference ?? ""}';
                    try {
                      await Share.share(text);
                    } catch (e) {
                      // Fallback for web or unsupported platforms
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing not supported on this platform, copy text manually.')),
                        );
                      }
                    }
                  },
                  color: AppTheme.slateGrey,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Arabic Quote (if present)
            if (quoteAr != null) ...[
              Text(
                quoteAr!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lateef(
                  fontSize: 32,
                  fontWeight: FontWeight.normal,
                  color: AppTheme.deepEmerald,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // English Quote
            Text(
              quote,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
