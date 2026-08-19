import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import 'package:unscroll/config/constants.dart';
import '../providers/onboarding_provider.dart';

class RiskWindowStep extends ConsumerWidget {
  final VoidCallback onNext;

  const RiskWindowStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final riskWindow = onboarding.riskWindow;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When are you most vulnerable?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Set your risk window—the time you\'re most likely to doom scroll.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 40),
            // Time picker section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _TimePickerField(
                    label: 'Start Time',
                    value: riskWindow?.startTime ?? '22:00',
                    onTap: () => _showTimePicker(context, true, riskWindow, notifier),
                  ),
                  const SizedBox(height: 20),
                  _TimePickerField(
                    label: 'End Time',
                    value: riskWindow?.endTime ?? '06:00',
                    onTap: () => _showTimePicker(context, false, riskWindow, notifier),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Day selector
            Text(
              'Which days apply?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _DaySelector(
              selectedDays: riskWindow?.selectedDays ?? [],
              onDayToggled: (day) {
                if (riskWindow != null) {
                  final days = List<String>.from(riskWindow.selectedDays);
                  if (days.contains(day)) {
                    days.remove(day);
                  } else {
                    days.add(day);
                  }
                  notifier.setRiskWindow(
                    riskWindow.copyWith(selectedDays: days),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    bool isStartTime,
    RiskWindow? riskWindow,
    OnboardingNotifier notifier,
  ) async {
    final currentTime = TimeOfDay.fromDateTime(
      DateTime.parse('2024-01-01 ${isStartTime ? riskWindow?.startTime ?? "22:00" : riskWindow?.endTime ?? "06:00"}'),
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (pickedTime != null && riskWindow != null) {
      final formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      if (isStartTime) {
        notifier.setRiskWindow(riskWindow.copyWith(startTime: formattedTime));
      } else {
        notifier.setRiskWindow(riskWindow.copyWith(endTime: formattedTime));
      }
    }
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.lightGray,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Icon(Icons.access_time, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final List<String> selectedDays;
  final Function(String) onDayToggled;

  const _DaySelector({
    required this.selectedDays,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isSelected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () => onDayToggled(day),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.lightGray,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                shortDays[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
