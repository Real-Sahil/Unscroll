import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/analytics/models/analytics_models.dart';
import 'package:unscroll/features/analytics/providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedTab = 'overview'; // overview, weekly, monthly, export
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    final dailyNotifier = ref.read(dailyAnalyticsProvider.notifier);
    final weeklyNotifier = ref.read(weeklyAnalyticsProvider.notifier);
    final monthlyNotifier = ref.read(monthlyAnalyticsProvider.notifier);

    List<DailyAnalytic> sampleDaily = [];
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      sampleDaily.add(DailyAnalytic(
        date: date,
        focusMinutesLost: (i % 5) * 15 + 10,
        disableAttempts: (i % 4) + 1,
        panicPresses: (i % 3),
        savedByFriction: (i % 6) * 10,
        relapsedApps: i % 2 == 0 ? ['instagram'] : ['youtube', 'tiktok'],
        hourlyBreakdown: {
          20: (i % 3) + 1,
          21: (i % 4) + 1,
          22: (i % 5) + 2,
        },
      ));
    }
    dailyNotifier.setDailyData(sampleDaily);

    List<WeeklyAnalytic> sampleWeekly = [];
    for (int w = 0; w < 4; w++) {
      final weekStart = now.subtract(Duration(days: w * 7));
      sampleWeekly.add(WeeklyAnalytic(
        weekStart: weekStart,
        totalDisables: 5 + w,
        totalPanics: 2 + w,
        totalMinutesLost: 120 + (w * 10),
        minutesSaved: 240 - (w * 20),
        adherencePercentage: 85.0 - (w * 5),
        mostActiveDay: 'Friday',
        mostActiveHour: 21 + w,
        mostTemptingApp: w % 2 == 0 ? 'Instagram' : 'TikTok',
        dailyBreakdown: [],
      ));
    }
    weeklyNotifier.setWeeklyData(sampleWeekly);

    List<MonthlyAnalytic> sampleMonthly = [];
    for (int m = 0; m < 3; m++) {
      final monthStart = DateTime(now.year, now.month - m, 1);
      sampleMonthly.add(MonthlyAnalytic(
        monthStart: monthStart,
        totalDisables: 20 + (m * 3),
        totalPanics: 8 + m,
        totalMinutesLost: 480 + (m * 30),
        minutesSaved: 960 - (m * 50),
        adherencePercentage: 82.0 - (m * 5),
        improvedDaysCount: 15 + (m * 2),
        consistentDaysCount: 10 - m,
        topRelapseApps: ['Instagram', 'TikTok', 'YouTube'],
        hourlyDistribution: List.generate(24, (h) => (h % 4) + 1),
      ));
    }
    monthlyNotifier.setMonthlyData(sampleMonthly);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Overview',
                      isSelected: _selectedTab == 'overview',
                      onTap: () => setState(() => _selectedTab = 'overview'),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Weekly',
                      isSelected: _selectedTab == 'weekly',
                      onTap: () => setState(() => _selectedTab = 'weekly'),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Monthly',
                      isSelected: _selectedTab == 'monthly',
                      onTap: () => setState(() => _selectedTab = 'monthly'),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: 'Export',
                      isSelected: _selectedTab == 'export',
                      onTap: () => setState(() => _selectedTab = 'export'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: () {
                switch (_selectedTab) {
                  case 'overview':
                    return _buildOverview(context, ref);
                  case 'weekly':
                    return _buildWeekly(context, ref);
                  case 'monthly':
                    return _buildMonthly(context, ref);
                  case 'export':
                    return _buildExport(context, ref);
                  default:
                    return const SizedBox.shrink();
                }
              }(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(analyticsOverviewProvider);
    final topApps = ref.watch(topAppsProvider);
    final highRiskHours = ref.watch(highRiskHoursProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All-Time Statistics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _StatTile(
              label: 'Minutes Lost',
              value: '${overview.totalMinutesLost}',
              icon: Icons.timer_off,
              color: Colors.red,
            ),
            _StatTile(
              label: 'Minutes Saved',
              value: '${overview.minutesSaved}',
              icon: Icons.timer,
              color: const Color(0xFF00AA66),
            ),
            _StatTile(
              label: 'Disable Attempts',
              value: '${overview.totalDisables}',
              icon: Icons.block,
              color: Colors.orange,
            ),
            _StatTile(
              label: 'Panic Presses',
              value: '${overview.totalPanics}',
              icon: Icons.sos,
              color: const Color(0xFF0066CC),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle('Top Risky Apps', context),
        const SizedBox(height: 12),
        if (topApps.isEmpty)
          Text(
            'No data available',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topApps
                .asMap()
                .entries
                .map((e) => Chip(
                      label: Text('${e.value} #${e.key + 1}'),
                      backgroundColor: Colors.orange[100],
                      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.orange[900],
                          ),
                    ))
                .toList(),
          ),
        const SizedBox(height: 24),
        _SectionTitle('High-Risk Hours', context),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: highRiskHours
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${e.value}:00 - ${(e.value + 1) % 24}:00'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Risk Level ${e.key + 1}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.red[900],
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekly(BuildContext context, WidgetRef ref) {
    final weeklyData = ref.watch(weeklyAnalyticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        if (weeklyData.isEmpty)
          Text(
            'No weekly data available',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Column(
            children: weeklyData.map((week) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WeeklyCard(week: week),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMonthly(BuildContext context, WidgetRef ref) {
    final monthlyData = ref.watch(monthlyAnalyticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Trends',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        if (monthlyData.isEmpty)
          Text(
            'No monthly data available',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Column(
            children: monthlyData.map((month) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MonthlyCard(month: month),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildExport(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Your Data',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Download your recovery data in your preferred format. Your data is encrypted and private.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        _ExportFormatTile(
          format: 'JSON',
          description: 'Complete data export with all metrics',
          icon: Icons.data_object,
          onTap: () {
            ref.read(dataExportProvider.notifier).createExport(
              ref.read(dailyAnalyticsProvider),
              ref.read(weeklyAnalyticsProvider),
              ref.read(monthlyAnalyticsProvider),
              format: 'json',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export prepared (JSON)')),
            );
          },
        ),
        _ExportFormatTile(
          format: 'CSV',
          description: 'Spreadsheet-compatible format',
          icon: Icons.table_chart,
          onTap: () {
            ref.read(dataExportProvider.notifier).createExport(
              ref.read(dailyAnalyticsProvider),
              ref.read(weeklyAnalyticsProvider),
              ref.read(monthlyAnalyticsProvider),
              format: 'csv',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export prepared (CSV)')),
            );
          },
        ),
        _ExportFormatTile(
          format: 'PDF Report',
          description: 'Printable recovery report',
          icon: Icons.picture_as_pdf,
          onTap: () {
            ref.read(dataExportProvider.notifier).createExport(
              ref.read(dailyAnalyticsProvider),
              ref.read(weeklyAnalyticsProvider),
              ref.read(monthlyAnalyticsProvider),
              format: 'pdf',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export prepared (PDF)')),
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy & Security',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your data is stored locally on your device and encrypted end-to-end. Exports are created locally on your device.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[900],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _SectionTitle(String text, BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066CC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final WeeklyAnalytic week;

  const _WeeklyCard({Key? key, required this.week}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week of ${week.weekStart.toString().split(' ')[0]}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat('Disables', '${week.totalDisables}', Colors.red),
              _MiniStat('Panics', '${week.totalPanics}', Colors.orange),
              _MiniStat('Adherence', '${week.adherencePercentage.toStringAsFixed(0)}%', const Color(0xFF00AA66)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyCard extends StatelessWidget {
  final MonthlyAnalytic month;

  const _MonthlyCard({Key? key, required this.month}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Month of ${month.monthStart.toString().substring(0, 7)}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat('Improved Days', '${month.improvedDaysCount}', const Color(0xFF00AA66)),
              _MiniStat('Consistent', '${month.consistentDaysCount}', const Color(0xFF0066CC)),
              _MiniStat('Adherence', '${month.adherencePercentage.toStringAsFixed(0)}%', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _ExportFormatTile extends StatelessWidget {
  final String format;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExportFormatTile({
    Key? key,
    required this.format,
    required this.description,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(icon, size: 28, color: const Color(0xFF0066CC)),
        title: Text(format),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
