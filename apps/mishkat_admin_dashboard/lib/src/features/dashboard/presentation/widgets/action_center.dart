import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:mishkat_admin_dashboard/src/features/dashboard/data/dashboard_repository.dart';

class ActionCenter extends ConsumerWidget {
  const ActionCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(adminActionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Action Center', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            actionsAsync.when(
              data: (actions) {
                if (actions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No pending actions. You are all caught up!'),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: actions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _buildCategoryIcon(action.category),
                      title: Text(action.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(action.description),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {},
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category) {
      case 'publish_pending':
        icon = Icons.publish;
        color = Colors.orange;
        break;
      case 'failed_webhook':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case 'flagged':
        icon = Icons.flag_outlined;
        color = AdminTheme.radiantGold;
        break;
      default:
        icon = Icons.notifications_none;
        color = AdminTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
