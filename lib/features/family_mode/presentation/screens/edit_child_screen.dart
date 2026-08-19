import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/family_mode/models/family_models.dart';
import 'package:unscroll/features/family_mode/providers/family_provider.dart';
import 'package:unscroll/features/policies/providers/policies_provider.dart';

class EditChildScreen extends ConsumerStatefulWidget {
  final String childId;
  final String childName;
  final String childEmail;

  const EditChildScreen({
    Key? key,
    required this.childId,
    required this.childName,
    required this.childEmail,
  }) : super(key: key);

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  late String _selectedPolicyId;
  late bool _canDisableProtection;
  late bool _canViewStats;
  late bool _canChangeSettings;
  late List<String> _restrictedApps;
  late int _childCooldownHours;
  late int _childPanicCooldownHours;

  @override
  void initState() {
    super.initState();
    _initializeFromPolicy();
  }

  void _initializeFromPolicy() {
    final policies = ref.read(policiesProvider);
    _selectedPolicyId = policies.isNotEmpty ? policies.first.id : '';

    final childPolicies = ref.read(childPoliciesProvider);
    final existingPolicy = childPolicies.firstWhere(
      (p) => p.childId == widget.childId,
      orElse: () => ChildPolicy(
        id: 'child_policy_${DateTime.now().millisecondsSinceEpoch}',
        childId: widget.childId,
        policyId: _selectedPolicyId,
        name: '${widget.childName}\'s Policy',
        canDisableProtection: false,
        canViewStats: true,
        canChangeSettings: false,
        restrictedApps: const ['instagram', 'youtube', 'tiktok'],
        cooldownAfterDisableHours: 24,
        panicCooldownHours: 12,
      ),
    );

    _selectedPolicyId = existingPolicy.policyId;
    _canDisableProtection = existingPolicy.canDisableProtection;
    _canViewStats = existingPolicy.canViewStats;
    _canChangeSettings = existingPolicy.canChangeSettings;
    _restrictedApps = List.from(existingPolicy.restrictedApps);
    _childCooldownHours = existingPolicy.cooldownAfterDisableHours;
    _childPanicCooldownHours = existingPolicy.panicCooldownHours;
  }

  void _saveChildPolicy() {
    final policy = ChildPolicy(
      id: 'child_policy_${DateTime.now().millisecondsSinceEpoch}',
      childId: widget.childId,
      policyId: _selectedPolicyId,
      name: '${widget.childName}\'s Custom Policy',
      canDisableProtection: _canDisableProtection,
      canViewStats: _canViewStats,
      canChangeSettings: _canChangeSettings,
      restrictedApps: _restrictedApps,
      cooldownAfterDisableHours: _childCooldownHours,
      panicCooldownHours: _childPanicCooldownHours,
    );

    ref.read(familyMembersProvider.notifier).updateChildPolicy(widget.childId, policy);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.childName}\'s policy updated')),
    );

    Navigator.pop(context, policy);
  }

  @override
  Widget build(BuildContext context) {
    final policies = ref.watch(policiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.childName}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.child_care,
                          color: Colors.blue[900],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.childName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            widget.childEmail,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Protection Policy Selection
            Text(
              'Protection Policy',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _selectedPolicyId.isNotEmpty ? _selectedPolicyId : null,
                isExpanded: true,
                underline: const SizedBox(),
                items: policies
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPolicyId = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // Child Permissions
            Text(
              'Child Permissions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              title: 'Can Disable Protection',
              subtitle: 'Child can turn off protection (not recommended)',
              value: _canDisableProtection,
              onChanged: (value) => setState(() => _canDisableProtection = value),
            ),
            _PermissionTile(
              title: 'Can View Statistics',
              subtitle: 'Child can see their relapse log and patterns',
              value: _canViewStats,
              onChanged: (value) => setState(() => _canViewStats = value),
            ),
            _PermissionTile(
              title: 'Can Change Settings',
              subtitle: 'Child can adjust their own app settings',
              value: _canChangeSettings,
              onChanged: (value) => setState(() => _canChangeSettings = value),
            ),
            const SizedBox(height: 24),

            // Restricted Apps
            Text(
              'Restricted Apps',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _AppRestrictionTile(
              app: 'Instagram',
              isRestricted: _restrictedApps.contains('instagram'),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _restrictedApps.add('instagram');
                  } else {
                    _restrictedApps.remove('instagram');
                  }
                });
              },
            ),
            _AppRestrictionTile(
              app: 'YouTube',
              isRestricted: _restrictedApps.contains('youtube'),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _restrictedApps.add('youtube');
                  } else {
                    _restrictedApps.remove('youtube');
                  }
                });
              },
            ),
            _AppRestrictionTile(
              app: 'TikTok',
              isRestricted: _restrictedApps.contains('tiktok'),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _restrictedApps.add('tiktok');
                  } else {
                    _restrictedApps.remove('tiktok');
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Custom Cooldown Periods
            Text(
              'Custom Cooldown Settings',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Disable Cooldown: $_childCooldownHours hours',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            Slider(
              value: _childCooldownHours.toDouble(),
              min: 1,
              max: 72,
              divisions: 71,
              onChanged: (value) {
                setState(() => _childCooldownHours = value.toInt());
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Panic Cooldown: $_childPanicCooldownHours hours',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            Slider(
              value: _childPanicCooldownHours.toDouble(),
              min: 1,
              max: 48,
              divisions: 47,
              onChanged: (value) {
                setState(() => _childPanicCooldownHours = value.toInt());
              },
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveChildPolicy,
                icon: const Icon(Icons.check),
                label: const Text('Save Policy'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: CheckboxListTile(
          title: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          value: value,
          onChanged: (val) => onChanged(val ?? false),
        ),
      ),
    );
  }
}

class _AppRestrictionTile extends StatelessWidget {
  final String app;
  final bool isRestricted;
  final ValueChanged<bool> onChanged;

  const _AppRestrictionTile({
    Key? key,
    required this.app,
    required this.isRestricted,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isRestricted ? const Color(0xFF00AA66).withOpacity(0.08) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isRestricted ? const Color(0xFF00AA66).withOpacity(0.3) : Colors.grey[200]!,
          ),
        ),
        child: CheckboxListTile(
          title: Text(app),
          subtitle: Text(
            isRestricted ? 'App is restricted for $app' : 'App is not restricted',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isRestricted ? const Color(0xFF00AA66) : Colors.grey[600],
                ),
          ),
          value: isRestricted,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
