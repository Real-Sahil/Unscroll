import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import '../../providers/relapse_provider.dart';
import '../widgets/daily_chart.dart';
import '../widgets/pattern_insights.dart';
import '../widgets/event_timeline.dart';

class RelapseLogScreen extends ConsumerWidget {
  const RelapseLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklySummary = ref.watch(weeklySummaryProvider);
    final todaySummary = ref.watch(todaySummaryProvider);
    final allEvents = ref.watch(relapseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relapse Log & Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encouragement Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.successLight,
                      AppColors.secondaryLight.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: AppColors.success, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Status',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todaySummary.getEncouragementMessage(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Stats Summary
              _StatsGrid(weeklySummary: weeklySummary),
              const SizedBox(height: 24),

              // Weekly Chart
              DailyChart(weeklySummary: weeklySummary),
              const SizedBox(height: 24),

              // Pattern Insights
              PatternInsights(todaySummary: todaySummary),
              const SizedBox(height: 24),

              // Trend Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        weeklySummary.getTrendMessage(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Event Timeline
              Text(
                'Recent Events',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              EventTimeline(events: allEvents.take(10).toList()),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final WeeklySummary weeklySummary;

  const _StatsGrid({required this.weeklySummary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _StatCard(
          label: 'Total Disables',
          value: weeklySummary.getTotalDisables().toString(),
          icon: Icons.lock_open,
          color: AppColors.primary,
        ),
        _StatCard(
          label: 'Avg Focus Off',
          value: '${weeklySummary.getAverageFocusOffMinutes()}m',
          icon: Icons.schedule,
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
