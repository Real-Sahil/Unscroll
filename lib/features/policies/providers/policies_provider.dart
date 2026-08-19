import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/core/models/policy.dart';

class PoliciesNotifier extends StateNotifier<List<PolicyModel>> {
  PoliciesNotifier() : super([]) {
    _initializeDefaultPolicies();
  }

  void _initializeDefaultPolicies() {
    // Default policy for all apps
    state = [
      PolicyModel(
        id: 'policy_default',
        name: 'Daily Protection',
        description: 'Blocks Reels, Shorts, and TikTok feed during risk window',
        schedule: PolicySchedule(
          startTime: '22:00',
          endTime: '06:00',
          activeDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
          hardBlockEnabled: false,
          cooldownAfterDisableHours: 24,
          panicCooldownHours: 12,
          frictionLevel: 2,
        ),
        rules: [
          PolicyRule(
            appName: 'instagram',
            blockReels: true,
            blockStories: true,
            disableAutoplay: true,
          ),
          PolicyRule(
            appName: 'youtube',
            blockShorts: true,
            disableAutoplay: true,
          ),
          PolicyRule(
            appName: 'tiktok',
            blockFeed: true,
            disableAutoplay: true,
          ),
        ],
        isActive: true,
      ),
    ];
  }

  void addPolicy(PolicyModel policy) {
    state = [...state, policy];
  }

  void updatePolicy(String policyId, PolicyModel updatedPolicy) {
    state = [
      for (final policy in state)
        if (policy.id == policyId) updatedPolicy else policy,
    ];
  }

  void deletePolicy(String policyId) {
    state = state.where((p) => p.id != policyId).toList();
  }

  void togglePolicyActive(String policyId) {
    state = [
      for (final policy in state)
        if (policy.id == policyId)
          PolicyModel(
            id: policy.id,
            name: policy.name,
            description: policy.description,
            schedule: policy.schedule,
            rules: policy.rules,
            isActive: !policy.isActive,
          )
        else
          policy,
    ];
  }

  void duplicatePolicy(String policyId) {
    final policy = state.firstWhere((p) => p.id == policyId);
    final newPolicy = PolicyModel(
      id: 'policy_${DateTime.now().millisecondsSinceEpoch}',
      name: '${policy.name} (Copy)',
      description: policy.description,
      schedule: policy.schedule,
      rules: policy.rules,
      isActive: false,
    );
    addPolicy(newPolicy);
  }
}

final policiesProvider = StateNotifierProvider<PoliciesNotifier, List<PolicyModel>>(
  (ref) => PoliciesNotifier(),
);

/// Provider for active policies
final activePoliciesProvider = Provider((ref) {
  final policies = ref.watch(policiesProvider);
  return policies.where((p) => p.isActive).toList();
});
