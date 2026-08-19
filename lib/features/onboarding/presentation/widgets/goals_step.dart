import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import 'package:unscroll/config/constants.dart';
import '../providers/onboarding_provider.dart';

class GoalsStep extends ConsumerWidget {
  final VoidCallback onNext;

  const GoalsStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are your goals?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select at least one goal to help us protect your time.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            ...List.generate(
              AppConstants.availableGoals.length,
              (index) {
                final goal = AppConstants.availableGoals[index];
                final isSelected = onboarding.selectedGoals.contains(goal);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GoalCard(
                    goal: goal,
                    isSelected: isSelected,
                    icon: _getGoalIcon(goal),
                    description: _getGoalDescription(goal),
                    onTap: () => notifier.toggleGoal(goal),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Sleep':
        return Icons.bedtime;
      case 'Work/Studying':
        return Icons.work_outline;
      case 'Relationships':
        return Icons.people_outline;
      case 'Mood':
        return Icons.mood;
      case 'General Wellness':
        return Icons.favorite_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'Sleep':
        return 'Protect your sleep schedule and rest time';
      case 'Work/Studying':
        return 'Stay focused on your work and studies';
      case 'Relationships':
        return 'Be more present with people around you';
      case 'Mood':
        return 'Improve your mental health and well-being';
      case 'General Wellness':
        return 'Support your overall health journey';
      default:
        return '';
    }
  }
}

class _GoalCard extends StatelessWidget {
  final String goal;
  final bool isSelected;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
