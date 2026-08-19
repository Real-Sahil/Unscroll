class RelapseEvent {
  final String id;
  final DateTime timestamp;
  final String eventType; // 'disable', 'panic', 'friction_bypass'
  final int? durationDisabledMinutes;
  final String? appName;
  final Map<String, dynamic>? metadata;

  RelapseEvent({
    required this.id,
    required this.timestamp,
    required this.eventType,
    this.durationDisabledMinutes,
    this.appName,
    this.metadata,
  });

  /// Get human-readable event description
  String getDescription() {
    switch (eventType) {
      case 'disable':
        return 'Protection Disabled';
      case 'panic':
        return 'Panic Button Pressed';
      case 'friction_bypass':
        return 'Friction Challenge Failed';
      default:
        return 'Unknown Event';
    }
  }

  /// Get icon for event type
  String getEmoji() {
    switch (eventType) {
      case 'disable':
        return '🔓';
      case 'panic':
        return '🚨';
      case 'friction_bypass':
        return '⚠️';
      default:
        return '📝';
    }
  }
}

class RelapseSummary {
  final DateTime date;
  final int totalDisableAttempts;
  final int panicButtonPresses;
  final int frictionBypassAttempts;
  final int totalFocusOffMinutes;
  final Map<String, int> disablesByHour; // Hour -> count
  final Map<String, int> disablesByApp; // App name -> count

  RelapseSummary({
    required this.date,
    this.totalDisableAttempts = 0,
    this.panicButtonPresses = 0,
    this.frictionBypassAttempts = 0,
    this.totalFocusOffMinutes = 0,
    this.disablesByHour = const {},
    this.disablesByApp = const {},
  });

  /// Get compassionate encouragement message
  String getEncouragementMessage() {
    if (totalDisableAttempts == 0) {
      return '🎉 Perfect day! You stayed strong!';
    } else if (totalDisableAttempts <= 2) {
      return '💪 Great effort today! Keep it going.';
    } else if (totalDisableAttempts <= 5) {
      return '📈 Progress over perfection. You\'re learning.';
    } else {
      return '🌱 Recovery isn\'t linear. Be kind to yourself.';
    }
  }

  /// Get the hour with most disables (for pattern detection)
  int? getHighestRiskHour() {
    if (disablesByHour.isEmpty) return null;
    return disablesByHour.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .replaceAll(':00', '') as int;
  }

  /// Get the app with most disables
  String? getHighestRiskApp() {
    if (disablesByApp.isEmpty) return null;
    return disablesByApp.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

class WeeklySummary {
  final DateTime weekStart;
  final List<RelapseSummary> dailySummaries;

  WeeklySummary({
    required this.weekStart,
    required this.dailySummaries,
  });

  int getTotalDisables() {
    return dailySummaries.fold<int>(
      0,
      (sum, summary) => sum + summary.totalDisableAttempts,
    );
  }

  int getAverageFocusOffMinutes() {
    if (dailySummaries.isEmpty) return 0;
    final total = dailySummaries.fold<int>(
      0,
      (sum, summary) => sum + summary.totalFocusOffMinutes,
    );
    return (total / dailySummaries.length).ceil();
  }

  String getTrendMessage() {
    if (dailySummaries.length < 2) return 'Not enough data';

    final latest = dailySummaries.last.totalDisableAttempts;
    final previous = dailySummaries[dailySummaries.length - 2].totalDisableAttempts;

    if (latest < previous) {
      return '📉 Improving! Fewer disables than yesterday.';
    } else if (latest > previous) {
      return '📈 Challenging day. Tomorrow is a fresh start.';
    } else {
      return '➡️ Steady. Keep your routine consistent.';
    }
  }
}
