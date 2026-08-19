import 'package:flutter/material.dart';
import 'package:unscroll/core/models/user_profile_extended.dart';

class PremiumCard extends StatelessWidget {
  final UserProfileExtended profile;

  const PremiumCard({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysRemaining = profile.daysUntilPremiumExpires;
    final isPremiumActive = profile.isPremiumActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremiumActive
              ? [
                  const Color(0xFFFF8C00).withOpacity(0.1),
                  const Color(0xFFFF6B35).withOpacity(0.1),
                ]
              : [
                  Colors.grey[300]!.withOpacity(0.3),
                  Colors.grey[400]!.withOpacity(0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPremiumActive
              ? const Color(0xFFFF8C00).withOpacity(0.5)
              : Colors.grey[400]!.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPremiumActive
                  ? const Color(0xFFFF8C00).withOpacity(0.2)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.diamond,
              color: isPremiumActive
                  ? const Color(0xFFFF8C00)
                  : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isPremiumActive
                            ? const Color(0xFFFF8C00)
                            : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPremiumActive
                      ? 'Expires in $daysRemaining days'
                      : 'Expired',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isPremiumActive)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Active',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFF8C00),
                      fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to premium upgrade
              },
              icon: const Icon(Icons.upgrade, size: 16),
              label: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }
}
