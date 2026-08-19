import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/constants.dart';
import 'package:unscroll/config/theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/welcome_step.dart';
import '../widgets/risk_window_step.dart';
import '../widgets/goals_step.dart';
import '../widgets/preview_step.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return WillPopScope(
      onWillPop: () async => onboarding.currentStep == 0 ? true : false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              if (onboarding.currentStep > 0)
                LinearProgressIndicator(
                  value: (onboarding.currentStep + 1) / 4,
                  backgroundColor: AppColors.lightGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              // Content
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    WelcomeStep(onNext: notifier.nextStep),
                    RiskWindowStep(onNext: notifier.nextStep),
                    GoalsStep(onNext: notifier.nextStep),
                    PreviewStep(onNext: notifier.nextStep),
                  ],
                ),
              ),
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (onboarding.currentStep > 0)
                      OutlinedButton(
                        onPressed: notifier.previousStep,
                        child: const Text('Back'),
                      )
                    else
                      const SizedBox(width: 80),
                    if (onboarding.currentStep < 3)
                      ElevatedButton(
                        onPressed: _validateAndNext(onboarding, notifier, context),
                        child: const Text('Next'),
                      )
                    else
                      ElevatedButton(
                        onPressed: onboarding.isLoading
                            ? null
                            : () => _completeOnboarding(notifier, context),
                        child: onboarding.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Complete'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback _validateAndNext(
    OnboardingState state,
    OnboardingNotifier notifier,
    BuildContext context,
  ) {
    return () {
      switch (state.currentStep) {
        case 1:
          if (state.riskWindow == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select your risk window')),
            );
            return;
          }
          break;
        case 2:
          if (state.selectedGoals.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select at least one goal')),
            );
            return;
          }
          break;
      }
      notifier.nextStep();
    };
  }

  Future<void> _completeOnboarding(
    OnboardingNotifier notifier,
    BuildContext context,
  ) async {
    notifier.setLoading(true);
    try {
      // TODO: Save onboarding data to Supabase
      // For now, just navigate to home
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      notifier.setError(e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      notifier.setLoading(false);
    }
  }
}
