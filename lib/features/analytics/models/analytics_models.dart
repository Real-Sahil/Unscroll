import 'package:flutter/foundation.dart';

@immutable
class DailyAnalytic {
  final DateTime date;
  final int focusMinutesLost;
  final int disableAttempts;
  final int panicPresses;
  final int savedByFriction;
  final List<String> relapsedApps;
  final Map<int, int> hourlyBreakdown; // hour -> attempt count

  const DailyAnalytic({
    required this.date,
    required this.focusMinutesLost,
    required this.disableAttempts,
    required this.panicPresses,
    required this.savedByFriction,
    required this.relapsedApps,
    required this.hourlyBreakdown,
  });

  DailyAnalytic copyWith({
    DateTime? date,
    int? focusMinutesLost,
    int? disableAttempts,
    int? panicPresses,
    int? savedByFriction,
    List<String>? relapsedApps,
    Map<int, int>? hourlyBreakdown,
  }) {
    return DailyAnalytic(
      date: date ?? this.date,
      focusMinutesLost: focusMinutesLost ?? this.focusMinutesLost,
      disableAttempts: disableAttempts ?? this.disableAttempts,
      panicPresses: panicPresses ?? this.panicPresses,
      savedByFriction: savedByFriction ?? this.savedByFriction,
      relapsedApps: relapsedApps ?? this.relapsedApps,
      hourlyBreakdown: hourlyBreakdown ?? this.hourlyBreakdown,
    );
  }
}

@immutable
class WeeklyAnalytic {
  final DateTime weekStart;
  final int totalDisables;
  final int totalPanics;
  final int totalMinutesLost;
  final int minutesSaved;
  final double adherencePercentage;
  final String mostActiveDay;
  final int mostActiveHour;
  final String mostTemptingApp;
  final List<DailyAnalytic> dailyBreakdown;

  const WeeklyAnalytic({
    required this.weekStart,
    required this.totalDisables,
    required this.totalPanics,
    required this.totalMinutesLost,
    required this.minutesSaved,
    required this.adherencePercentage,
    required this.mostActiveDay,
    required this.mostActiveHour,
    required this.mostTemptingApp,
    required this.dailyBreakdown,
  });

  WeeklyAnalytic copyWith({
    DateTime? weekStart,
    int? totalDisables,
    int? totalPanics,
    int? totalMinutesLost,
    int? minutesSaved,
    double? adherencePercentage,
    String? mostActiveDay,
    int? mostActiveHour,
    String? mostTemptingApp,
    List<DailyAnalytic>? dailyBreakdown,
  }) {
    return WeeklyAnalytic(
      weekStart: weekStart ?? this.weekStart,
      totalDisables: totalDisables ?? this.totalDisables,
      totalPanics: totalPanics ?? this.totalPanics,
      totalMinutesLost: totalMinutesLost ?? this.totalMinutesLost,
      minutesSaved: minutesSaved ?? this.minutesSaved,
      adherencePercentage: adherencePercentage ?? this.adherencePercentage,
      mostActiveDay: mostActiveDay ?? this.mostActiveDay,
      mostActiveHour: mostActiveHour ?? this.mostActiveHour,
      mostTemptingApp: mostTemptingApp ?? this.mostTemptingApp,
      dailyBreakdown: dailyBreakdown ?? this.dailyBreakdown,
    );
  }
}

@immutable
class MonthlyAnalytic {
  final DateTime monthStart;
  final int totalDisables;
  final int totalPanics;
  final int totalMinutesLost;
  final int minutesSaved;
  final double adherencePercentage;
  final int improvedDaysCount;
  final int consistentDaysCount;
  final List<String> topRelapseApps;
  final List<int> hourlyDistribution; // 24 elements for each hour

  const MonthlyAnalytic({
    required this.monthStart,
    required this.totalDisables,
    required this.totalPanics,
    required this.totalMinutesLost,
    required this.minutesSaved,
    required this.adherencePercentage,
    required this.improvedDaysCount,
    required this.consistentDaysCount,
    required this.topRelapseApps,
    required this.hourlyDistribution,
  });

  MonthlyAnalytic copyWith({
    DateTime? monthStart,
    int? totalDisables,
    int? totalPanics,
    int? totalMinutesLost,
    int? minutesSaved,
    double? adherencePercentage,
    int? improvedDaysCount,
    int? consistentDaysCount,
    List<String>? topRelapseApps,
    List<int>? hourlyDistribution,
  }) {
    return MonthlyAnalytic(
      monthStart: monthStart ?? this.monthStart,
      totalDisables: totalDisables ?? this.totalDisables,
      totalPanics: totalPanics ?? this.totalPanics,
      totalMinutesLost: totalMinutesLost ?? this.totalMinutesLost,
      minutesSaved: minutesSaved ?? this.minutesSaved,
      adherencePercentage: adherencePercentage ?? this.adherencePercentage,
      improvedDaysCount: improvedDaysCount ?? this.improvedDaysCount,
      consistentDaysCount: consistentDaysCount ?? this.consistentDaysCount,
      topRelapseApps: topRelapseApps ?? this.topRelapseApps,
      hourlyDistribution: hourlyDistribution ?? this.hourlyDistribution,
    );
  }
}

@immutable
class DataExportPackage {
  final DateTime exportedAt;
  final String format; // 'csv', 'json', 'pdf'
  final List<DailyAnalytic> dailyData;
  final List<WeeklyAnalytic> weeklyData;
  final List<MonthlyAnalytic> monthlyData;
  final Map<String, dynamic> metadata;

  const DataExportPackage({
    required this.exportedAt,
    required this.format,
    required this.dailyData,
    required this.weeklyData,
    required this.monthlyData,
    required this.metadata,
  });

  String get fileExtension => format == 'csv' ? '.csv' : format == 'json' ? '.json' : '.pdf';

  String get filename => 'unscroll_export_${exportedAt.toString().split(' ')[0]}$fileExtension';

  DataExportPackage copyWith({
    DateTime? exportedAt,
    String? format,
    List<DailyAnalytic>? dailyData,
    List<WeeklyAnalytic>? weeklyData,
    List<MonthlyAnalytic>? monthlyData,
    Map<String, dynamic>? metadata,
  }) {
    return DataExportPackage(
      exportedAt: exportedAt ?? this.exportedAt,
      format: format ?? this.format,
      dailyData: dailyData ?? this.dailyData,
      weeklyData: weeklyData ?? this.weeklyData,
      monthlyData: monthlyData ?? this.monthlyData,
      metadata: metadata ?? this.metadata,
    );
  }
}

@immutable
class AnalyticsFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? apps;
  final int? minHour;
  final int? maxHour;

  const AnalyticsFilter({
    this.startDate,
    this.endDate,
    this.apps,
    this.minHour,
    this.maxHour,
  });

  AnalyticsFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? apps,
    int? minHour,
    int? maxHour,
  }) {
    return AnalyticsFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      apps: apps ?? this.apps,
      minHour: minHour ?? this.minHour,
      maxHour: maxHour ?? this.maxHour,
    );
  }
}
