import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/accountability/providers/accountability_provider.dart';

class AccountabilitySummariesScreen extends ConsumerWidget {
  final String? partnerId;

  const AccountabilitySummariesScreen({
    Key? key,
    this.partnerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(accountabilitySummaryProvider);
    final filteredSummaries = partnerId != null
        ? summaries.where((s) => s.partnerId == partnerId).toList()
        : summaries;

    final sortedSummaries = filteredSummaries
        .sort((a, b) => b.weekStart.compareTo(a.weekStart));

    return Scaffold(
      appBar: AppBar(
        title: Text(partnerId != null
            ? 'Weekly Summaries'
            : 'All Accountability Summaries'),
        elevation: 0,
      ),
      body: filteredSummaries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No summaries yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weekly summaries will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: filteredSummaries.map((summary) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SummaryCard(summary: summary),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final dynamic summary;

  const _SummaryCard({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Week of ${summary.weekStart.toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (summary.sentAt)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00AA66).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sent',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF00AA66),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Stats grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Statistics',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _StatTile(
                      icon: Icons.block,
                      label: 'Block Attempts',
                      value: '${summary.totalDisables}',
                      color: const Color(0xFFFF8C00),
                    ),
                    _StatTile(
                      icon: Icons.sos,
                      label: 'Panic Presses',
                      value: '${summary.totalPanicPresses}',
                      color: Colors.red,
                    ),
                    _StatTile(
                      icon: Icons.access_time,
                      label: 'Focus Off Time',
                      value: '${summary.focusOffMinutes}m',
                      color: const Color(0xFF0066CC),
                    ),
                    _StatTile(
                      icon: Icons.trending_down,
                      label: 'Avg Hourly Rate',
                      value: '${summary.avgHourlyDisables.toStringAsFixed(1)}',
                      color: const Color(0xFF00AA66),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Insights
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (summary.highRiskHour != null)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'High-risk hour: ${summary.highRiskHour}:00',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                if (summary.highRiskApp != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.apps,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Most tempting: ${summary.highRiskApp}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Message
          if (summary.encouragementMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.encouragementMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
            ),
          ),
        ],
      ),
    );
  }
}
