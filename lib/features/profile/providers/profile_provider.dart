import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/core/models/user_profile_extended.dart';
import 'package:unscroll/core/models/achievement_model.dart';

class ProfileNotifier extends StateNotifier<UserProfileExtended?> {
  ProfileNotifier() : super(null);

  /// Initialize user profile
  void initializeProfile(UserProfileExtended profile) {
    state = profile;
  }

  /// Update profile display info
  void updateProfile({
    String? displayName,
    String? profileImageUrl,
    String? recoveryGoal,
    bool? notificationsEnabled,
    String? preferredLanguage,
    String? timezone,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      recoveryGoal: recoveryGoal,
      notificationsEnabled: notificationsEnabled,
      preferredLanguage: preferredLanguage,
      timezone: timezone,
    );
  }

  /// Add achievement
  void unlockAchievement(String achievementId) {
    if (state == null) return;
    final achievement = PredefinedAchievements.getById(achievementId);
    if (achievement == null) return;

    if (state!.unlockedAchievementIds.contains(achievementId)) return;

    final newAchievements = [...state!.unlockedAchievementIds, achievementId];
    state = state!.copyWith(
      unlockedAchievementIds: newAchievements,
      totalPoints: state!.totalPoints + achievement.pointsReward,
    );
  }

  /// Update streak
  void updateStreak(int current, int longest) {
    if (state == null) return;
    state = state!.copyWith(
      currentStreak: current,
      longestStreak: longest,
    );
  }

  /// Add protected days
  void addProtectedDay() {
    if (state == null) return;
    state = state!.copyWith(
      totalDaysProtected: state!.totalDaysProtected + 1,
    );
  }

  /// Add focus time
  void addFocusTime(int minutes) {
    if (state == null) return;
    state = state!.copyWith(
      totalFocusTimeMinutes: state!.totalFocusTimeMinutes + minutes,
    );
  }

  /// Update last active
  void updateLastActive() {
    if (state == null) return;
    state = state!.copyWith(lastActiveAt: DateTime.now());
  }

  /// Set recovery start date
  void setRecoveryStart(DateTime date) {
    if (state == null) return;
    state = state!.copyWith(recoveryStartDate: date);
  }

  /// Upgrade to premium
  void upgradeToPremium(DateTime expiresAt) {
    if (state == null) return;
    state = state!.copyWith(
      isPremium: true,
      premiumExpiresAt: expiresAt,
    );
  }

  /// Clear profile (logout)
  void clearProfile() {
    state = null;
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfileExtended?>((ref) {
  return ProfileNotifier();
});

/// Provider for user achievements
final userAchievementsProvider = Provider((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) return <Achievement>[];

  return profile.unlockedAchievementIds
      .map((id) => PredefinedAchievements.getById(id))
      .whereType<Achievement>()
      .toList();
});

/// Provider for achievement progress
final achievementProgressProvider = Provider((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) return <AchievementProgress>[];

  final progressList = <AchievementProgress>[];

  // Calculate progress for milestone achievements
  progressList.add(AchievementProgress(
    achievementId: 'first_day',
    currentProgress: profile.totalDaysProtected > 0 ? 1 : 0,
    targetProgress: 1,
  ));

  progressList.add(AchievementProgress(
    achievementId: 'week_protected',
    currentProgress: profile.currentStreak,
    targetProgress: 7,
  ));

  progressList.add(AchievementProgress(
    achievementId: 'month_protected',
    currentProgress: profile.currentStreak,
    targetProgress: 30,
  ));

  progressList.add(AchievementProgress(
    achievementId: 'hundred_days',
    currentProgress: profile.totalDaysProtected,
    targetProgress: 100,
  ));

  return progressList;
});

/// Provider for user stats
final userStatsProvider = Provider((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) {
    return {
      'totalDays': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'totalPoints': 0,
      'focusHours': 0,
      'recoveryStatus': 'Not started',
    };
  }

  return {
    'totalDays': profile.totalDaysProtected,
    'currentStreak': profile.currentStreak,
    'longestStreak': profile.longestStreak,
    'totalPoints': profile.totalPoints,
    'focusHours': (profile.totalFocusTimeMinutes / 60).toStringAsFixed(1),
    'recoveryStatus': profile.getRecoveryStatus(),
  };
});
