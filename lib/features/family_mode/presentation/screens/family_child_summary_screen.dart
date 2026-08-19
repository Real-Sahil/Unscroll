import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import '../../../profile/presentation/widgets/stats_grid.dart';
import '../../models/family_models.dart';
import '../../providers/family_mode_provider.dart';

class FamilyChildSummaryScreen extends ConsumerWidget {
  final String childId;

  const FamilyChildSummaryScreen({
    super.key,
    required this.childId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider);

    return childrenAsync.when(
      loading: () => const Scaffold(
        appBar: AppBar(title: Text('Child Summary')),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Child Summary')),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
      data: (children) {
        final child = children.firstWhere(
          (c) => c.id == childId,
          orElse: () => throw Exception('Child not found'),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('${child.name} - Summary'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChildHeader(context, child),
                  const SizedBox(height: 32),
                  _buildProtectionStatus(context, child),
                  const SizedBox(height: 32),
                  _buildComplianceMetrics(context, child),
                  const SizedBox(height: 32),
                  _buildActivePolicies(context, child),
                  const SizedBox(height: 32),
                  _buildRecentActivity(context, child),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, ref, child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChildHeader(BuildContext context, FamilyChild child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            child.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            child.deviceModel ?? 'Device info not available',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: child.isProtected ? AppColors.success : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              child.isProtected ? 'Protection Active' : 'Protection Inactive',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtectionStatus(BuildContext context, FamilyChild child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Protection Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: child.isProtected ? AppColors.success.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: child.isProtected ? AppColors.success : Colors.orange,
            ),
          ),
          child: Row(
            children: [
              Icon(
                child.isProtected ? Icons.shield_verified : Icons.warning_outlined,
                color: child.isProtected ? AppColors.success : Colors.orange,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.isProtected ? 'Protection is active' : 'Protection is inactive',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      child.isProtected
                          ? 'All policies are being enforced'
                          : 'Child can access restricted content',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceMetrics(BuildContext context, FamilyChild child) {
    final adherenceRate = (child.blockedAttemptsCount > 0
        ? (child.blockedAttemptsCount / (child.blockedAttemptsCount + 5) * 100).toStringAsFixed(1)
        : '0') as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compliance Metrics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Blocked Attempts',
                child.blockedAttemptsCount.toString(),
                Icons.block_outlined,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Adherence Rate',
                '$adherenceRate%',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePolicies(BuildContext context, FamilyChild child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Policies',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to edit child screen
                Navigator.pushNamed(
                  context,
                  '/family-edit-child',
                  arguments: child.id,
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (child.policiesCount == 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No active policies. Add policies to enable protection.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              _buildPolicyItem(context, 'Instagram Reels', 'Blocked all day'),
              const SizedBox(height: 8),
              _buildPolicyItem(context, 'YouTube Shorts', '10 PM - 7 AM'),
              const SizedBox(height: 8),
              _buildPolicyItem(context, 'TikTok', 'School hours (8 AM - 3 PM)'),
            ],
          ),
      ],
    );
  }

  Widget _buildPolicyItem(BuildContext context, String app, String schedule) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  schedule,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, FamilyChild child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Blocked attempt on Instagram',
                '2 hours ago',
                Icons.block_outlined,
              ),
              Divider(height: 16),
              _buildActivityItem(
                'Policy updated by parent',
                '5 hours ago',
                Icons.edit_outlined,
              ),
              Divider(height: 16),
              _buildActivityItem(
                'Successfully avoided Reels',
                '1 day ago',
                Icons.check_circle_outline,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, FamilyChild child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Implement force enable/disable
          },
          icon: const Icon(Icons.power_settings_new),
          label: Text(child.isProtected ? 'Disable Protection' : 'Enable Protection'),
          style: ElevatedButton.styleFrom(
            backgroundColor: child.isProtected ? Colors.orange : AppColors.success,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // Send message/note to child
          },
          icon: const Icon(Icons.message_outlined),
          label: const Text('Send Message'),
        ),
      ],
    );
  }
}
