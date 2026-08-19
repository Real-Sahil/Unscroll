import 'package:unscroll/core/models/policy.dart';
import 'package:unscroll/config/constants.dart';

class PolicyEvaluator {
  /// Evaluate if protection should be active based on current time and policy
  static bool isProtectionActive(PolicySchedule schedule) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentDayName = _getDayName(now.weekday);

    // Check if current day is in selected days
    if (!schedule.activeDays.contains(currentDayName)) {
      return false;
    }

    // Parse start and end times
    final startTime = _parseTimeString(schedule.startTime);
    final endTime = _parseTimeString(schedule.endTime);

    // Handle overnight protection (e.g., 22:00 to 06:00)
    if (startTime.hour <= endTime.hour && startTime.hour > endTime.hour) {
      // Not an overnight protection, simple comparison
      return currentTime.hour >= startTime.hour &&
          currentTime.hour < endTime.hour;
    } else if (startTime.hour > endTime.hour) {
      // Overnight protection
      return currentTime.hour >= startTime.hour ||
          currentTime.hour < endTime.hour;
    }

    // Handle same-hour cases
    if (startTime.hour == endTime.hour) {
      return currentTime.hour == startTime.hour &&
          currentTime.minute >= startTime.minute &&
          currentTime.minute < endTime.minute;
    }

    return currentTime.hour >= startTime.hour &&
        currentTime.hour < endTime.hour;
  }

  /// Check if cooldown period is still active
  static bool isCooldownActive(DateTime disableTime, int cooldownHours) {
    final now = DateTime.now();
    final cooldownEnd = disableTime.add(Duration(hours: cooldownHours));
    return now.isBefore(cooldownEnd);
  }

  /// Get remaining cooldown time in minutes
  static int getRemainingCooldownMinutes(DateTime disableTime, int cooldownHours) {
    final now = DateTime.now();
    final cooldownEnd = disableTime.add(Duration(hours: cooldownHours));
    final remaining = cooldownEnd.difference(now);
    return remaining.inMinutes > 0 ? remaining.inMinutes : 0;
  }

  /// Determine if app access should be blocked
  static bool shouldBlockApp(
    String appName,
    PolicyRule? ruleForApp,
    PolicySchedule schedule,
  ) {
    if (ruleForApp == null) {
      return false;
    }

    // If hard block is enabled, always block
    if (schedule.hardBlockEnabled) {
      return true;
    }

    // Otherwise check if rule is active
    if (!isProtectionActive(schedule)) {
      return false;
    }

    // Check app-specific settings
    switch (appName.toLowerCase()) {
      case 'instagram':
        return ruleForApp.blockReels || ruleForApp.blockStories;
      case 'youtube':
        return ruleForApp.blockShorts;
      case 'tiktok':
        return ruleForApp.blockFeed;
      default:
        return false;
    }
  }

  /// Calculate next protection activation time
  static DateTime? getNextProtectionTime(PolicySchedule schedule) {
    final now = DateTime.now();
    final startTime = _parseTimeString(schedule.startTime);

    // Check today
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final dayName = _getDayName(checkDate.weekday);

      if (schedule.activeDays.contains(dayName)) {
        final protectionTime = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          startTime.hour,
          startTime.minute,
        );

        if (protectionTime.isAfter(now)) {
          return protectionTime;
        }
      }
    }

    return null;
  }

  /// Parse time string in HH:MM format to TimeOfDay
  static TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: parts.length > 1 ? int.parse(parts[1]) : 0,
    );
  }

  /// Get day name from weekday (1=Monday, 7=Sunday)
  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dt) {
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';
}

class PolicyEngineService {
  final Map<String, DateTime> _disableTimes = {};
  final Map<String, DateTime> _panicTimes = {};

  /// Check if protection is currently active
  bool isProtectionActive(PolicySchedule schedule) {
    return PolicyEvaluator.isProtectionActive(schedule);
  }

  /// Record a disable attempt
  void recordDisableAttempt(String policyId) {
    _disableTimes[policyId] = DateTime.now();
  }

  /// Record a panic button press
  void recordPanicPress(String policyId) {
    _panicTimes[policyId] = DateTime.now();
  }

  /// Check if disable cooldown is active
  bool isDisableCooldownActive(String policyId, int cooldownHours) {
    final disableTime = _disableTimes[policyId];
    if (disableTime == null) return false;
    return PolicyEvaluator.isCooldownActive(disableTime, cooldownHours);
  }

  /// Check if panic cooldown is active
  bool isPanicCooldownActive(String policyId, int cooldownHours) {
    final panicTime = _panicTimes[policyId];
    if (panicTime == null) return false;
    return PolicyEvaluator.isCooldownActive(panicTime, cooldownHours);
  }

  /// Get remaining cooldown minutes for disable
  int getDisableCooldownMinutes(String policyId, int cooldownHours) {
    final disableTime = _disableTimes[policyId];
    if (disableTime == null) return 0;
    return PolicyEvaluator.getRemainingCooldownMinutes(disableTime, cooldownHours);
  }

  /// Get remaining cooldown minutes for panic
  int getPanicCooldownMinutes(String policyId, int cooldownHours) {
    final panicTime = _panicTimes[policyId];
    if (panicTime == null) return 0;
    return PolicyEvaluator.getRemainingCooldownMinutes(panicTime, cooldownHours);
  }

  /// Evaluate if app should be blocked
  bool shouldBlockApp(
    String appName,
    PolicyRule? rule,
    PolicySchedule schedule,
  ) {
    return PolicyEvaluator.shouldBlockApp(appName, rule, schedule);
  }

  /// Clear cached times (for testing)
  void clearCache() {
    _disableTimes.clear();
    _panicTimes.clear();
  }
}
