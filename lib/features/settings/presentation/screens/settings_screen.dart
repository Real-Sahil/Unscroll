import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import '../../../settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Protection Settings Section
              _SettingsSection(
                title: 'Protection',
                children: [
                  _SettingsTile(
                    title: 'Friction Level',
                    subtitle: 'Higher = more difficult to disable',
                    trailing: DropdownButton<int>(
                      value: settings.frictionLevel,
                      items: [1, 2, 3].map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text('Level $level'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          notifier.setFrictionLevel(value);
                        }
                      },
                    ),
                  ),
                  _SettingsTile(
                    title: 'Allow Disable',
                    subtitle: 'Prevent any disabling of protection',
                    trailing: Switch(
                      value: settings.allowBypass,
                      onChanged: notifier.setAllowBypass,
                    ),
                  ),
                  _SettingsTile(
                    title: 'Bypass Cooldown',
                    subtitle: '${settings.bypassCooldownHours} hours',
                    trailing: DropdownButton<int>(
                      value: settings.bypassCooldownHours,
                      items: [2, 6, 12, 24].map((hours) {
                        return DropdownMenuItem(
                          value: hours,
                          child: Text('$hours h'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          notifier.setBypassCooldown(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Blocked Apps Section
              _SettingsSection(
                title: 'Blocked Apps',
                children: [
                  _AppToggleTile(
                    appName: 'Instagram',
                    isBlocked: settings.blockedApps.contains('instagram'),
                    icon: Icons.photo_library_outlined,
                    onToggle: () => notifier.toggleBlockedApp('instagram'),
                  ),
                  _AppToggleTile(
                    appName: 'YouTube',
                    isBlocked: settings.blockedApps.contains('youtube'),
                    icon: Icons.play_circle_outline,
                    onToggle: () => notifier.toggleBlockedApp('youtube'),
                  ),
                  _AppToggleTile(
                    appName: 'TikTok',
                    isBlocked: settings.blockedApps.contains('tiktok'),
                    icon: Icons.music_note_outlined,
                    onToggle: () => notifier.toggleBlockedApp('tiktok'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _SettingsSection(
                title: 'Notifications',
                children: [
                  _SettingsTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive blocking & reminder alerts',
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: notifier.toggleNotifications,
                    ),
                  ),
                  _SettingsTile(
                    title: 'Daily Summary Email',
                    subtitle: 'Get daily stats in your inbox',
                    trailing: Switch(
                      value: settings.dailySummaryEmail,
                      onChanged: notifier.toggleDailySummary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Appearance Section
              _SettingsSection(
                title: 'Appearance',
                children: [
                  _SettingsTile(
                    title: 'Dark Mode',
                    subtitle: 'Easier on the eyes at night',
                    trailing: Switch(
                      value: settings.darkModeEnabled,
                      onChanged: notifier.toggleDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Accountability Section
              _SettingsSection(
                title: 'Accountability',
                children: [
                  _SettingsTile(
                    title: 'Partner Notifications',
                    subtitle: 'Share weekly progress with partner',
                    trailing: Switch(
                      value: settings.partnerNotifications,
                      onChanged: notifier.togglePartnerNotifications,
                    ),
                  ),
                  if (settings.partnerId != null)
                    _SettingsTile(
                      title: 'Connected Partner',
                      subtitle: settings.partnerId!,
                      onTap: () {
                        // TODO: Show partner details/disconnect option
                      },
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Open accountability partner invite
                      },
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Invite Partner'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Account Section
              _SettingsSection(
                title: 'Account',
                children: [
                  _SettingsTile(
                    title: 'Change Password',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to change password
                    },
                  ),
                  _SettingsTile(
                    title: 'Export Data',
                    subtitle: 'Download all your data',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Export data flow
                    },
                  ),
                  _SettingsTile(
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your data',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    isDestructive: true,
                    onTap: () {
                      // TODO: Show delete confirmation
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset to Defaults?'),
                        content: const Text(
                          'This will reset all settings to their default values.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              notifier.resetToDefaults();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Settings reset to defaults'),
                                ),
                              );
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Reset to Defaults'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    const Divider(height: 0, thickness: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _AppToggleTile extends StatelessWidget {
  final String appName;
  final bool isBlocked;
  final IconData icon;
  final VoidCallback onToggle;

  const _AppToggleTile({
    required this.appName,
    required this.isBlocked,
    required this.icon,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(appName),
      subtitle: Text(
        isBlocked ? 'Currently blocked' : 'Not blocked',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isBlocked ? AppColors.secondary : AppColors.textSecondary,
            ),
      ),
      trailing: Switch(
        value: isBlocked,
        onChanged: (_) => onToggle(),
      ),
    );
  }
}
