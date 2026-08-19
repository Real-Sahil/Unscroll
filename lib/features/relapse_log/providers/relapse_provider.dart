import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/relapse_model.dart';

class RelapseNotifier extends StateNotifier<List<RelapseEvent>> {
  RelapseNotifier() : super([]);

  /// Add a new relapse event
  void addEvent(
    String eventType, {
    int? durationMinutes,
    String? appName,
    Map<String, dynamic>? metadata,
  }) {
    final event = RelapseEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      eventType: eventType,
      durationDisabledMinutes: durationMinutes,
      appName: appName,
      metadata: metadata,
    );
    state = [...state, event];
  }

  /// Get today's summary
  RelapseSummary getTodaySummary() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final todayEvents = state
        .where((e) => e.timestamp.isAfter(todayStart) && e.timestamp.isBefore(todayEnd))
        .toList();

    int disables = 0;
    int panics = 0;
    int bypasses = 0;
    int totalMinutes = 0;
    final disablesByHour = <String, int>{};
    final disablesByApp = <String, int>{};

    for (var event in todayEvents) {
      switch (event.eventType) {
        case 'disable':
          disables++;
          totalMinutes += event.durationDisabledMinutes ?? 0;

          // Track by hour
          final hour = '${event.timestamp.hour}:00';
          disablesByHour[hour] = (disablesByHour[hour] ?? 0) + 1;

          // Track by app
          if (event.appName != null) {
            disablesByApp[event.appName!] = (disablesByApp[event.appName!] ?? 0) + 1;
          }
          break;
        case 'panic':
          panics++;
          break;
        case 'friction_bypass':
          bypasses++;
          break;
      }
    }

    return RelapseSummary(
      date: todayStart,
      totalDisableAttempts: disables,
      panicButtonPresses: panics,
      frictionBypassAttempts: bypasses,
      totalFocusOffMinutes: totalMinutes,
      disablesByHour: disablesByHour,
      disablesByApp: disablesByApp,
    );
  }

  /// Get weekly summary
  WeeklySummary getWeeklySummary() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dailySummaries = <RelapseSummary>[];

    for (int i = 0; i < 7; i++) {
      final dayStart = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + i,
      );
      final dayEnd = DateTime(
        dayStart.year,
        dayStart.month,
        dayStart.day,
        23,
        59,
        59,
      );

      final dayEvents = state
          .where((e) => e.timestamp.isAfter(dayStart) && e.timestamp.isBefore(dayEnd))
          .toList();

      int disables = 0;
      int panics = 0;
      int bypasses = 0;
      int totalMinutes = 0;
      final disablesByHour = <String, int>{};
      final disablesByApp = <String, int>{};

      for (var event in dayEvents) {
        switch (event.eventType) {
          case 'disable':
            disables++;
            totalMinutes += event.durationDisabledMinutes ?? 0;
            final hour = '${event.timestamp.hour}:00';
            disablesByHour[hour] = (disablesByHour[hour] ?? 0) + 1;
            if (event.appName != null) {
              disablesByApp[event.appName!] = (disablesByApp[event.appName!] ?? 0) + 1;
            }
            break;
          case 'panic':
            panics++;
            break;
          case 'friction_bypass':
            bypasses++;
            break;
        }
      }

      dailySummaries.add(
        RelapseSummary(
          date: dayStart,
          totalDisableAttempts: disables,
          panicButtonPresses: panics,
          frictionBypassAttempts: bypasses,
          totalFocusOffMinutes: totalMinutes,
          disablesByHour: disablesByHour,
          disablesByApp: disablesByApp,
        ),
      );
    }

    return WeeklySummary(
      weekStart: weekStart,
      dailySummaries: dailySummaries,
    );
  }

  /// Get events from last N days
  List<RelapseEvent> getEventsInRange(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return state.where((e) => e.timestamp.isAfter(cutoffDate)).toList();
  }

  /// Clear all events (for testing)
  void clearAll() {
    state = [];
  }
}

final relapseProvider =
    StateNotifierProvider<RelapseNotifier, List<RelapseEvent>>(
  (ref) => RelapseNotifier(),
);

/// Provider for today's summary
final todaySummaryProvider = Provider((ref) {
  ref.watch(relapseProvider);
  return ref.read(relapseProvider.notifier).getTodaySummary();
});

/// Provider for weekly summary
final weeklySummaryProvider = Provider((ref) {
  ref.watch(relapseProvider);
  return ref.read(relapseProvider.notifier).getWeeklySummary();
});
