import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import 'package:unscroll/config/constants.dart';
import '../providers/home_provider.dart';
import '../widgets/focus_mode_card.dart';
import '../widgets/panic_button.dart';
import '../widgets/daily_stats_card.dart';
import '../widgets/quick_actions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStats = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('${AppConstants.appName}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Focus Mode Status
              FocusModeCard(
                isActive: homeStats.focusModeActive,
                onToggle: (value) {
                  ref.read(homeProvider.notifier).toggleFocusMode(value);
                },
              ),
              const SizedBox(height: 24),

              // Panic Button
              PanicButton(
                onPressed: () {
                  ref.read(homeProvider.notifier).incrementPanicButton();
                  _showPanicConfirmation(context);
                },
              ),
              const SizedBox(height: 24),

              // Daily Stats
              DailyStatsCard(
                stats: homeStats,
              ),
              const SizedBox(height: 24),

              // Quick Actions
              QuickActions(
                onPoliciesTap: () => Navigator.pushNamed(context, '/policies'),
                onRelapseLogTap: () => Navigator.pushNamed(context, '/relapse-log'),
                onAccountabilityTap: () => Navigator.pushNamed(context, '/accountability'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPanicConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🛡️ Protection Locked'),
        content: const Text(
          'All protection features have been activated. You cannot disable them for 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
