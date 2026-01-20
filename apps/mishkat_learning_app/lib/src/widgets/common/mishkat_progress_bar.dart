import 'package:flutter/material.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class MishkatProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final bool showLabel;
  final String? label;
  final Color? backgroundColor;

  const MishkatProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.showLabel = false,
    this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label ?? 'MODULE PROGRESS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.deepEmerald,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepEmerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.deepEmerald.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.radiantGold, Color(0xFFEAB308)],
                ),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
