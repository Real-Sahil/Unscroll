import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/analytics/models/analytics_models.dart';

class DailyAnalyticsNotifier extends StateNotifier<List<DailyAnalytic>> {
  DailyAnalyticsNotifier() : super([]);

  void setDailyData(List<DailyAnalytic> data) {
    state = data;
  }

  void addDailyData(DailyAnalytic data) {
    state = [...state, data];
  }

  void updateDailyData(DateTime date, DailyAnalytic updated) {
    state = state.map((d) => d.date.compareTo(date) == 0 ? updated : d).toList();
  }

  List<DailyAnalytic> getRange(DateTime start, DateTime end) {
    return state
        .where((d) => !d.date.isBefore(start) && !d.date.isAfter(end))
        .toList();
  }

  int getTotalMinutesLost(DateTime start, DateTime end) {
    return getRange(start, end)
        .fold(0, (sum, d) => sum + d.focusMinutesLost);
  }

  int getTotalDisables(DateTime start, DateTime end) {
    return getRange(start, end)
        .fold(0, (sum, d) => sum + d.disableAttempts);
  }

  int getTotalPanics(DateTime start, DateTime end) {
    return getRange(start, end)
        .fold(0, (sum, d) => sum + d.panicPresses);
  }
}

class WeeklyAnalyticsNotifier extends StateNotifier<List<WeeklyAnalytic>> {
  WeeklyAnalyticsNotifier() : super([]);

  void setWeeklyData(List<WeeklyAnalytic> data) {
    state = data;
  }

  void addWeeklyData(WeeklyAnalytic data) {
    state = [...state, data];
  }

  void updateWeeklyData(DateTime weekStart, WeeklyAnalytic updated) {
    state = state
        .map((w) => w.weekStart.compareTo(weekStart) == 0 ? updated : w)
        .toList();
  }

  List<WeeklyAnalytic> sortByAdherence() {
    return [...state]..sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));
  }

  List<WeeklyAnalytic> sortByImprovement() {
    return [...state]..sort((a, b) => b.minutesSaved.compareTo(a.minutesSaved));
  }
}

class MonthlyAnalyticsNotifier extends StateNotifier<List<MonthlyAnalytic>> {
  MonthlyAnalyticsNotifier() : super([]);

  void setMonthlyData(List<MonthlyAnalytic> data) {
    state = data;
  }

  void addMonthlyData(MonthlyAnalytic data) {
    state = [...state, data];
  }

  List<MonthlyAnalytic> sortByAdherence() {
    return [...state]..sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));
  }

  double getAverageAdherence() {
    if (state.isEmpty) return 0;
    return state.fold(0.0, (sum, m) => sum + m.adherencePercentage) / state.length;
  }

  int getTotalTimeSaved() {
    return state.fold(0, (sum, m) => sum + m.minutesSaved);
  }
}

class DataExportNotifier extends StateNotifier<DataExportPackage?> {
  DataExportNotifier() : super(null);

  void createExport(
    List<DailyAnalytic> daily,
    List<WeeklyAnalytic> weekly,
    List<MonthlyAnalytic> monthly, {
    String format = 'json',
    Map<String, dynamic>? metadata,
  }) {
    state = DataExportPackage(
      exportedAt: DateTime.now(),
      format: format,
      dailyData: daily,
      weeklyData: weekly,
      monthlyData: monthly,
      metadata: metadata ?? {},
    );
  }

  String toJSON() {
    if (state == null) return '{}';
    return '''
{
  "exportedAt": "${state!.exportedAt.toIso8601String()}",
  "format": "${state!.format}",
  "dailyDataCount": ${state!.dailyData.length},
  "weeklyDataCount": ${state!.weeklyData.length},
  "monthlyDataCount": ${state!.monthlyData.length},
  "metadata": ${_mapToJsonString(state!.metadata)}
}
''';
  }

  String toCSV() {
    if (state == null) return '';
    final buffer = StringBuffer();
    buffer.writeln('Date,Focus Minutes Lost,Disables,Panics,Saved by Friction');

    for (var daily in state!.dailyData) {
      buffer.writeln(
        '${daily.date.toIso8601String()},${daily.focusMinutesLost},${daily.disableAttempts},${daily.panicPresses},${daily.savedByFriction}',
      );
    }

    return buffer.toString();
  }

  String _mapToJsonString(Map<String, dynamic> map) {
    return map.toString();
  }

  void clearExport() {
    state = null;
  }
}

final dailyAnalyticsProvider =
    StateNotifierProvider<DailyAnalyticsNotifier, List<DailyAnalytic>>((ref) {
  return DailyAnalyticsNotifier();
});

final weeklyAnalyticsProvider =
    StateNotifierProvider<WeeklyAnalyticsNotifier, List<WeeklyAnalytic>>((ref) {
  return WeeklyAnalyticsNotifier();
});

final monthlyAnalyticsProvider =
    StateNotifierProvider<MonthlyAnalyticsNotifier, List<MonthlyAnalytic>>((ref) {
  return MonthlyAnalyticsNotifier();
});

final dataExportProvider =
    StateNotifierProvider<DataExportNotifier, DataExportPackage?>((ref) {
  return DataExportNotifier();
});

final analyticsOverviewProvider = Provider<({
  int totalMinutesLost,
  int totalDisables,
  int totalPanics,
  double averageAdherence,
  int minutesSaved,
})>((ref) {
  final daily = ref.watch(dailyAnalyticsProvider);
  final monthly = ref.watch(monthlyAnalyticsProvider);

  final totalMinutesLost = daily.fold(0, (sum, d) => sum + d.focusMinutesLost);
  final totalDisables = daily.fold(0, (sum, d) => sum + d.disableAttempts);
  final totalPanics = daily.fold(0, (sum, d) => sum + d.panicPresses);
  final averageAdherence =
      monthly.isNotEmpty
          ? monthly.fold(0.0, (sum, m) => sum + m.adherencePercentage) / monthly.length
          : 0.0;
  final minutesSaved = monthly.fold(0, (sum, m) => sum + m.minutesSaved);

  return (
    totalMinutesLost: totalMinutesLost,
    totalDisables: totalDisables,
    totalPanics: totalPanics,
    averageAdherence: averageAdherence,
    minutesSaved: minutesSaved,
  );
});

final topAppsProvider = Provider<List<String>>((ref) {
  final daily = ref.watch(dailyAnalyticsProvider);
  final appCounts = <String, int>{};

  for (var d in daily) {
    for (var app in d.relapsedApps) {
      appCounts[app] = (appCounts[app] ?? 0) + 1;
    }
  }

  final sorted = appCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.map((e) => e.key).take(5).toList();
});

final highRiskHoursProvider = Provider<List<int>>((ref) {
  final daily = ref.watch(dailyAnalyticsProvider);
  final hourCounts = <int, int>{};

  for (var d in daily) {
    for (var entry in d.hourlyBreakdown.entries) {
      hourCounts[entry.key] = (hourCounts[entry.key] ?? 0) + entry.value;
    }
  }

  final sorted = hourCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.map((e) => e.key).take(5).toList();
});
