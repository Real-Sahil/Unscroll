import 'package:flutter/foundation.dart';

@immutable
class DeepLinkData {
  final String route;
  final Map<String, String> parameters;
  final String? action;
  final DateTime? timestamp;

  const DeepLinkData({
    required this.route,
    required this.parameters,
    this.action,
    this.timestamp,
  });

  DeepLinkData copyWith({
    String? route,
    Map<String, String>? parameters,
    String? action,
    DateTime? timestamp,
  }) {
    return DeepLinkData(
      route: route ?? this.route,
      parameters: parameters ?? this.parameters,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  String get deepLinkUrl => 'unscroll://$route?${_paramsToString()}';

  String _paramsToString() {
    return parameters.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}

enum NotificationType {
  disableCooldown,
  panicCooldown,
  dailyGoal,
  weeklyReview,
  partnerUpdate,
  friendlyReminder,
  riskAlert,
  achievement,
  custom,
}

@immutable
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DeepLinkData? deepLink;
  final Map<String, String> metadata;
  final bool isRead;
  final bool isPriority;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.scheduledFor,
    this.deepLink,
    required this.metadata,
    required this.isRead,
    required this.isPriority,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DeepLinkData? deepLink,
    Map<String, String>? metadata,
    bool? isRead,
    bool? isPriority,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      deepLink: deepLink ?? this.deepLink,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      isPriority: isPriority ?? this.isPriority,
    );
  }

  bool get isScheduled => scheduledFor != null;

  bool get canBeSent => !isScheduled || (scheduledFor!.isBefore(DateTime.now()));

  String getTypeLabel() {
    switch (type) {
      case NotificationType.disableCooldown:
        return 'Disable Cooldown';
      case NotificationType.panicCooldown:
        return 'Panic Cooldown';
      case NotificationType.dailyGoal:
        return 'Daily Goal';
      case NotificationType.weeklyReview:
        return 'Weekly Review';
      case NotificationType.partnerUpdate:
        return 'Partner Update';
      case NotificationType.friendlyReminder:
        return 'Reminder';
      case NotificationType.riskAlert:
        return 'Risk Alert';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.custom:
        return 'Notification';
    }
  }
}

@immutable
class NotificationPreferences {
  final bool enablePushNotifications;
  final bool enableEmailSummaries;
  final bool enableRiskAlerts;
  final bool enableDailyReminders;
  final bool enableWeeklyReview;
  final int? quietHourStart; // 24-hour format
  final int? quietHourEnd; // 24-hour format
  final List<String> disabledNotificationTypes;

  const NotificationPreferences({
    required this.enablePushNotifications,
    required this.enableEmailSummaries,
    required this.enableRiskAlerts,
    required this.enableDailyReminders,
    required this.enableWeeklyReview,
    this.quietHourStart,
    this.quietHourEnd,
    required this.disabledNotificationTypes,
  });

  const NotificationPreferences.defaults()
      : enablePushNotifications = true,
        enableEmailSummaries = false,
        enableRiskAlerts = true,
        enableDailyReminders = true,
        enableWeeklyReview = true,
        quietHourStart = 22,
        quietHourEnd = 8,
        disabledNotificationTypes = const [];

  NotificationPreferences copyWith({
    bool? enablePushNotifications,
    bool? enableEmailSummaries,
    bool? enableRiskAlerts,
    bool? enableDailyReminders,
    bool? enableWeeklyReview,
    int? quietHourStart,
    int? quietHourEnd,
    List<String>? disabledNotificationTypes,
  }) {
    return NotificationPreferences(
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableEmailSummaries: enableEmailSummaries ?? this.enableEmailSummaries,
      enableRiskAlerts: enableRiskAlerts ?? this.enableRiskAlerts,
      enableDailyReminders: enableDailyReminders ?? this.enableDailyReminders,
      enableWeeklyReview: enableWeeklyReview ?? this.enableWeeklyReview,
      quietHourStart: quietHourStart ?? this.quietHourStart,
      quietHourEnd: quietHourEnd ?? this.quietHourEnd,
      disabledNotificationTypes: disabledNotificationTypes ?? this.disabledNotificationTypes,
    );
  }

  bool isInQuietHours(DateTime time) {
    if (quietHourStart == null || quietHourEnd == null) return false;
    if (quietHourStart! < quietHourEnd!) {
      return time.hour >= quietHourStart! && time.hour < quietHourEnd!;
    } else {
      return time.hour >= quietHourStart! || time.hour < quietHourEnd!;
    }
  }

  bool shouldShow(NotificationModel notification) {
    if (!enablePushNotifications) return false;
    if (disabledNotificationTypes.contains(notification.getTypeLabel())) return false;
    return true;
  }
}
