import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/core/models/achievement_model.dart';
import 'package:unscroll/features/profile/providers/profile_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(userAchievementsProvider);
    final progress = ref.watch(achievementProgressProvider);
    final allAchievements = PredefinedAchievements.all;

    final unlockedCount = achievements.length;
    final totalCount = allAchievements.length;
    final totalPoints = achievements.fold<int>(0, (sum, a) => sum + a.pointsReward);

    final categories = {
      AchievementCategory.milestone: 'Milestones',
      AchievementCategory.streak: 'Streaks',
      AchievementCategory.behavior: 'Behaviors',
      AchievementCategory.social: 'Social',
      AchievementCategory.custom: 'Custom',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00AA66).withOpacity(0.1),
                      const Color(0xFF00D686).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00AA66).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$unlockedCount / $totalCount',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00AA66),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Points',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$totalPoints',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFF8C00),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: unlockedCount / totalCount,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Color(0xFF00AA66)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Achievements by category
            ...categories.entries.map((entry) {
              final category = entry.key;
              final categoryName = entry.value;
              final categoryAchievements =
                  allAchievements.where((a) => a.category == category).toList();

              if (categoryAchievements.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...categoryAchievements.map((achievement) {
                      final isUnlocked =
                          achievements.any((a) => a.id == achievement.id);
                      final achievementProgress = progress.firstWhere(
                        (p) => p.achievementId == achievement.id,
                        orElse: () => AchievementProgress(
                          achievementId: achievement.id,
                          currentProgress: 0,
                          targetProgress: 1,
                        ),
                      );

                      return AchievementCard(
                        achievement: achievement,
                        isUnlocked: isUnlocked,
                        progress: achievementProgress,
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final AchievementProgress progress;

  const AchievementCard({
    Key? key,
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.amber[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? Colors.amber[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.amber[100]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Stack(
                children: [
                  Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                  if (!isUnlocked)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!progress.isComplete)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.percentComplete,
                        minHeight: 4,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked
                              ? const Color(0xFF00AA66)
                              : Colors.grey[400]!,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFFF8C00),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${achievement.pointsReward}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!progress.isComplete)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${progress.currentProgress}/${progress.targetProgress}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
