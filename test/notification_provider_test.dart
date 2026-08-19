import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/features/deep_linking/models/deep_link_models.dart';
import 'package:unscroll/features/deep_linking/providers/notification_provider.dart';

void main() {
  group('NotificationPreferences', () {
    test('creates default preferences', () {
      final prefs = NotificationPreferences.defaults();

      expect(prefs.enablePushNotifications, true);
      expect(prefs.enableEmailSummaries, false);
      expect(prefs.enableRiskAlerts, true);
      expect(prefs.enableDailyReminders, true);
      expect(prefs.enableWeeklyReview, true);
      expect(prefs.quietHourStart, 22);
      expect(prefs.quietHourEnd, 8);
    });

    test('creates custom notification preferences', () {
      final prefs = NotificationPreferences(
        enablePushNotifications: false,
        enableEmailSummaries: true,
        enableRiskAlerts: false,
        enableDailyReminders: false,
        enableWeeklyReview: true,
        quietHourStart: 23,
        quietHourEnd: 7,
        disabledNotificationTypes: [],
      );

      expect(prefs.enablePushNotifications, false);
      expect(prefs.enableEmailSummaries, true);
      expect(prefs.enableRiskAlerts, false);
      expect(prefs.quietHourStart, 23);
    });

    test('copies with updates', () {
      final prefs = NotificationPreferences.defaults();
      final updated = prefs.copyWith(enableEmailSummaries: true);

      expect(prefs.enableEmailSummaries, false);
      expect(updated.enableEmailSummaries, true);
      expect(updated.enablePushNotifications, prefs.enablePushNotifications);
    });
  });

  group('NotificationModel', () {
    test('creates notification', () {
      final now = DateTime.now();
      final notification = NotificationModel(
        id: 'notif_1',
        title: 'Cooldown Active',
        body: 'You disabled protection. It will be available again in 24 hours.',
        type: NotificationType.disableCooldown,
        createdAt: now,
        scheduledFor: now,
        deepLink: 'unscroll://home',
        metadata: {'policyId': 'policy_1'},
        isRead: false,
        isPriority: true,
      );

      expect(notification.id, 'notif_1');
      expect(notification.type, NotificationType.disableCooldown);
      expect(notification.isRead, false);
      expect(notification.isPriority, true);
    });

    test('marks notification as read', () {
      final notification = NotificationModel(
        id: 'notif_1',
        title: 'Test',
        body: 'Test notification',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: false,
      );

      expect(notification.isRead, false);

      final updated = notification.copyWith(isRead: true);
      expect(updated.isRead, true);
    });

    test('stores metadata', () {
      final notification = NotificationModel(
        id: 'notif_1',
        title: 'Achievement',
        body: 'You reached 7-day streak!',
        type: NotificationType.achievement,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        metadata: {
          'streakDays': '7',
          'achievementId': 'ach_7day',
          'milestone': 'true',
        },
      );

      expect(notification.metadata['streakDays'], '7');
      expect(notification.metadata['achievementId'], 'ach_7day');
    });
  });

  group('NotificationType', () {
    test('all notification types are defined', () {
      final types = [
        NotificationType.disableCooldown,
        NotificationType.panicCooldown,
        NotificationType.dailyGoal,
        NotificationType.weeklyReview,
        NotificationType.partnerUpdate,
        NotificationType.friendlyReminder,
        NotificationType.riskAlert,
        NotificationType.achievement,
        NotificationType.custom,
      ];

      expect(types.length, 9);
    });

    test('maps notification type to string', () {
      final type = NotificationType.disableCooldown;
      final typeString = type.toString();

      expect(typeString, contains('disableCooldown'));
    });
  });

  group('NotificationHistoryNotifier', () {
    late NotificationHistoryNotifier historyNotifier;

    setUp(() {
      historyNotifier = NotificationHistoryNotifier();
    });

    test('initializes with empty history', () {
      expect(historyNotifier.state, isEmpty);
    });

    test('adds notification to history', () {
      final notification = NotificationModel(
        id: 'notif_1',
        title: 'Test',
        body: 'Test notification',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
      );

      historyNotifier.addNotification(notification);
      expect(historyNotifier.state.length, 1);
      expect(historyNotifier.state.first.id, 'notif_1');
    });

    test('marks notification as read', () {
      final notification = NotificationModel(
        id: 'notif_1',
        title: 'Test',
        body: 'Test notification',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: false,
      );

      historyNotifier.addNotification(notification);
      historyNotifier.markAsRead('notif_1');

      expect(historyNotifier.state.first.isRead, true);
    });

    test('marks all notifications as read', () {
      final notif1 = NotificationModel(
        id: 'notif_1',
        title: 'Test 1',
        body: 'Test notification 1',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: false,
      );

      final notif2 = NotificationModel(
        id: 'notif_2',
        title: 'Test 2',
        body: 'Test notification 2',
        type: NotificationType.riskAlert,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: false,
      );

      historyNotifier.addNotification(notif1);
      historyNotifier.addNotification(notif2);
      historyNotifier.markAllAsRead();

      expect(historyNotifier.state.every((n) => n.isRead), true);
    });

    test('removes notification', () {
      final notification = NotificationModel(
        id: 'notif_1',
        title: 'Test',
        body: 'Test notification',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
      );

      historyNotifier.addNotification(notification);
      expect(historyNotifier.state.length, 1);

      historyNotifier.removeNotification('notif_1');
      expect(historyNotifier.state, isEmpty);
    });

    test('clears all notifications', () {
      final notif1 = NotificationModel(
        id: 'notif_1',
        title: 'Test 1',
        body: 'Test notification 1',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
      );

      final notif2 = NotificationModel(
        id: 'notif_2',
        title: 'Test 2',
        body: 'Test notification 2',
        type: NotificationType.riskAlert,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
      );

      historyNotifier.addNotification(notif1);
      historyNotifier.addNotification(notif2);
      historyNotifier.clearAll();

      expect(historyNotifier.state, isEmpty);
    });

    test('gets unread notifications', () {
      final notif1 = NotificationModel(
        id: 'notif_1',
        title: 'Test 1',
        body: 'Test notification 1',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: false,
      );

      final notif2 = NotificationModel(
        id: 'notif_2',
        title: 'Test 2',
        body: 'Test notification 2',
        type: NotificationType.riskAlert,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: true,
      );

      historyNotifier.addNotification(notif1);
      historyNotifier.addNotification(notif2);

      final unread = historyNotifier.getUnread();
      expect(unread.length, 1);
      expect(unread.first.id, 'notif_1');
    });

    test('filters notifications by type', () {
      final notif1 = NotificationModel(
        id: 'notif_1',
        title: 'Test 1',
        body: 'Test notification 1',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
      );

      final notif2 = NotificationModel(
        id: 'notif_2',
        title: 'Test 2',
        body: 'Test notification 2',
        type: NotificationType.riskAlert,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
      );

      historyNotifier.addNotification(notif1);
      historyNotifier.addNotification(notif2);

      final riskAlerts = historyNotifier.getByType(NotificationType.riskAlert);
      expect(riskAlerts.length, 1);
      expect(riskAlerts.first.type, NotificationType.riskAlert);
    });

    test('gets priority notifications', () {
      final notif1 = NotificationModel(
        id: 'notif_1',
        title: 'Test 1',
        body: 'Test notification 1',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isPriority: false,
      );

      final notif2 = NotificationModel(
        id: 'notif_2',
        title: 'Test 2',
        body: 'Test notification 2',
        type: NotificationType.riskAlert,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isPriority: true,
      );

      historyNotifier.addNotification(notif1);
      historyNotifier.addNotification(notif2);

      final priority = historyNotifier.getPriority();
      expect(priority.length, 1);
      expect(priority.first.isPriority, true);
    });

    test('gets unread count', () {
      final notif1 = NotificationModel(
        id: 'notif_1',
        title: 'Test 1',
        body: 'Test notification 1',
        type: NotificationType.friendlyReminder,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: false,
      );

      final notif2 = NotificationModel(
        id: 'notif_2',
        title: 'Test 2',
        body: 'Test notification 2',
        type: NotificationType.riskAlert,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: false,
      );

      final notif3 = NotificationModel(
        id: 'notif_3',
        title: 'Test 3',
        body: 'Test notification 3',
        type: NotificationType.achievement,
        createdAt: DateTime.now(),
        scheduledFor: DateTime.now(),
        isRead: true,
      );

      historyNotifier.addNotification(notif1);
      historyNotifier.addNotification(notif2);
      historyNotifier.addNotification(notif3);

      final unreadCount = historyNotifier.getUnreadCount();
      expect(unreadCount, 2);
    });
  });

  group('NotificationPreferencesNotifier', () {
    late NotificationPreferencesNotifier preferencesNotifier;

    setUp(() {
      preferencesNotifier = NotificationPreferencesNotifier();
    });

    test('initializes with default preferences', () {
      expect(preferencesNotifier.state.enablePushNotifications, true);
      expect(preferencesNotifier.state.enableEmailSummaries, false);
    });

    test('updates push notification setting', () {
      preferencesNotifier.updatePreferences(
        preferencesNotifier.state.copyWith(enablePushNotifications: false),
      );

      expect(preferencesNotifier.state.enablePushNotifications, false);
    });

    test('toggles email summaries', () {
      final current = preferencesNotifier.state.enableEmailSummaries;
      preferencesNotifier.updatePreferences(
        preferencesNotifier.state.copyWith(enableEmailSummaries: !current),
      );

      expect(preferencesNotifier.state.enableEmailSummaries, !current);
    });

    test('sets quiet hours', () {
      preferencesNotifier.updatePreferences(
        preferencesNotifier.state.copyWith(
          quietHourStart: 23,
          quietHourEnd: 7,
        ),
      );

      expect(preferencesNotifier.state.quietHourStart, 23);
      expect(preferencesNotifier.state.quietHourEnd, 7);
    });

    test('disables notification type', () {
      final prefs = preferencesNotifier.state;
      preferencesNotifier.updatePreferences(
        prefs.copyWith(
          disabledNotificationTypes: [
            ...prefs.disabledNotificationTypes,
            NotificationType.dailyReminder,
          ],
        ),
      );

      expect(
        preferencesNotifier.state.disabledNotificationTypes
            .contains(NotificationType.dailyReminder),
        true,
      );
    });

    test('resets to defaults', () {
      preferencesNotifier.updatePreferences(
        preferencesNotifier.state.copyWith(
          enablePushNotifications: false,
          enableEmailSummaries: true,
          quietHourStart: 23,
        ),
      );

      preferencesNotifier.updatePreferences(NotificationPreferences.defaults());

      final defaults = NotificationPreferences.defaults();
      expect(preferencesNotifier.state.enablePushNotifications,
          defaults.enablePushNotifications);
      expect(
          preferencesNotifier.state.enableEmailSummaries,
          defaults.enableEmailSummaries);
      expect(preferencesNotifier.state.quietHourStart, defaults.quietHourStart);
    });
  });

  group('Notification Quiet Hours', () {
    test('identifies if time is in quiet hours (evening)', () {
      final prefs = NotificationPreferences(
        enablePushNotifications: true,
        enableEmailSummaries: false,
        enableRiskAlerts: true,
        enableDailyReminders: true,
        enableWeeklyReview: true,
        quietHourStart: 22,
        quietHourEnd: 8,
        disabledNotificationTypes: [],
      );

      final nightTime = DateTime(2024, 8, 15, 23, 0);
      final isInQuietHours = nightTime.hour >= prefs.quietHourStart ||
          nightTime.hour < prefs.quietHourEnd;

      expect(isInQuietHours, true);
    });

    test('identifies if time is outside quiet hours', () {
      final prefs = NotificationPreferences(
        enablePushNotifications: true,
        enableEmailSummaries: false,
        enableRiskAlerts: true,
        enableDailyReminders: true,
        enableWeeklyReview: true,
        quietHourStart: 22,
        quietHourEnd: 8,
        disabledNotificationTypes: [],
      );

      final dayTime = DateTime(2024, 8, 15, 14, 0);
      final isInQuietHours = dayTime.hour >= prefs.quietHourStart ||
          dayTime.hour < prefs.quietHourEnd;

      expect(isInQuietHours, false);
    });
  });
}
