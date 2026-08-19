import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import '../../../policies/providers/policies_provider.dart';

class PoliciesListScreen extends ConsumerWidget {
  const PoliciesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policies = ref.watch(policiesProvider);
    final notifier = ref.read(policiesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protection Policies'),
        elevation: 0,
      ),
      body: policies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No policies yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first protection policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to create policy screen
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Policy'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: policies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final policy = policies[index];
                return _PolicyCard(
                  policy: policy,
                  onToggle: () => notifier.togglePolicyActive(policy.id),
                  onEdit: () {
                    // TODO: Navigate to edit policy screen
                  },
                  onDuplicate: () => notifier.duplicatePolicy(policy.id),
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Policy?'),
                        content: const Text(
                          'This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              notifier.deletePolicy(policy.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create policy screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final dynamic policy;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _PolicyCard({
    required this.policy,
    required this.onToggle,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              policy.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: policy.isActive
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.borderColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              policy.isActive ? 'Active' : 'Inactive',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: policy.isActive
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        policy.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: policy.isActive,
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
          ),

          // Policy details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _PolicyDetail(
                    icon: Icons.schedule,
                    label: 'Time',
                    value:
                        '${policy.schedule.startTime} - ${policy.schedule.endTime}',
                  ),
                ),
                Expanded(
                  child: _PolicyDetail(
                    icon: Icons.apps,
                    label: 'Apps',
                    value: '${policy.rules.length} blocked',
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDuplicate,
                    icon: const Icon(Icons.content_copy_outlined, size: 16),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PolicyDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
