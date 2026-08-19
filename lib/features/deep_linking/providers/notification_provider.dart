import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/deep_linking/models/deep_link_models.dart';

class NotificationHistoryNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationHistoryNotifier() : super([]);

  void addNotification(NotificationModel notification) {
    state = [notification, ...state];
  }

  void markAsRead(String notificationId) {
    state = state.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void removeNotification(String notificationId) {
    state = state.where((n) => n.id != notificationId).toList();
  }

  void clearAll() {
    state = [];
  }

  List<NotificationModel> getUnread() {
    return state.where((n) => !n.isRead).toList();
  }

  List<NotificationModel> getByType(NotificationType type) {
    return state.where((n) => n.type == type).toList();
  }

  List<NotificationModel> getPriority() {
    return state.where((n) => n.isPriority).toList();
  }

  int getUnreadCount() {
    return state.where((n) => !n.isRead).length;
  }
}

class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(const NotificationPreferences.defaults());

  void updatePreferences(NotificationPreferences prefs) {
    state = prefs;
  }

  void togglePushNotifications() {
    state = state.copyWith(enablePushNotifications: !state.enablePushNotifications);
  }

  void toggleEmailSummaries() {
    state = state.copyWith(enableEmailSummaries: !state.enableEmailSummaries);
  }

  void toggleRiskAlerts() {
    state = state.copyWith(enableRiskAlerts: !state.enableRiskAlerts);
  }

  void toggleDailyReminders() {
    state = state.copyWith(enableDailyReminders: !state.enableDailyReminders);
  }

  void toggleWeeklyReview() {
    state = state.copyWith(enableWeeklyReview: !state.enableWeeklyReview);
  }

  void setQuietHours(int? start, int? end) {
    state = state.copyWith(quietHourStart: start, quietHourEnd: end);
  }

  void disableNotificationType(String type) {
    final disabled = [...state.disabledNotificationTypes];
    if (!disabled.contains(type)) {
      disabled.add(type);
    }
    state = state.copyWith(disabledNotificationTypes: disabled);
  }

  void enableNotificationType(String type) {
    final disabled = state.disabledNotificationTypes.where((t) => t != type).toList();
    state = state.copyWith(disabledNotificationTypes: disabled);
  }

  void resetToDefaults() {
    state = const NotificationPreferences.defaults();
  }
}

class ScheduledNotificationNotifier extends StateNotifier<List<NotificationModel>> {
  ScheduledNotificationNotifier() : super([]);

  void scheduleNotification(NotificationModel notification) {
    if (!notification.isScheduled) {
      throw ArgumentError('Notification must have a scheduledFor time');
    }
    state = [...state, notification];
  }

  void cancelScheduled(String notificationId) {
    state = state.where((n) => n.id != notificationId).toList();
  }

  void cancelAll() {
    state = [];
  }

  List<NotificationModel> getPendingNotifications() {
    return state.where((n) => !n.canBeSent).toList();
  }

  List<NotificationModel> getReadyToSend() {
    return state.where((n) => n.canBeSent).toList();
  }

  int getPendingCount() {
    return getPendingNotifications().length;
  }
}

final notificationHistoryProvider =
    StateNotifierProvider<NotificationHistoryNotifier, List<NotificationModel>>((ref) {
  return NotificationHistoryNotifier();
});

final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

final scheduledNotificationsProvider =
    StateNotifierProvider<ScheduledNotificationNotifier, List<NotificationModel>>((ref) {
  return ScheduledNotificationNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationHistoryProvider);
  return notifications.where((n) => !n.isRead).length;
});

final priorityNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationHistoryProvider);
  return notifications.where((n) => n.isPriority && !n.isRead).toList();
});

final notificationsSummaryProvider = Provider<({
  int unread,
  int total,
  int pending,
  List<NotificationModel> priority,
})>((ref) {
  final history = ref.watch(notificationHistoryProvider);
  final scheduled = ref.watch(scheduledNotificationsProvider);
  final unread = history.where((n) => !n.isRead).length;
  final priority = history.where((n) => n.isPriority && !n.isRead).toList();

  return (
    unread: unread,
    total: history.length,
    pending: scheduled.length,
    priority: priority,
  );
});
