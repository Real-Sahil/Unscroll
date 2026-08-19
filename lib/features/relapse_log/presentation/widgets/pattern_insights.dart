import 'package:flutter/material.dart';
import 'package:unscroll/config/theme.dart';
import '../../providers/relapse_provider.dart';

class PatternInsights extends StatelessWidget {
  final RelapseSummary todaySummary;

  const PatternInsights({super.key, required this.todaySummary});

  @override
  Widget build(BuildContext context) {
    final highRiskHour = todaySummary.getHighestRiskHour();
    final highRiskApp = todaySummary.getHighestRiskApp();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Patterns',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (highRiskHour != null) ...[
            _InsightItem(
              icon: Icons.schedule,
              title: 'High Risk Time',
              description: 'Most disables around $highRiskHour:00',
              color: AppColors.accent,
            ),
            const SizedBox(height: 12),
          ],
          if (highRiskApp != null) ...[
            _InsightItem(
              icon: Icons.apps,
              title: 'Most Tempting',
              description: 'You struggle most with $highRiskApp',
              color: AppColors.secondary,
            ),
          ] else
            _InsightItem(
              icon: Icons.lightbulb,
              title: 'Keep Building',
              description: 'More data needed for better insights',
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
