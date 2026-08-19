import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/services/friction_engine.dart';

final frictionEngineProvider = StateNotifierProvider<FrictionNotifier, FrictionState>(
  (ref) => FrictionNotifier(),
);

class FrictionNotifier extends StateNotifier<FrictionState> {
  late final FrictionEngineService _service;

  FrictionNotifier() : super(FrictionState()) {
    _service = FrictionEngineService();
  }

  /// Initialize PIN during setup
  Future<bool> initializePin(String pin) async {
    return await _service.initializePin(pin);
  }

  /// Verify PIN and update state
  Future<bool> verifyPin(String pin) async {
    final result = await _service.verifyPin(pin);
    state = _service.currentState;
    return result;
  }

  /// Check if account is locked
  bool isLocked() {
    return _service.isAccountLocked();
  }

  /// Get remaining lockout minutes
  int getLockoutRemainingMinutes() {
    return _service.getLockoutRemainingMinutes();
  }

  /// Get friction challenges for current level
  List<FrictionChallenge> getChallenges() {
    return _service.getFrictionChallenges();
  }

  /// Get urge-surf duration
  int getUrgeSurfDuration() {
    return _service.getUrgeSurfDuration();
  }

  /// Verify typed confirmation phrase
  bool verifyConfirmation(String input) {
    return _service.verifyTypedConfirmation(input);
  }

  /// Set friction level (1-3)
  void setFrictionLevel(int level) {
    _service.setFrictionLevel(level);
    state = _service.currentState;
  }

  /// Reset attempts (admin only)
  void resetAttempts() {
    _service.resetAttempts();
    state = _service.currentState;
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
