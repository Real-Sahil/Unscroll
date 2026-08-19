import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakCard({
    Key? key,
    required this.currentStreak,
    required this.longestStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0066CC).withOpacity(0.1),
                  const Color(0xFF00A3FF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0066CC).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFF0066CC),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Streak',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF0066CC),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentStreak',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0066CC),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'days protected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF8C00).withOpacity(0.1),
                  const Color(0xFFFF6B35).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF8C00).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFF8C00),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Best Streak',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFFF8C00),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$longestStreak',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF8C00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
