import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/panic_button_models.dart';

final panicButtonProvider =
    StateNotifierProvider<PanicButtonNotifier, PanicButtonState>(
  (ref) => PanicButtonNotifier(),
);

final isPanicActivatedProvider = Provider<bool>((ref) {
  final state = ref.watch(panicButtonProvider);
  return state.isOnCooldown;
});

final panicCooldownRemainingProvider = Provider<Duration>((ref) {
  final state = ref.watch(panicButtonProvider);
  return state.cooldownRemaining;
});

final panicEventHistoryProvider = Provider<List<PanicButtonEvent>>((ref) {
  final state = ref.watch(panicButtonProvider);
  return state.events;
});

final panicStatisticsProvider = Provider<({
  int total,
  int thisWeek,
  int today,
  String? lastActivated,
})>((ref) {
  final state = ref.watch(panicButtonProvider);

  return (
    total: state.totalPressedCount,
    thisWeek: state.thisWeekCount,
    today: state.todayCount,
    lastActivated: state.latestEvent?.timestamp.toString(),
  );
});

final defaultCooldownProvider = Provider<PanicButtonCooldown>((ref) {
  final state = ref.watch(panicButtonProvider);
  return state.defaultCooldown;
});
