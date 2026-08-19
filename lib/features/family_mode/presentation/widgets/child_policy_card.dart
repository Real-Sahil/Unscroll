import 'package:flutter/material.dart';
import 'package:unscroll/features/family_mode/models/family_models.dart';

class ChildPolicyCard extends StatelessWidget {
  final ChildPolicy policy;

  const ChildPolicyCard({
    Key? key,
    required this.policy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AA66).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.policy_outlined,
                  color: Color(0xFF00AA66),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set by parent',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AA66).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF00AA66),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Restrictions info
          _PolicyRestrictionTile(
            icon: Icons.info_outline,
            label: 'Can't disable protection',
            enabled: !policy.canDisableProtection,
          ),
          _PolicyRestrictionTile(
            icon: Icons.visibility_off,
            label: 'Can\'t change settings',
            enabled: !policy.canChangeSettings,
          ),
          _PolicyRestrictionTile(
            icon: Icons.bar_chart,
            label: 'Can view statistics',
            enabled: policy.canViewStats,
          ),
        ],
      ),
    );
  }
}

class _PolicyRestrictionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;

  const _PolicyRestrictionTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: enabled ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enabled ? Colors.grey[700] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
