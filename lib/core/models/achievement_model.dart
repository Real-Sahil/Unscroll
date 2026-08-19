enum AchievementCategory {
  milestone, // X days protected
  streak,    // Consecutive days
  behavior,  // Behavioral change
  social,    // Social/accountability
  custom,    // User-defined
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int pointsReward;
  final DateTime? unlockedAt;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.pointsReward = 10,
    this.unlockedAt,
    this.metadata,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement unlock() {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      pointsReward: pointsReward,
      unlockedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    AchievementCategory? category,
    int? pointsReward,
    DateTime? unlockedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      pointsReward: pointsReward ?? this.pointsReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AchievementProgress {
  final String achievementId;
  final int currentProgress;
  final int targetProgress;
  final double get percentComplete => currentProgress / targetProgress;

  AchievementProgress({
    required this.achievementId,
    required this.currentProgress,
    required this.targetProgress,
  });

  bool get isComplete => currentProgress >= targetProgress;
}

class PredefinedAchievements {
  static final List<Achievement> all = [
    // Milestone achievements
    Achievement(
      id: 'first_day',
      name: '🌟 First Day',
      description: 'Complete your first day of protection',
      icon: '✨',
      category: AchievementCategory.milestone,
      pointsReward: 10,
    ),
    Achievement(
      id: 'week_protected',
      name: '📊 Week Strong',
      description: 'Protect for 7 consecutive days',
      icon: '📈',
      category: AchievementCategory.milestone,
      pointsReward: 50,
    ),
    Achievement(
      id: 'month_protected',
      name: '🎯 Month Challenge',
      description: 'Protect for 30 consecutive days',
      icon: '🎯',
      category: AchievementCategory.milestone,
      pointsReward: 100,
    ),
    Achievement(
      id: 'hundred_days',
      name: '💯 Century',
      description: 'Reach 100 days of protection',
      icon: '💯',
      category: AchievementCategory.milestone,
      pointsReward: 250,
    ),

    // Streak achievements
    Achievement(
      id: 'no_disables_week',
      name: '🛡️ Unbreakable',
      description: 'Full week with zero disable attempts',
      icon: '🛡️',
      category: AchievementCategory.streak,
      pointsReward: 75,
    ),
    Achievement(
      id: 'panic_hero',
      name: '🚨 Crisis Manager',
      description: 'Use panic button 3 times (getting help when needed)',
      icon: '🚨',
      category: AchievementCategory.streak,
      pointsReward: 40,
    ),

    // Behavioral achievements
    Achievement(
      id: 'friction_master',
      name: '🧠 Willpower',
      description: 'Complete friction challenges 50 times',
      icon: '🧠',
      category: AchievementCategory.behavior,
      pointsReward: 60,
    ),
    Achievement(
      id: 'time_saver',
      name: '⏰ Time Saved',
      description: 'Prevent 10 hours of doomscrolling',
      icon: '⏰',
      category: AchievementCategory.behavior,
      pointsReward: 80,
    ),

    // Social achievements
    Achievement(
      id: 'accountability_partner',
      name: '👥 Connected',
      description: 'Add an accountability partner',
      icon: '👥',
      category: AchievementCategory.social,
      pointsReward: 30,
    ),
    Achievement(
      id: 'family_protector',
      name: '👨‍👩‍👧‍👦 Family Shield',
      description: 'Set up family protection for a child',
      icon: '👨‍👩‍👧‍👦',
      category: AchievementCategory.social,
      pointsReward: 70,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }
}
