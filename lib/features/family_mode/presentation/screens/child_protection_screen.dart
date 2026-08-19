import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/family_mode/providers/family_provider.dart';
import '../widgets/parent_info_card.dart';
import '../widgets/child_policy_card.dart';

class ChildProtectionScreen extends ConsumerWidget {
  const ChildProtectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyRole = ref.watch(familyRoleProvider);
    final childPolicies = ref.watch(childPoliciesProvider);

    // Only show this if user is a child in a family
    if (familyRole != FamilyRole.child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Family Protection'),
        ),
        body: Center(
          child: Text(
            'You are not linked to a family',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Protection Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent info card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ParentInfoCard(),
            ),

            // Info message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your parent has set up protection rules for your device. You cannot modify these settings without their approval.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.blue[900],
                              height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Policies section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Active Policies',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (childPolicies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'No active policies',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: childPolicies.map((policy) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ChildPolicyCard(policy: policy),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Restrictions info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Restrictions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RestrictionItem(
                    icon: Icons.settings,
                    label: 'Change Settings',
                    restricted: true,
                  ),
                  _RestrictionItem(
                    icon: Icons.delete,
                    label: 'Delete Policies',
                    restricted: true,
                  ),
                  _RestrictionItem(
                    icon: Icons.bar_chart,
                    label: 'View Statistics',
                    restricted: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RestrictionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool restricted;

  const _RestrictionItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.restricted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: restricted ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: restricted ? Colors.red[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: restricted ? Colors.red[700] : Colors.green[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: restricted
                  ? Colors.red[100]
                  : Colors.green[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              restricted ? 'Restricted' : 'Allowed',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: restricted ? Colors.red[700] : Colors.green[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
