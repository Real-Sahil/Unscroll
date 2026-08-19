import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/policies/providers/policies_provider.dart';
import 'package:unscroll/core/models/policy.dart';

class PolicyEditorScreen extends ConsumerStatefulWidget {
  final String? policyId;

  const PolicyEditorScreen({
    Key? key,
    this.policyId,
  }) : super(key: key);

  @override
  ConsumerState<PolicyEditorScreen> createState() => _PolicyEditorScreenState();
}

class _PolicyEditorScreenState extends ConsumerState<PolicyEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  bool _instagramEnabled = true;
  bool _youtubeEnabled = true;
  bool _tiktokEnabled = true;

  String _startTime = '22:00';
  String _endTime = '07:00';

  List<String> _selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  bool _hardBlockEnabled = true;
  String _frictionLevel = 'hard';
  int _cooldownHours = 24;
  int _panicCooldownHours = 12;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Daily Protection');
    _descriptionController = TextEditingController(
        text: 'Block Reels during evening hours');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _savePolicy() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Policy name is required')),
      );
      return;
    }

    final rules = [
      if (_instagramEnabled)
        PolicyRule(
          id: 'rule_ig_${DateTime.now().millisecondsSinceEpoch}',
          policyId: widget.policyId ?? 'policy_new',
          app: 'instagram',
          blockReels: true,
          blockStories: true,
          disableAutoplay: true,
        ),
      if (_youtubeEnabled)
        PolicyRule(
          id: 'rule_yt_${DateTime.now().millisecondsSinceEpoch}',
          policyId: widget.policyId ?? 'policy_new',
          app: 'youtube',
          blockShorts: true,
          disableAutoplay: true,
        ),
      if (_tiktokEnabled)
        PolicyRule(
          id: 'rule_tt_${DateTime.now().millisecondsSinceEpoch}',
          policyId: widget.policyId ?? 'policy_new',
          app: 'tiktok',
          blockReels: true,
          disableAutoplay: true,
        ),
    ];

    final schedule = PolicySchedule(
      daysOfWeek: _selectedDays,
      startTime: _startTime,
      endTime: _endTime,
      action: 'block',
    );

    final policy = Policy(
      id: widget.policyId ?? 'policy_${DateTime.now().millisecondsSinceEpoch}',
      ownerProfileId: 'user_default',
      name: _nameController.text,
      mode: 'scheduled',
      schedules: [schedule],
      hardBlockEnabled: _hardBlockEnabled,
      cooldownAfterDisableHours: _cooldownHours,
      panicCooldownHours: _panicCooldownHours,
      frictionLevel: _frictionLevel,
      rules: rules,
      createdAt: DateTime.now(),
    );

    if (widget.policyId != null) {
      ref.read(policiesProvider.notifier).updatePolicy(widget.policyId!, policy);
    } else {
      ref.read(policiesProvider.notifier).addPolicy(policy);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.policyId != null ? 'Edit Policy' : 'Create Policy'),
        elevation: 0,
        actions: [
          if (widget.policyId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(policiesProvider.notifier).deletePolicy(widget.policyId!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Policy Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Time Window
            Text(
              'Time Window',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          Text(
                            _startTime,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          Text(
                            _endTime,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Days Selection
            Text(
              'Days of Week',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .asMap()
                  .entries
                  .map((e) {
                final dayNames = [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ];
                return FilterChip(
                  label: Text(e.value),
                  selected: _selectedDays.contains(dayNames[e.key]),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(dayNames[e.key]);
                      } else {
                        _selectedDays.remove(dayNames[e.key]);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Blocked Apps
            Text(
              'Blocked Apps',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Instagram'),
              subtitle: const Text('Reels & Stories'),
              value: _instagramEnabled,
              onChanged: (value) {
                setState(() => _instagramEnabled = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('YouTube'),
              subtitle: const Text('Shorts'),
              value: _youtubeEnabled,
              onChanged: (value) {
                setState(() => _youtubeEnabled = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('TikTok'),
              subtitle: const Text('Main feed'),
              value: _tiktokEnabled,
              onChanged: (value) {
                setState(() => _tiktokEnabled = value ?? false);
              },
            ),

            const SizedBox(height: 24),

            // Friction Level
            Text(
              'Protection Level',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            RadioListTile(
              title: const Text('Standard'),
              subtitle: const Text('PIN + confirmation'),
              value: 'standard',
              groupValue: _frictionLevel,
              onChanged: (value) {
                setState(() => _frictionLevel = value ?? 'hard');
              },
            ),
            RadioListTile(
              title: const Text('Hard'),
              subtitle: const Text('PIN + urge surf + breathing'),
              value: 'hard',
              groupValue: _frictionLevel,
              onChanged: (value) {
                setState(() => _frictionLevel = value ?? 'hard');
              },
            ),

            const SizedBox(height: 24),

            // Cooldown
            Text(
              'Cooldown Period (hours)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text('$_cooldownHours hours'),
            Slider(
              value: _cooldownHours.toDouble(),
              min: 1,
              max: 72,
              divisions: 71,
              onChanged: (value) {
                setState(() => _cooldownHours = value.toInt());
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savePolicy,
                icon: const Icon(Icons.check),
                label: Text(widget.policyId != null ? 'Update' : 'Create'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
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

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        if (isStart) {
          _startTime = '$hour:$minute';
        } else {
          _endTime = '$hour:$minute';
        }
      });
    }
  }
}
