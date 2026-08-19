import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../models/panic_button_models.dart';
import '../../providers/panic_button_provider.dart';

class PanicButtonScreen extends ConsumerWidget {
  const PanicButtonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panicState = ref.watch(panicButtonProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    if (panicState.isOnCooldown) {
      return _buildCooldownScreen(context, ref, panicState, homeNotifier);
    }

    return _buildActivationScreen(context, ref, panicState, homeNotifier);
  }

  Widget _buildActivationScreen(
    BuildContext context,
    WidgetRef ref,
    PanicButtonState state,
    dynamic homeNotifier,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Protection'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 80,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Emergency Protection',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Activate emergency protection to hard-block all short-form content immediately. Once activated, you cannot disable it for the selected cooldown period.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildCooldownSelector(context, ref, state),
              const SizedBox(height: 48),
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildStatisticsGrid(context, ref),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: () => _confirmActivation(context, ref, state),
                  child: const Text(
                    '🛡️ Activate Protection Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCooldownScreen(
    BuildContext context,
    WidgetRef ref,
    PanicButtonState state,
    dynamic homeNotifier,
  ) {
    final event = state.latestEvent!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protection Active'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '✓ Protection Activated',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.success,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'All short-form content is now blocked.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildCooldownTimer(context, event),
              const SizedBox(height: 32),
              if (event.note != null) ...[
                Text(
                  'Your note:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 48),
              ],
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCooldownSelector(
    BuildContext context,
    WidgetRef ref,
    PanicButtonState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cooldown Duration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...PanicButtonCooldown.values.map((cooldown) {
          final isSelected = state.defaultCooldown == cooldown;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(panicButtonProvider.notifier)
                    .setDefaultCooldown(cooldown);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
                ),
                child: Row(
                  children: [
                    Radio(
                      value: cooldown,
                      groupValue: state.defaultCooldown,
                      onChanged: (_) {
                        ref
                            .read(panicButtonProvider.notifier)
                            .setDefaultCooldown(cooldown);
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cooldown.label,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            '${cooldown.durationMinutes} minutes of protection',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(panicStatisticsProvider);

    return Row(
      children: [
        _buildStatCard(
          context,
          'Today',
          stats.today.toString(),
          Icons.today_outlined,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          'This Week',
          stats.thisWeek.toString(),
          Icons.date_range_outlined,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          'Total',
          stats.total.toString(),
          Icons.trending_up_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCooldownTimer(BuildContext context, PanicButtonEvent event) {
    return Column(
      children: [
        Text(
          'Time Remaining',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                event.remainingTimeFormatted,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Until ${event.expiresAt.toString().split('.')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmActivation(
    BuildContext context,
    WidgetRef ref,
    PanicButtonState state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Protection Activation'),
        content: Text(
          'Are you sure you want to activate emergency protection for ${state.defaultCooldown.label}? '
          'You will not be able to disable it during this period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(panicButtonProvider.notifier).activatePanic(
                    cooldown: state.defaultCooldown,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Emergency protection activated'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
