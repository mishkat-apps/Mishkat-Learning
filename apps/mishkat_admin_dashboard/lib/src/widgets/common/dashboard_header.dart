import 'package:flutter/material.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/notification_popover.dart';
import 'package:mishkat_admin_dashboard/src/widgets/common/user_profile_menu.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AdminTheme.background,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.foreground,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdminTheme.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          if (action != null) ...[
            action!,
            const SizedBox(width: 24),
            Container(height: 24, width: 1, color: AdminTheme.border),
            const SizedBox(width: 24),
          ],
          const NotificationPopover(),
          const SizedBox(width: 16),
          const UserProfileMenu(),
        ],
      ),
    );
  }
}
