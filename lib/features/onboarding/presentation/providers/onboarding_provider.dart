import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiskWindow {
  final String startTime;
  final String endTime;
  final List<String> selectedDays;

  RiskWindow({
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
  });

  RiskWindow copyWith({
    String? startTime,
    String? endTime,
    List<String>? selectedDays,
  }) {
    return RiskWindow(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}

class OnboardingState {
  final int currentStep;
  final RiskWindow? riskWindow;
  final List<String> selectedGoals;
  final bool isLoading;
  final String? errorMessage;

  OnboardingState({
    this.currentStep = 0,
    this.riskWindow,
    this.selectedGoals = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    int? currentStep,
    RiskWindow? riskWindow,
    List<String>? selectedGoals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      riskWindow: riskWindow ?? this.riskWindow,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setRiskWindow(RiskWindow window) {
    state = state.copyWith(riskWindow: window);
  }

  void toggleGoal(String goal) {
    final goals = List<String>.from(state.selectedGoals);
    if (goals.contains(goal)) {
      goals.remove(goal);
    } else {
      goals.add(goal);
    }
    state = state.copyWith(selectedGoals: goals);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void reset() {
    state = OnboardingState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
