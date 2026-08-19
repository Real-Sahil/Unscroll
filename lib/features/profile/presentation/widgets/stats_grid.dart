import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsGrid({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statsList = [
      {
        'icon': Icons.calendar_today,
        'label': 'Total Days',
        'value': '${stats['totalDays']}',
        'color': const Color(0xFF00AA66),
      },
      {
        'icon': Icons.access_time,
        'label': 'Focus Hours',
        'value': '${stats['focusHours']}h',
        'color': const Color(0xFF0066CC),
      },
      {
        'icon': Icons.psychology,
        'label': 'Recovery Status',
        'value': '${stats['recoveryStatus']}',
        'color': const Color(0xFFFF8C00),
      },
    ];

    return GridView.count(
      crossAxisCount: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: statsList.map((stat) {
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: (stat['color'] as Color).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (stat['color'] as Color).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['label'] as String,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stat['value'] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: stat['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
