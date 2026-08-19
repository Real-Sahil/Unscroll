// App Configuration Constants
class AppConstants {
  // App Info
  static const String appName = 'UnScroll';
  static const String appVersion = '0.1.0';
  static const String bundleId = 'com.unscroll.app';

  // Timing
  static const int frictionDurationSeconds = 10;
  static const int maxFrictionDurationSeconds = 30;
  static const int cooldownHoursDefault = 24;
  static const int panicCooldownHoursDefault = 12;
  static const int sessionTimeoutMinutes = 15;

  // Security
  static const int pinLength = 4;
  static const int pinMaxAttempts = 5;
  static const int pinLockoutDurationMinutes = 10;
  static const int pbkdf2Iterations = 100000;
  static const int saltLengthBytes = 32;

  // Friction Engine
  static const String typedConfirmationPhrase = 'I accept I may lose 30+ minutes';
  static const int typedConfirmationMinLength = 5;

  // Goals
  static const List<String> availableGoals = [
    'Sleep',
    'Work/Studying',
    'Relationships',
    'Mood',
    'General Wellness',
  ];

  // Friction Levels
  static const String frictionLevelLow = 'low';
  static const String frictionLevelMedium = 'medium';
  static const String frictionLevelHard = 'hard';

  // Panic Cooldown Options (hours)
  static const List<int> panicCooldownOptions = [2, 12, 24];

  // Default high-risk windows
  static const List<String> defaultHighRiskDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const String defaultHighRiskStartTime = '22:00';
  static const String defaultHighRiskEndTime = '08:00';

  // Storage Keys
  static const String storageKeyPinHash = 'pin_hash';
  static const String storageKeySalt = 'pin_salt';
  static const String storageKeyBiometricEnabled = 'biometric_enabled';
  static const String storageKeyLastProtectionDisableTime = 'last_protection_disable_time';
  static const String storageKeyPanicCooldownExpires = 'panic_cooldown_expires';
  static const String storageKeyCachedPolicy = 'cached_policy';
  static const String storageKeyAppState = 'app_state';

  // Email subjects
  static const String weeklyAccountabilitySummarySubject = 'Your FocusFeed Weekly Summary';

  // Messaging
  static const String welcomeHeadline = 'For people who know they\'ll doomscroll tonight.';
  static const String welcomeSubheading = 'This app assumes you\'re at risk and makes short-form hard to start, easy to stop.';

  static const String focusModeEnabledMessage = 'Focus Mode: ON (hard block)';
  static const String focusModeDisabledMessage = 'Focus Mode: OFF';

  static const String urgeCoachMessage = 'You\'ve been here before. Most times, this urge passes in a few minutes.';
  static const String panicButtonMessage = 'Session ended. Short-form is locked for the next hours.';

  // APIs
  static const Duration defaultApiTimeout = Duration(seconds: 30);
}

class AppPlatforms {
  static const String ios = 'ios';
  static const String android = 'android';
  static const String chrome = 'chrome';
  static const String firefox = 'firefox';
  static const String safari = 'safari';
}

class AppRoles {
  static const String adult = 'adult';
  static const String parent = 'parent';
  static const String child = 'child';
  static const String therapist = 'therapist';
}

class AppResources {
  // Image assets
  static const String assetLogo = 'assets/images/logo.png';
  static const String assetWelcome = 'assets/images/welcome.png';

  // Animations
  static const String animationBreathing = 'assets/animations/breathing.riv';
  static const String animationSuccess = 'assets/animations/success.riv';

  // Icons
  static const String iconPanic = 'assets/icons/panic.svg';
  static const String iconFocus = 'assets/icons/focus.svg';
  static const String iconSettings = 'assets/icons/settings.svg';
}
