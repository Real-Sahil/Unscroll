import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_models.dart';

class FamilyNotifier extends StateNotifier<FamilyGroup?> {
  FamilyNotifier() : super(null);

  /// Initialize family group
  void initializeFamily(FamilyGroup family) {
    state = family;
  }

  /// Add family member (parent only)
  void addFamilyMember(FamilyMember member) {
    if (state == null) return;
    state = FamilyGroup(
      id: state!.id,
      parentId: state!.parentId,
      members: [...state!.members, member],
      childPolicies: state!.childPolicies,
      createdAt: state!.createdAt,
    );
  }

  /// Remove family member (parent only)
  void removeFamilyMember(String memberId) {
    if (state == null) return;
    state = FamilyGroup(
      id: state!.id,
      parentId: state!.parentId,
      members: state!.members.where((m) => m.id != memberId).toList(),
      childPolicies:
          state!.childPolicies.where((p) => p.childId != memberId).toList(),
      createdAt: state!.createdAt,
    );
  }

  /// Update child policy (parent only)
  void updateChildPolicy(ChildPolicy policy) {
    if (state == null) return;
    state = FamilyGroup(
      id: state!.id,
      parentId: state!.parentId,
      members: state!.members,
      childPolicies: [
        for (final p in state!.childPolicies)
          if (p.id == policy.id) policy else p,
      ],
      createdAt: state!.createdAt,
    );
  }

  /// Add child policy
  void addChildPolicy(ChildPolicy policy) {
    if (state == null) return;
    state = FamilyGroup(
      id: state!.id,
      parentId: state!.parentId,
      members: state!.members,
      childPolicies: [...state!.childPolicies, policy],
      createdAt: state!.createdAt,
    );
  }

  /// Clear family (logout)
  void clearFamily() {
    state = null;
  }
}

final familyProvider =
    StateNotifierProvider<FamilyNotifier, FamilyGroup?>((ref) {
  return FamilyNotifier();
});

/// Provider for family members
final familyMembersProvider = Provider((ref) {
  final family = ref.watch(familyProvider);
  return family?.members ?? [];
});

/// Provider for child members
final childrenProvider = Provider((ref) {
  final family = ref.watch(familyProvider);
  return family?.children ?? [];
});

/// Provider for child policies
final childPoliciesProvider = Provider((ref) {
  final family = ref.watch(familyProvider);
  return family?.childPolicies ?? [];
});

/// Provider for current user's family role
final familyRoleProvider = Provider((ref) {
  // This would normally determine role from auth context
  // For now returning parent as default
  return FamilyRole.parent;
});

class FamilyInviteNotifier extends StateNotifier<List<FamilyInvite>> {
  FamilyInviteNotifier() : super([]);

  /// Add pending invite
  void addInvite(FamilyInvite invite) {
    state = [...state, invite];
  }

  /// Accept invite
  void acceptInvite(String inviteId) {
    state = [
      for (final invite in state)
        if (invite.id == inviteId)
          invite.copyWith(accepted: true)
        else
          invite,
    ];
  }

  /// Reject invite
  void rejectInvite(String inviteId) {
    state = state.where((i) => i.id != inviteId).toList();
  }

  /// Clear all invites
  void clearInvites() {
    state = [];
  }
}

final familyInviteProvider =
    StateNotifierProvider<FamilyInviteNotifier, List<FamilyInvite>>((ref) {
  return FamilyInviteNotifier();
});

/// Provider for pending invites
final pendingInvitesProvider = Provider((ref) {
  final invites = ref.watch(familyInviteProvider);
  return invites.where((i) => !i.accepted && i.canAccept).toList();
});

/// Provider for pending family invites (alias for consistency)
final pendingFamilyInvitesProvider = Provider((ref) {
  final invites = ref.watch(familyInviteProvider);
  return invites.where((i) => !i.accepted && i.canAccept).toList();
});
