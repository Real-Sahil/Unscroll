import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import 'package:unscroll/features/profile/providers/profile_provider.dart';
import '../widgets/recovery_status_card.dart';
import '../widgets/achievements_preview.dart';
import '../widgets/stats_grid.dart';
import '../widgets/streak_card.dart';
import '../widgets/premium_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final stats = ref.watch(userStatsProvider);

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No profile data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete onboarding to set up your profile',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Achievements'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profile.profileImageUrl != null
                        ? NetworkImage(profile.profileImageUrl!)
                        : null,
                    child: profile.profileImageUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFF8C00),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.totalPoints} points',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Premium status
            if (profile.isPremium)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PremiumCard(profile: profile),
              ),

            const SizedBox(height: 16),

            // Recovery status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RecoveryStatusCard(profile: profile),
            ),

            const SizedBox(height: 16),

            // Streaks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreakCard(
                currentStreak: profile.currentStreak,
                longestStreak: profile.longestStreak,
              ),
            ),

            const SizedBox(height: 16),

            // Stats grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StatsGrid(stats: stats),
            ),

            const SizedBox(height: 24),

            // Achievements section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Achievements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all achievements
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AchievementsPreview(profile: profile),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
