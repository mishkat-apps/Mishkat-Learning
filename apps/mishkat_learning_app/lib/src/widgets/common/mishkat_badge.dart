import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MishkatBadgeType {
  popular,
  newAddition,
  featured,
  inProgress,
  completed,
  bestseller,
}

class MishkatBadge extends StatelessWidget {
  final MishkatBadgeType type;
  final String? label;

  const MishkatBadge({
    super.key,
    required this.type,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBadge();
  }

  Widget _buildBadge() {
    final config = _getBadgeConfig();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: config.gradient,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: config.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                config.icon,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                (label ?? config.defaultLabel).toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _BadgeConfig _getBadgeConfig() {
    switch (type) {
      case MishkatBadgeType.popular:
        return _BadgeConfig(
          color: const Color(0xFFF59E0B),
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.star_rounded,
          defaultLabel: 'Popular',
        );
      case MishkatBadgeType.newAddition:
        return _BadgeConfig(
          color: const Color(0xFF10B981),
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.auto_awesome_rounded,
          defaultLabel: 'New',
        );
      case MishkatBadgeType.featured:
        return _BadgeConfig(
          color: const Color(0xFF8B5CF6),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.workspace_premium_rounded,
          defaultLabel: 'Featured',
        );
      case MishkatBadgeType.inProgress:
        return _BadgeConfig(
          color: const Color(0xFF3B82F6),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.play_arrow_rounded,
          defaultLabel: 'In Progress',
        );
      case MishkatBadgeType.completed:
        return _BadgeConfig(
          color: const Color(0xFF064E3B),
          gradient: const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF065F46)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.check_circle_rounded,
          defaultLabel: 'Completed',
        );
      case MishkatBadgeType.bestseller:
        return _BadgeConfig(
          color: const Color(0xFF92400E),
          gradient: const LinearGradient(
            colors: [Color(0xFFFBBF24), Color(0xFF92400E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.trending_up_rounded,
          defaultLabel: 'Bestseller',
        );
    }
  }
}

class _BadgeConfig {
  final Color color;
  final Gradient gradient;
  final IconData icon;
  final String defaultLabel;

  _BadgeConfig({
    required this.color,
    required this.gradient,
    required this.icon,
    required this.defaultLabel,
  });
}
