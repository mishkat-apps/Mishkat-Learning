import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_admin_dashboard/src/features/auth/data/auth_repository.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';

class UserProfileMenu extends ConsumerWidget {
  const UserProfileMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final initials = user?.email?.isNotEmpty == true
        ? user!.email![0].toUpperCase()
        : 'A';

    return MenuAnchor(
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
             if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AdminTheme.primaryEmerald,
            child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        );
      },
      menuChildren: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Signed in as',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        MenuItemButton(
          leadingIcon: const Icon(Icons.settings_outlined, size: 20),
          onPressed: () => context.go('/settings'),
          child: const Text('My Settings'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout, size: 20, color: Colors.red),
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) {
              context.go('/login');
            }
          },
          child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
