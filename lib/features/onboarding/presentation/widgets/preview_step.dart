import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import 'package:unscroll/config/constants.dart';
import '../providers/onboarding_provider.dart';

class PreviewStep extends ConsumerWidget {
  final VoidCallback onNext;

  const PreviewStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Protection Setup',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Here\'s what we\'ll protect for you:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            // Risk Window Section
            _PreviewSection(
              title: 'Your Risk Window',
              icon: Icons.schedule,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onboarding.riskWindow != null) ...[
                    Text(
                      '${onboarding.riskWindow!.startTime} - ${onboarding.riskWindow!.endTime}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: onboarding.riskWindow!.selectedDays.map((day) {
                        return Chip(
                          label: Text(day.substring(0, 3)),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        );
                      }).toList(),
                    ),
                  ] else
                    Text(
                      'No risk window selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Goals Section
            _PreviewSection(
              title: 'Your Goals',
              icon: Icons.target,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: onboarding.selectedGoals.isNotEmpty
                    ? onboarding.selectedGoals.map((goal) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 20, color: AppColors.success),
                              const SizedBox(width: 8),
                              Text(
                                goal,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    : [
                        Text(
                          'No goals selected',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
              ),
            ),
            const SizedBox(height: 16),
            // Apps Protected Section
            _PreviewSection(
              title: 'Apps We\'ll Protect',
              icon: Icons.shield_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AppProtectionItem(
                    appName: 'Instagram',
                    features: ['Hide Reels', 'Block Stories', 'Disable Autoplay'],
                  ),
                  const SizedBox(height: 12),
                  _AppProtectionItem(
                    appName: 'YouTube',
                    features: ['Block Shorts', 'Disable Autoplay'],
                  ),
                  const SizedBox(height: 12),
                  _AppProtectionItem(
                    appName: 'TikTok',
                    features: ['Block Feed', 'Disable Autoplay'],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Friction Engine Section
            _PreviewSection(
              title: 'Smart Protection',
              icon: Icons.psychology,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureItem(
                    title: 'Friction Layers',
                    description: 'PIN + biometric + typed confirmation to disable protection',
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    title: 'Panic Button',
                    description: 'Instant lock if urges become overwhelming',
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    title: 'Cooldown Protection',
                    description: '24-hour wait before you can disable again',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'re ready to take control. Complete setup to start protecting your time.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PreviewSection({
    required this.title,
    required this.icon,
    required this.child,
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
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AppProtectionItem extends StatelessWidget {
  final String appName;
  final List<String> features;

  const _AppProtectionItem({
    required this.appName,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        ...features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                const Text('•', style: TextStyle(color: AppColors.primary)),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
