import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyStats {
  final int disableAttempts;
  final int panicButtonPresses;
  final int focusOffMinutes;
  final bool focusModeActive;

  DailyStats({
    this.disableAttempts = 0,
    this.panicButtonPresses = 0,
    this.focusOffMinutes = 0,
    this.focusModeActive = true,
  });

  DailyStats copyWith({
    int? disableAttempts,
    int? panicButtonPresses,
    int? focusOffMinutes,
    bool? focusModeActive,
  }) {
    return DailyStats(
      disableAttempts: disableAttempts ?? this.disableAttempts,
      panicButtonPresses: panicButtonPresses ?? this.panicButtonPresses,
      focusOffMinutes: focusOffMinutes ?? this.focusOffMinutes,
      focusModeActive: focusModeActive ?? this.focusModeActive,
    );
  }
}

class HomeNotifier extends StateNotifier<DailyStats> {
  HomeNotifier() : super(DailyStats());

  void updateStats({
    int? disableAttempts,
    int? panicButtonPresses,
    int? focusOffMinutes,
    bool? focusModeActive,
  }) {
    state = state.copyWith(
      disableAttempts: disableAttempts,
      panicButtonPresses: panicButtonPresses,
      focusOffMinutes: focusOffMinutes,
      focusModeActive: focusModeActive,
    );
  }

  void incrementDisableAttempts() {
    state = state.copyWith(disableAttempts: state.disableAttempts + 1);
  }

  void incrementPanicButton() {
    state = state.copyWith(panicButtonPresses: state.panicButtonPresses + 1);
  }

  void addFocusOffTime(int minutes) {
    state = state.copyWith(focusOffMinutes: state.focusOffMinutes + minutes);
  }

  void toggleFocusMode(bool active) {
    state = state.copyWith(focusModeActive: active);
  }

  void resetDailyStats() {
    state = DailyStats();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, DailyStats>(
  (ref) => HomeNotifier(),
);
