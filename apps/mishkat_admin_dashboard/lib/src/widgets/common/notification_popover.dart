import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/data/dashboard_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPopover extends ConsumerWidget {
  const NotificationPopover({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(adminActionsProvider);

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Badge(
            isLabelVisible: actionsAsync.hasValue && actionsAsync.value!.isNotEmpty,
            label: Text('${actionsAsync.value?.length ?? 0}'),
            child: const Icon(Icons.notifications_none),
          ),
          tooltip: 'Notifications',
        );
      },
      menuChildren: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const Divider(height: 1),
        ...actionsAsync.when(
          data: (actions) {
            if (actions.isEmpty) {
              return [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No recent notifications'),
                ),
              ];
            }
            return actions.take(5).map((action) => MenuItemButton(
              onPressed: () => context.go('/technical'), // Go to audit logs
              leadingIcon: Icon(_getIconForAction(action.category), size: 18),
              child: SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.description,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeago.format(action.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ));
          },
          loading: () => [const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))],
          error: (_, __) => [const Padding(padding: EdgeInsets.all(8), child: Text('Error loading notifications'))],
        ),
        const Divider(height: 1),
        MenuItemButton(
          onPressed: () => context.go('/technical'),
          child: const Center(
            child: Text(
              'View All Audit Logs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForAction(String type) {
    if (type.contains('payment')) return Icons.payment;
    if (type.contains('user')) return Icons.person_add;
    if (type.contains('course')) return Icons.library_books;
    return Icons.info_outline;
  }
}
