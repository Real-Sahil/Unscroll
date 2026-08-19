import 'package:flutter/material.dart';
import 'package:unscroll/config/theme.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onPoliciesTap;
  final VoidCallback onRelapseLogTap;
  final VoidCallback onAccountabilityTap;

  const QuickActions({
    super.key,
    required this.onPoliciesTap,
    required this.onRelapseLogTap,
    required this.onAccountabilityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _QuickActionTile(
          title: 'Protection Policies',
          subtitle: 'Manage your blocking rules',
          icon: Icons.shield_outlined,
          onTap: onPoliciesTap,
        ),
        const SizedBox(height: 12),
        _QuickActionTile(
          title: 'Relapse Log',
          subtitle: 'View your patterns and progress',
          icon: Icons.analytics_outlined,
          onTap: onRelapseLogTap,
        ),
        const SizedBox(height: 12),
        _QuickActionTile(
          title: 'Accountability',
          subtitle: 'Connect with your support partner',
          icon: Icons.people_outline,
          onTap: onAccountabilityTap,
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
