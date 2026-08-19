enum FamilyRole { parent, child, none }

class FamilyMember {
  final String id;
  final String userId;
  final String name;
  final String email;
  final FamilyRole role;
  final DateTime addedAt;
  final bool isVerified;

  FamilyMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.addedAt,
    this.isVerified = false,
  });

  FamilyMember copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    FamilyRole? role,
    DateTime? addedAt,
    bool? isVerified,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      addedAt: addedAt ?? this.addedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class FamilyInvite {
  final String id;
  final String invitedBy; // Parent ID
  final String invitedEmail;
  final FamilyRole invitedRole;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool accepted;
  final String? inviteToken;

  FamilyInvite({
    required this.id,
    required this.invitedBy,
    required this.invitedEmail,
    required this.invitedRole,
    required this.createdAt,
    required this.expiresAt,
    this.accepted = false,
    this.inviteToken,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get canAccept => !isExpired && !accepted;

  FamilyInvite copyWith({
    String? id,
    String? invitedBy,
    String? invitedEmail,
    FamilyRole? invitedRole,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? accepted,
    String? inviteToken,
  }) {
    return FamilyInvite(
      id: id ?? this.id,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedEmail: invitedEmail ?? this.invitedEmail,
      invitedRole: invitedRole ?? this.invitedRole,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      accepted: accepted ?? this.accepted,
      inviteToken: inviteToken ?? this.inviteToken,
    );
  }
}

class ChildPolicy {
  final String id;
  final String childId;
  final String parentId;
  final bool canDisableProtection;
  final bool canViewStats;
  final bool canChangeSettings;
  final List<String> restrictedApps;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChildPolicy({
    required this.id,
    required this.childId,
    required this.parentId,
    this.canDisableProtection = false,
    this.canViewStats = true,
    this.canChangeSettings = false,
    this.restrictedApps = const ['instagram', 'youtube', 'tiktok'],
    required this.createdAt,
    this.updatedAt,
  });

  ChildPolicy copyWith({
    String? id,
    String? childId,
    String? parentId,
    bool? canDisableProtection,
    bool? canViewStats,
    bool? canChangeSettings,
    List<String>? restrictedApps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildPolicy(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      parentId: parentId ?? this.parentId,
      canDisableProtection: canDisableProtection ?? this.canDisableProtection,
      canViewStats: canViewStats ?? this.canViewStats,
      canChangeSettings: canChangeSettings ?? this.canChangeSettings,
      restrictedApps: restrictedApps ?? this.restrictedApps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FamilyGroup {
  final String id;
  final String parentId;
  final List<FamilyMember> members;
  final List<ChildPolicy> childPolicies;
  final DateTime createdAt;

  FamilyGroup({
    required this.id,
    required this.parentId,
    required this.members,
    required this.childPolicies,
    required this.createdAt,
  });

  List<FamilyMember> get children =>
      members.where((m) => m.role == FamilyRole.child).toList();

  FamilyMember? getParent() =>
      members.firstWhere((m) => m.role == FamilyRole.parent);
}
