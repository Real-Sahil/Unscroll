import 'package:flutter/material.dart';
import 'package:unscroll/core/models/user_profile_extended.dart';

class RecoveryStatusCard extends StatelessWidget {
  final UserProfileExtended profile;

  const RecoveryStatusCard({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = profile.getRecoveryStatus();
    final hasStarted = profile.recoveryStartDate != null;
    final daysInRecovery = profile.recoverySince.inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00AA66).withOpacity(0.1),
            const Color(0xFF00D686).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00AA66).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety,
                color: Color(0xFF00AA66),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recovery Status',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00AA66),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasStarted) ...[
            Text(
              status,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Started ${profile.recoveryStartDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
              ),
            ),
          ] else
            Text(
              'Start your recovery journey',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
              ),
            ),
        ],
      ),
    );
  }
}
