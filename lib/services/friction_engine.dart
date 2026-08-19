import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:unscroll/config/constants.dart';

enum AuthMethod { pin, biometric, none }

class FrictionState {
  final int attemptsRemaining;
  final bool isLocked;
  final DateTime? lockUntil;
  final int frictionLevel; // 1-3: low, medium, hard

  FrictionState({
    this.attemptsRemaining = AppConstants.maxPinAttempts,
    this.isLocked = false,
    this.lockUntil,
    this.frictionLevel = 2,
  });

  bool get isAccountLocked => isLocked && lockUntil != null && DateTime.now().isBefore(lockUntil!);

  FrictionState copyWith({
    int? attemptsRemaining,
    bool? isLocked,
    DateTime? lockUntil,
    int? frictionLevel,
  }) {
    return FrictionState(
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      isLocked: isLocked ?? this.isLocked,
      lockUntil: lockUntil ?? this.lockUntil,
      frictionLevel: frictionLevel ?? this.frictionLevel,
    );
  }
}

class FrictionEngineService {
  late FrictionState _state;
  String? _hashedPin;
  final _frictionController = StreamController<FrictionState>.broadcast();

  Stream<FrictionState> get stateStream => _frictionController.stream;
  FrictionState get currentState => _state;

  FrictionEngineService({int frictionLevel = 2}) {
    _state = FrictionState(frictionLevel: frictionLevel);
  }

  /// Initialize PIN during onboarding
  Future<bool> initializePin(String pin) async {
    if (!_isValidPin(pin)) {
      return false;
    }
    _hashedPin = _hashPin(pin);
    return true;
  }

  /// Verify PIN with attempt tracking
  Future<bool> verifyPin(String pin) async {
    if (_state.isAccountLocked) {
      return false;
    }

    final hashedInput = _hashPin(pin);
    if (hashedInput == _hashedPin) {
      // Correct PIN
      _updateState(_state.copyWith(attemptsRemaining: AppConstants.maxPinAttempts));
      return true;
    }

    // Wrong PIN
    int remaining = _state.attemptsRemaining - 1;
    if (remaining <= 0) {
      // Lock account
      _updateState(_state.copyWith(
        attemptsRemaining: 0,
        isLocked: true,
        lockUntil: DateTime.now().add(
          Duration(minutes: AppConstants.pinLockoutMinutes),
        ),
      ));
    } else {
      _updateState(_state.copyWith(attemptsRemaining: remaining));
    }

    return false;
  }

  /// Check if account is locked
  bool isAccountLocked() {
    if (_state.isLocked && _state.lockUntil != null) {
      if (DateTime.now().isAfter(_state.lockUntil!)) {
        // Lock period expired
        _updateState(_state.copyWith(
          isLocked: false,
          lockUntil: null,
          attemptsRemaining: AppConstants.maxPinAttempts,
        ));
        return false;
      }
      return true;
    }
    return false;
  }

  /// Get remaining lockout time in minutes
  int getLockoutRemainingMinutes() {
    if (!_state.isAccountLocked) {
      return 0;
    }
    final remaining = _state.lockUntil!.difference(DateTime.now());
    return remaining.inMinutes + (remaining.inSeconds % 60 > 0 ? 1 : 0);
  }

  /// Get friction challenges based on level
  List<FrictionChallenge> getFrictionChallenges() {
    final challenges = <FrictionChallenge>[];

    // Level 1: Simple PIN
    if (_state.frictionLevel >= 1) {
      challenges.add(FrictionChallenge.pin);
    }

    // Level 2: PIN + Urge Surf
    if (_state.frictionLevel >= 2) {
      challenges.add(FrictionChallenge.urgeSurf);
      challenges.add(FrictionChallenge.typedConfirmation);
    }

    // Level 3: All of the above + Breathing Exercise
    if (_state.frictionLevel >= 3) {
      challenges.add(FrictionChallenge.breathingExercise);
    }

    return challenges;
  }

  /// Get urge-surf duration in seconds based on friction level
  int getUrgeSurfDuration() {
    switch (_state.frictionLevel) {
      case 1:
        return 10;
      case 2:
        return 20;
      case 3:
        return 30;
      default:
        return 15;
    }
  }

  /// Verify typed confirmation phrase
  bool verifyTypedConfirmation(String input) {
    return input.toLowerCase().trim() ==
        AppConstants.typedConfirmationPhrase.toLowerCase().trim();
  }

  /// Update friction level
  void setFrictionLevel(int level) {
    if (level >= 1 && level <= 3) {
      _updateState(_state.copyWith(frictionLevel: level));
    }
  }

  /// Reset attempts (for admin/recovery)
  void resetAttempts() {
    _updateState(_state.copyWith(
      attemptsRemaining: AppConstants.maxPinAttempts,
      isLocked: false,
      lockUntil: null,
    ));
  }

  /// Hash PIN using PBKDF2-like approach
  String _hashPin(String pin) {
    final salt = 'unscroll_salt_2024';
    return sha256.convert('$pin$salt'.codeUnits).toString();
  }

  /// Validate PIN format
  bool _isValidPin(String pin) {
    return pin.length == 4 && int.tryParse(pin) != null;
  }

  /// Internal state update with stream emission
  void _updateState(FrictionState newState) {
    _state = newState;
    _frictionController.add(_state);
  }

  void dispose() {
    _frictionController.close();
  }
}

enum FrictionChallenge {
  pin,
  urgeSurf,
  breathingExercise,
  typedConfirmation,
}

extension FrictionChallengeExt on FrictionChallenge {
  String get displayName {
    switch (this) {
      case FrictionChallenge.pin:
        return 'Enter PIN';
      case FrictionChallenge.urgeSurf:
        return 'Urge Surfing';
      case FrictionChallenge.breathingExercise:
        return 'Breathing Exercise';
      case FrictionChallenge.typedConfirmation:
        return 'Confirmation';
    }
  }

  String get description {
    switch (this) {
      case FrictionChallenge.pin:
        return 'Enter your 4-digit PIN';
      case FrictionChallenge.urgeSurf:
        return 'Wait and breathe through the urge';
      case FrictionChallenge.breathingExercise:
        return 'Follow the breathing guide';
      case FrictionChallenge.typedConfirmation:
        return 'Type the confirmation phrase';
    }
  }
}
