import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

enum NotificationType {
  reminder,
  protectionDisabled,
  partnerUpdate,
  dailySummary,
  achievementUnlocked,
  urgeSurf,
}

class NotificationPayload {
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, String>? data;
  final DateTime? scheduledTime;

  NotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.scheduledTime,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  /// Initialize notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
    return true;
  }

  /// Show immediate notification
  Future<void> showNotification(NotificationPayload payload) async {
    if (!_isInitialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      _getChannelId(payload.type),
      _getChannelName(payload.type),
      channelDescription: _getChannelDescription(payload.type),
      importance: _getImportance(payload.type),
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      payload.type.index,
      payload.title,
      payload.body,
      notificationDetails,
      payload: payload.data != null ? _encodePayload(payload.data!) : null,
    );
  }

  /// Schedule notification for later
  Future<void> scheduleNotification(NotificationPayload payload) async {
    if (!_isInitialized) await initialize();
    if (payload.scheduledTime == null) return;

    final androidDetails = AndroidNotificationDetails(
      _getChannelId(payload.type),
      _getChannelName(payload.type),
      channelDescription: _getChannelDescription(payload.type),
      importance: _getImportance(payload.type),
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      payload.type.index,
      payload.title,
      payload.body,
      tz.TZDateTime.from(
        payload.scheduledTime!,
        tz.local,
      ),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAndAlarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload.data != null ? _encodePayload(payload.data!) : null,
    );
  }

  /// Cancel notification by type
  Future<void> cancelNotification(NotificationType type) async {
    await _flutterLocalNotificationsPlugin.cancel(type.index);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get channel ID for notification type
  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return 'reminder_channel';
      case NotificationType.protectionDisabled:
        return 'protection_channel';
      case NotificationType.partnerUpdate:
        return 'partner_channel';
      case NotificationType.dailySummary:
        return 'summary_channel';
      case NotificationType.achievementUnlocked:
        return 'achievement_channel';
      case NotificationType.urgeSurf:
        return 'urge_channel';
    }
  }

  /// Get channel name
  String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return 'Reminders';
      case NotificationType.protectionDisabled:
        return 'Protection Alerts';
      case NotificationType.partnerUpdate:
        return 'Partner Updates';
      case NotificationType.dailySummary:
        return 'Daily Summary';
      case NotificationType.achievementUnlocked:
        return 'Achievements';
      case NotificationType.urgeSurf:
        return 'Urge Support';
    }
  }

  /// Get channel description
  String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.reminder:
        return 'Reminders and check-ins';
      case NotificationType.protectionDisabled:
        return 'Alerts when protection is disabled';
      case NotificationType.partnerUpdate:
        return 'Updates from accountability partner';
      case NotificationType.dailySummary:
        return 'Your daily usage summary';
      case NotificationType.achievementUnlocked:
        return 'Achievement and milestone notifications';
      case NotificationType.urgeSurf:
        return 'Support during difficult moments';
    }
  }

  /// Get importance level
  Importance _getImportance(NotificationType type) {
    switch (type) {
      case NotificationType.protectionDisabled:
      case NotificationType.urgeSurf:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  /// Handle notification response
  void _onNotificationResponse(NotificationResponse response) {
    // TODO: Handle notification tap
    // Route to appropriate screen based on payload
  }

  /// Encode payload to string
  String _encodePayload(Map<String, String> data) {
    return data.entries.map((e) => '${e.key}:${e.value}').join('|');
  }

  /// Decode payload from string
  Map<String, String> _decodePayload(String encoded) {
    final map = <String, String>{};
    for (final entry in encoded.split('|')) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}

/// Pre-built notification templates
class NotificationTemplates {
  static NotificationPayload protectionDisabled() {
    return NotificationPayload(
      type: NotificationType.protectionDisabled,
      title: '⚠️ Protection Disabled',
      body: 'You disabled protection. Re-enable in 24 hours.',
    );
  }

  static NotificationPayload dailySummary(int disables, int focusMinutes) {
    return NotificationPayload(
      type: NotificationType.dailySummary,
      title: '📊 Daily Summary',
      body:
          'Today: $disables disable attempts, $focusMinutes min saved. You\'re doing great!',
    );
  }

  static NotificationPayload partnerUpdate(String partnerName, String message) {
    return NotificationPayload(
      type: NotificationType.partnerUpdate,
      title: '👥 Message from $partnerName',
      body: message,
    );
  }

  static NotificationPayload urgeSurf() {
    return NotificationPayload(
      type: NotificationType.urgeSurf,
      title: '🌊 Ride the Wave',
      body: 'The urge will pass. Take a deep breath and wait it out.',
    );
  }

  static NotificationPayload achievementUnlocked(String achievement) {
    return NotificationPayload(
      type: NotificationType.achievementUnlocked,
      title: '🏆 Achievement Unlocked!',
      body: achievement,
    );
  }

  static NotificationPayload dailyReminder() {
    return NotificationPayload(
      type: NotificationType.reminder,
      title: '⏰ Time to Check In',
      body: 'How are you doing today? View your stats.',
    );
  }
}
