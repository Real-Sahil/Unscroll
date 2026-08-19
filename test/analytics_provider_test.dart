import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/features/analytics/models/analytics_models.dart';
import 'package:unscroll/features/analytics/providers/analytics_provider.dart';

void main() {
  group('AnalyticsProviders', () {
    late DailyAnalyticsNotifier dailyNotifier;
    late WeeklyAnalyticsNotifier weeklyNotifier;
    late MonthlyAnalyticsNotifier monthlyNotifier;
    late DataExportNotifier exportNotifier;

    setUp(() {
      dailyNotifier = DailyAnalyticsNotifier();
      weeklyNotifier = WeeklyAnalyticsNotifier();
      monthlyNotifier = MonthlyAnalyticsNotifier();
      exportNotifier = DataExportNotifier();
    });

    group('DailyAnalyticsNotifier', () {
      test('initializes with empty list', () {
        expect(dailyNotifier.state, isEmpty);
      });

      test('adds daily analytic', () {
        final daily = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 45,
          disableAttempts: 3,
          panicPresses: 1,
          savedByFriction: 35,
          relapsedApps: ['instagram', 'youtube'],
          hourlyBreakdown: {23: 25, 22: 20},
        );

        dailyNotifier.addClient(daily);
        expect(dailyNotifier.state.length, 1);
        expect(dailyNotifier.state.first.focusMinutesLost, 45);
      });

      test('removes daily analytic', () {
        final daily = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 45,
          disableAttempts: 3,
          panicPresses: 1,
          savedByFriction: 35,
          relapsedApps: ['instagram'],
          hourlyBreakdown: {23: 25},
        );

        dailyNotifier.addClient(daily);
        dailyNotifier.removeClient(DateTime(2024, 8, 15));
        expect(dailyNotifier.state, isEmpty);
      });

      test('updates daily analytic', () {
        final daily = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 45,
          disableAttempts: 3,
          panicPresses: 1,
          savedByFriction: 35,
          relapsedApps: ['instagram'],
          hourlyBreakdown: {23: 25},
        );

        dailyNotifier.addClient(daily);
        final updated = daily.copyWith(focusMinutesLost: 60);
        dailyNotifier.updateClient(updated);

        expect(dailyNotifier.state.first.focusMinutesLost, 60);
      });

      test('gets daily analytics in range', () {
        final daily1 = DailyAnalytic(
          date: DateTime(2024, 8, 13),
          focusMinutesLost: 30,
          disableAttempts: 2,
          panicPresses: 0,
          savedByFriction: 25,
          relapsedApps: ['instagram'],
          hourlyBreakdown: {23: 30},
        );

        final daily2 = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 45,
          disableAttempts: 3,
          panicPresses: 1,
          savedByFriction: 35,
          relapsedApps: ['youtube'],
          hourlyBreakdown: {22: 45},
        );

        dailyNotifier.addClient(daily1);
        dailyNotifier.addClient(daily2);

        final range = dailyNotifier.state
            .where((d) => d.date.isAfter(DateTime(2024, 8, 14)))
            .toList();

        expect(range.length, 1);
        expect(range.first.date, DateTime(2024, 8, 15));
      });

      test('calculates total minutes lost', () {
        final daily1 = DailyAnalytic(
          date: DateTime(2024, 8, 13),
          focusMinutesLost: 30,
          disableAttempts: 2,
          panicPresses: 0,
          savedByFriction: 25,
          relapsedApps: ['instagram'],
          hourlyBreakdown: {23: 30},
        );

        final daily2 = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 45,
          disableAttempts: 3,
          panicPresses: 1,
          savedByFriction: 35,
          relapsedApps: ['youtube'],
          hourlyBreakdown: {22: 45},
        );

        dailyNotifier.addClient(daily1);
        dailyNotifier.addClient(daily2);

        final total = dailyNotifier.state
            .map((d) => d.focusMinutesLost)
            .fold(0, (sum, minutes) => sum + minutes);

        expect(total, 75);
      });
    });

    group('WeeklyAnalyticsNotifier', () {
      test('initializes with empty list', () {
        expect(weeklyNotifier.state, isEmpty);
      });

      test('adds weekly analytic', () {
        final weekly = WeeklyAnalytic(
          weekStart: DateTime(2024, 8, 12),
          totalDisables: 15,
          totalPanics: 3,
          totalMinutesLost: 280,
          minutesSaved: 210,
          adherencePercentage: 75.0,
          mostActiveDay: 'Friday',
          mostActiveHour: 23,
          mostTemptingApp: 'instagram',
          dailyBreakdown: [],
        );

        weeklyNotifier.addClient(weekly);
        expect(weeklyNotifier.state.length, 1);
        expect(weeklyNotifier.state.first.adherencePercentage, 75.0);
      });

      test('removes weekly analytic', () {
        final weekly = WeeklyAnalytic(
          weekStart: DateTime(2024, 8, 12),
          totalDisables: 15,
          totalPanics: 3,
          totalMinutesLost: 280,
          minutesSaved: 210,
          adherencePercentage: 75.0,
          mostActiveDay: 'Friday',
          mostActiveHour: 23,
          mostTemptingApp: 'instagram',
          dailyBreakdown: [],
        );

        weeklyNotifier.addClient(weekly);
        weeklyNotifier.removeClient(DateTime(2024, 8, 12));
        expect(weeklyNotifier.state, isEmpty);
      });

      test('updates weekly analytic', () {
        final weekly = WeeklyAnalytic(
          weekStart: DateTime(2024, 8, 12),
          totalDisables: 15,
          totalPanics: 3,
          totalMinutesLost: 280,
          minutesSaved: 210,
          adherencePercentage: 75.0,
          mostActiveDay: 'Friday',
          mostActiveHour: 23,
          mostTemptingApp: 'instagram',
          dailyBreakdown: [],
        );

        weeklyNotifier.addClient(weekly);
        final updated = weekly.copyWith(adherencePercentage: 82.0);
        weeklyNotifier.updateClient(updated);

        expect(weeklyNotifier.state.first.adherencePercentage, 82.0);
      });

      test('filters high adherence weeks', () {
        final weekly1 = WeeklyAnalytic(
          weekStart: DateTime(2024, 8, 5),
          totalDisables: 20,
          totalPanics: 2,
          totalMinutesLost: 350,
          minutesSaved: 400,
          adherencePercentage: 88.0,
          mostActiveDay: 'Saturday',
          mostActiveHour: 22,
          mostTemptingApp: 'youtube',
          dailyBreakdown: [],
        );

        final weekly2 = WeeklyAnalytic(
          weekStart: DateTime(2024, 8, 12),
          totalDisables: 15,
          totalPanics: 3,
          totalMinutesLost: 280,
          minutesSaved: 210,
          adherencePercentage: 65.0,
          mostActiveDay: 'Friday',
          mostActiveHour: 23,
          mostTemptingApp: 'instagram',
          dailyBreakdown: [],
        );

        weeklyNotifier.addClient(weekly1);
        weeklyNotifier.addClient(weekly2);

        final highAdherence = weeklyNotifier.state
            .where((w) => w.adherencePercentage >= 85)
            .toList();

        expect(highAdherence.length, 1);
        expect(highAdherence.first.weekStart, DateTime(2024, 8, 5));
      });
    });

    group('MonthlyAnalyticsNotifier', () {
      test('initializes with empty list', () {
        expect(monthlyNotifier.state, isEmpty);
      });

      test('adds monthly analytic', () {
        final monthly = MonthlyAnalytic(
          monthStart: DateTime(2024, 8, 1),
          totalDisables: 60,
          totalPanics: 12,
          totalMinutesLost: 1200,
          minutesSaved: 900,
          adherencePercentage: 72.0,
          improvedDaysCount: 18,
          consistentDaysCount: 15,
          topRelapseApps: ['instagram', 'youtube', 'tiktok'],
          hourlyDistribution: [0, 0, 0, 0, 0, 0, 0, 0, 50, 45, 60, 75, 80, 90, 85, 70, 65, 55, 45, 120, 130, 150, 160, 140],
        );

        monthlyNotifier.addClient(monthly);
        expect(monthlyNotifier.state.length, 1);
        expect(monthlyNotifier.state.first.adherencePercentage, 72.0);
      });

      test('calculates average adherence across months', () {
        final monthly1 = MonthlyAnalytic(
          monthStart: DateTime(2024, 7, 1),
          totalDisables: 70,
          totalPanics: 10,
          totalMinutesLost: 1400,
          minutesSaved: 800,
          adherencePercentage: 65.0,
          improvedDaysCount: 15,
          consistentDaysCount: 12,
          topRelapseApps: ['instagram'],
          hourlyDistribution: List.filled(24, 0),
        );

        final monthly2 = MonthlyAnalytic(
          monthStart: DateTime(2024, 8, 1),
          totalDisables: 60,
          totalPanics: 12,
          totalMinutesLost: 1200,
          minutesSaved: 900,
          adherencePercentage: 75.0,
          improvedDaysCount: 18,
          consistentDaysCount: 15,
          topRelapseApps: ['youtube'],
          hourlyDistribution: List.filled(24, 0),
        );

        monthlyNotifier.addClient(monthly1);
        monthlyNotifier.addClient(monthly2);

        final avgAdherence = monthlyNotifier.state
            .map((m) => m.adherencePercentage)
            .fold(0.0, (sum, val) => sum + val) / monthlyNotifier.state.length;

        expect(avgAdherence, 70.0);
      });

      test('identifies most tempting hour across month', () {
        final monthly = MonthlyAnalytic(
          monthStart: DateTime(2024, 8, 1),
          totalDisables: 60,
          totalPanics: 12,
          totalMinutesLost: 1200,
          minutesSaved: 900,
          adherencePercentage: 72.0,
          improvedDaysCount: 18,
          consistentDaysCount: 15,
          topRelapseApps: ['instagram'],
          hourlyDistribution: [0, 0, 0, 0, 0, 0, 0, 0, 50, 45, 60, 75, 80, 90, 85, 70, 65, 55, 45, 120, 130, 150, 160, 140],
        );

        monthlyNotifier.addClient(monthly);

        final maxHour = monthly.hourlyDistribution
            .asMap()
            .entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        expect(maxHour, 22); // Hour 22 (10 PM) has 160 relapse attempts
      });
    });

    group('DataExportNotifier', () {
      test('initializes with null', () {
        expect(exportNotifier.state, isNull);
      });

      test('creates JSON export', () {
        final now = DateTime.now();
        final export = DataExportPackage(
          exportedAt: now,
          format: 'json',
          dailyData: [],
          weeklyData: [],
          monthlyData: [],
          metadata: {
            'version': '1.0',
            'userId': 'user_123',
            'appVersion': '1.0.0',
          },
        );

        exportNotifier.createExport(export);
        expect(exportNotifier.state, isNotNull);
        expect(exportNotifier.state?.format, 'json');
      });

      test('exports data to JSON format', () {
        final daily = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 45,
          disableAttempts: 3,
          panicPresses: 1,
          savedByFriction: 35,
          relapsedApps: ['instagram'],
          hourlyBreakdown: {23: 25},
        );

        final export = DataExportPackage(
          exportedAt: DateTime.now(),
          format: 'json',
          dailyData: [daily],
          weeklyData: [],
          monthlyData: [],
          metadata: {'userId': 'user_123'},
        );

        exportNotifier.createExport(export);
        final json = exportNotifier.toJSON();

        expect(json, contains('user_123'));
        expect(json, contains('45'));
      });

      test('exports data to CSV format', () {
        final daily = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 45,
          disableAttempts: 3,
          panicPresses: 1,
          savedByFriction: 35,
          relapsedApps: ['instagram'],
          hourlyBreakdown: {23: 25},
        );

        final export = DataExportPackage(
          exportedAt: DateTime.now(),
          format: 'csv',
          dailyData: [daily],
          weeklyData: [],
          monthlyData: [],
          metadata: {},
        );

        exportNotifier.createExport(export);
        final csv = exportNotifier.toCSV();

        expect(csv, contains('Date'));
        expect(csv, contains('45'));
      });

      test('clears export', () {
        final export = DataExportPackage(
          exportedAt: DateTime.now(),
          format: 'json',
          dailyData: [],
          weeklyData: [],
          monthlyData: [],
          metadata: {},
        );

        exportNotifier.createExport(export);
        expect(exportNotifier.state, isNotNull);

        exportNotifier.clearExport();
        expect(exportNotifier.state, isNull);
      });
    });

    group('Analytics Calculations', () {
      test('calculates adherence percentage', () {
        final protectedDays = 21;
        final totalDays = 30;
        final adherence = (protectedDays / totalDays) * 100;

        expect(adherence, closeTo(70.0, 0.1));
      });

      test('identifies improvement trend', () {
        final weeklyScores = [60.0, 65.0, 72.0, 78.0, 85.0];
        final isImproving = weeklyScores.last > weeklyScores.first;

        expect(isImproving, true);
      });

      test('counts relapse-free days', () {
        final daily1 = DailyAnalytic(
          date: DateTime(2024, 8, 13),
          focusMinutesLost: 0,
          disableAttempts: 0,
          panicPresses: 0,
          savedByFriction: 0,
          relapsedApps: [],
          hourlyBreakdown: {},
        );

        final daily2 = DailyAnalytic(
          date: DateTime(2024, 8, 14),
          focusMinutesLost: 30,
          disableAttempts: 2,
          panicPresses: 0,
          savedByFriction: 25,
          relapsedApps: ['instagram'],
          hourlyBreakdown: {23: 30},
        );

        final daily3 = DailyAnalytic(
          date: DateTime(2024, 8, 15),
          focusMinutesLost: 0,
          disableAttempts: 0,
          panicPresses: 0,
          savedByFriction: 0,
          relapsedApps: [],
          hourlyBreakdown: {},
        );

        final days = [daily1, daily2, daily3];
        final relapseFreeDays = days.where((d) => d.focusMinutesLost == 0).length;

        expect(relapseFreeDays, 2);
      });
    });
  });
}
