import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/core/models/achievement_model.dart';
import 'package:unscroll/core/models/user_profile_extended.dart';
import 'package:unscroll/features/profile/providers/profile_provider.dart';

class AchievementsPreview extends ConsumerWidget {
  final UserProfileExtended profile;

  const AchievementsPreview({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(userAchievementsProvider);
    final allAchievements = PredefinedAchievements.all;

    final unlockedCount = achievements.length;
    final totalCount = allAchievements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Achievement progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: unlockedCount / totalCount,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00AA66)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$unlockedCount / $totalCount Unlocked',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Achievement grid (preview - first 6)
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: allAchievements.take(6).map((achievement) {
            final isUnlocked = achievements.any((a) => a.id == achievement.id);
            return AchievementTile(
              achievement: achievement,
              isUnlocked: isUnlocked,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementTile({
    Key? key,
    required this.achievement,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.amber[50]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? Colors.amber[300]!
              : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.name.split(' ').first,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isUnlocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          if (isUnlocked)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
