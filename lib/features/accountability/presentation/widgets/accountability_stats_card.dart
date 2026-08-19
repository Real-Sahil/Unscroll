import 'package:flutter/material.dart';

class AccountabilityStatsCard extends StatelessWidget {
  final int partnerCount;
  final int verifiedCount;
  final int summariesCount;

  const AccountabilityStatsCard({
    Key? key,
    required this.partnerCount,
    required this.verifiedCount,
    required this.summariesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accountability Network',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF0066CC),
                        fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.people,
                        label: 'Partners',
                        value: '$partnerCount',
                        color: const Color(0xFF0066CC),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.check_circle,
                        label: 'Verified',
                        value: '$verifiedCount',
                        color: const Color(0xFF00AA66),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.handshake,
              color: Color(0xFF0066CC),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
          ),
        ),
      ],
    );
  }
}
