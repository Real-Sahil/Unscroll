import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String role;
  final Map<String, dynamic>? riskWindows;
  final String? goals;
  final bool accountabilityEnabled;
  final String? accountabilityPartnerEmail;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.riskWindows,
    this.goals,
    this.accountabilityEnabled = false,
    this.accountabilityPartnerEmail,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? email,
    String? role,
    Map<String, dynamic>? riskWindows,
    String? goals,
    bool? accountabilityEnabled,
    String? accountabilityPartnerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      riskWindows: riskWindows ?? this.riskWindows,
      goals: goals ?? this.goals,
      accountabilityEnabled: accountabilityEnabled ?? this.accountabilityEnabled,
      accountabilityPartnerEmail: accountabilityPartnerEmail ?? this.accountabilityPartnerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isAdult => role == 'adult';
  bool isParent => role == 'parent';
  bool isChild => role == 'child';
  bool isTherapist => role == 'therapist';
}
