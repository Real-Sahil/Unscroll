import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final int frictionLevel; // 1-3
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool dailySummaryEmail;
  final bool partnerNotifications;
  final String? partnerId;
  final List<String> blockedApps; // instagram, youtube, tiktok
  final bool allowBypass; // Allow friction-based disable
  final int bypassCooldownHours;

  AppSettings({
    this.frictionLevel = 2,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.dailySummaryEmail = true,
    this.partnerNotifications = false,
    this.partnerId,
    this.blockedApps = const ['instagram', 'youtube', 'tiktok'],
    this.allowBypass = true,
    this.bypassCooldownHours = 24,
  });

  AppSettings copyWith({
    int? frictionLevel,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? dailySummaryEmail,
    bool? partnerNotifications,
    String? partnerId,
    List<String>? blockedApps,
    bool? allowBypass,
    int? bypassCooldownHours,
  }) {
    return AppSettings(
      frictionLevel: frictionLevel ?? this.frictionLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      dailySummaryEmail: dailySummaryEmail ?? this.dailySummaryEmail,
      partnerNotifications: partnerNotifications ?? this.partnerNotifications,
      partnerId: partnerId ?? this.partnerId,
      blockedApps: blockedApps ?? this.blockedApps,
      allowBypass: allowBypass ?? this.allowBypass,
      bypassCooldownHours: bypassCooldownHours ?? this.bypassCooldownHours,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings());

  void setFrictionLevel(int level) {
    if (level >= 1 && level <= 3) {
      state = state.copyWith(frictionLevel: level);
    }
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void toggleDarkMode(bool enabled) {
    state = state.copyWith(darkModeEnabled: enabled);
  }

  void toggleDailySummary(bool enabled) {
    state = state.copyWith(dailySummaryEmail: enabled);
  }

  void togglePartnerNotifications(bool enabled) {
    state = state.copyWith(partnerNotifications: enabled);
  }

  void setPartnerId(String? partnerId) {
    state = state.copyWith(partnerId: partnerId);
  }

  void toggleBlockedApp(String app) {
    final apps = List<String>.from(state.blockedApps);
    if (apps.contains(app)) {
      apps.remove(app);
    } else {
      apps.add(app);
    }
    state = state.copyWith(blockedApps: apps);
  }

  void setAllowBypass(bool allow) {
    state = state.copyWith(allowBypass: allow);
  }

  void setBypassCooldown(int hours) {
    state = state.copyWith(bypassCooldownHours: hours);
  }

  void resetToDefaults() {
    state = AppSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
