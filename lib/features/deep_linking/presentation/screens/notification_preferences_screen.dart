import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/deep_linking/providers/notification_provider.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  late int? _quietHourStart;
  late int? _quietHourEnd;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(notificationPreferencesProvider);
    _quietHourStart = prefs.quietHourStart;
    _quietHourEnd = prefs.quietHourEnd;
  }

  void _saveQuietHours() {
    ref.read(notificationPreferencesProvider.notifier).setQuietHours(
          _quietHourStart,
          _quietHourEnd,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiet hours updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main toggles
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _PreferenceTile(
              title: 'Push Notifications',
              subtitle: 'Receive alerts on your device',
              value: prefs.enablePushNotifications,
              onChanged: (value) {
                ref
                    .read(notificationPreferencesProvider.notifier)
                    .togglePushNotifications();
              },
            ),
            _PreferenceTile(
              title: 'Email Summaries',
              subtitle: 'Weekly recovery summaries via email',
              value: prefs.enableEmailSummaries,
              onChanged: (value) {
                ref
                    .read(notificationPreferencesProvider.notifier)
                    .toggleEmailSummaries();
              },
            ),
            _PreferenceTile(
              title: 'Risk Alerts',
              subtitle: 'Get notified of high-risk patterns',
              value: prefs.enableRiskAlerts,
              onChanged: (value) {
                ref
                    .read(notificationPreferencesProvider.notifier)
                    .toggleRiskAlerts();
              },
            ),
            _PreferenceTile(
              title: 'Daily Reminders',
              subtitle: 'Morning and evening check-in reminders',
              value: prefs.enableDailyReminders,
              onChanged: (value) {
                ref
                    .read(notificationPreferencesProvider.notifier)
                    .toggleDailyReminders();
              },
            ),
            _PreferenceTile(
              title: 'Weekly Review',
              subtitle: 'Sunday summary of your week',
              value: prefs.enableWeeklyReview,
              onChanged: (value) {
                ref
                    .read(notificationPreferencesProvider.notifier)
                    .toggleWeeklyReview();
              },
            ),
            const SizedBox(height: 32),

            // Quiet hours
            Text(
              'Quiet Hours',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'No notifications will be sent during quiet hours',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Hour',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<int?>(
                          value: _quietHourStart,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Disabled'),
                            ),
                            ...List.generate(
                              24,
                              (index) => DropdownMenuItem(
                                value: index,
                                child: Text('${index.toString().padLeft(2, '0')}:00'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _quietHourStart = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Hour',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<int?>(
                          value: _quietHourEnd,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Disabled'),
                            ),
                            ...List.generate(
                              24,
                              (index) => DropdownMenuItem(
                                value: index,
                                child: Text('${index.toString().padLeft(2, '0')}:00'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _quietHourEnd = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveQuietHours,
                child: const Text('Save Quiet Hours'),
              ),
            ),
            const SizedBox(height: 32),

            // Notification history
            Text(
              'Notification History',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(notificationHistoryProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Mark All as Read'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text(
                        'Are you sure you want to clear all notification history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(notificationHistoryProvider.notifier).clearAll();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('History cleared')),
                          );
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear History'),
            ),
            const SizedBox(height: 32),

            // Reset button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset to Defaults',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Restore default notification settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(notificationPreferencesProvider.notifier)
                            .resetToDefaults();
                        setState(() {
                          _quietHourStart = 22;
                          _quietHourEnd = 8;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reset to defaults')),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
