import 'package:flutter/material.dart';
import 'package:unscroll/config/theme.dart';
import '../../providers/relapse_provider.dart';

class DailyChart extends StatelessWidget {
  final WeeklySummary weeklySummary;

  const DailyChart({super.key, required this.weeklySummary});

  @override
  Widget build(BuildContext context) {
    final maxValue = weeklySummary.dailySummaries
        .map((s) => s.totalDisableAttempts)
        .fold<int>(0, (max, val) => val > max ? val : max)
        .toDouble();

    final displayMax = maxValue == 0 ? 1 : maxValue;

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
            'Weekly Disables',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              weeklySummary.dailySummaries.length,
              (index) {
                final summary = weeklySummary.dailySummaries[index];
                final height = (summary.totalDisableAttempts / displayMax) * 100;
                final dayLabel =
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];

                return Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 30,
                          height: height.clamp(5, 100),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.totalDisableAttempts.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
