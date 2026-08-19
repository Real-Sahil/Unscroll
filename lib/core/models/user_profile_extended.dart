class UserProfileExtended {
  final String id;
  final String email;
  final String? displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final int totalPoints;
  final List<String> unlockedAchievementIds;
  final int totalDaysProtected;
  final int currentStreak;
  final int longestStreak;
  final int totalFocusTimeMinutes;
  final String? recoveryGoal;
  final DateTime? recoveryStartDate;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final bool notificationsEnabled;
  final String preferredLanguage;
  final String? timezone;
  final Map<String, dynamic>? preferences;

  UserProfileExtended({
    required this.id,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    required this.createdAt,
    this.lastActiveAt,
    this.totalPoints = 0,
    this.unlockedAchievementIds = const [],
    this.totalDaysProtected = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalFocusTimeMinutes = 0,
    this.recoveryGoal,
    this.recoveryStartDate,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.notificationsEnabled = true,
    this.preferredLanguage = 'en',
    this.timezone,
    this.preferences,
  });

  bool get isPremiumActive =>
      isPremium && (premiumExpiresAt?.isAfter(DateTime.now()) ?? false);

  int get daysUntilPremiumExpires {
    if (!isPremium || premiumExpiresAt == null) return 0;
    return premiumExpiresAt!.difference(DateTime.now()).inDays;
  }

  Duration get recoverySince {
    if (recoveryStartDate == null) return Duration.zero;
    return DateTime.now().difference(recoveryStartDate!);
  }

  String getRecoveryStatus() {
    if (recoveryStartDate == null) return 'Not started';
    final days = recoverySince.inDays;
    if (days < 1) return 'Just started!';
    if (days < 7) return '$days day${days > 1 ? 's' : ''} strong';
    if (days < 30) return '${(days / 7).floor()} weeks in';
    if (days < 365) return '${(days / 30).floor()} months in';
    return '${(days / 365).floor()} year${(days / 365).floor() > 1 ? 's' : ''} strong';
  }

  UserProfileExtended copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? totalPoints,
    List<String>? unlockedAchievementIds,
    int? totalDaysProtected,
    int? currentStreak,
    int? longestStreak,
    int? totalFocusTimeMinutes,
    String? recoveryGoal,
    DateTime? recoveryStartDate,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    bool? notificationsEnabled,
    String? preferredLanguage,
    String? timezone,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfileExtended(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalPoints: totalPoints ?? this.totalPoints,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      totalDaysProtected: totalDaysProtected ?? this.totalDaysProtected,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalFocusTimeMinutes: totalFocusTimeMinutes ?? this.totalFocusTimeMinutes,
      recoveryGoal: recoveryGoal ?? this.recoveryGoal,
      recoveryStartDate: recoveryStartDate ?? this.recoveryStartDate,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      preferences: preferences ?? this.preferences,
    );
  }
}
