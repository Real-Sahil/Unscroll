import 'package:json_annotation/json_annotation.dart';

part 'policy.g.dart';

@JsonSerializable()
class Policy {
  final String id;
  final String ownerProfileId;
  final String name;
  final String mode;
  final List<PolicySchedule>? schedules;
  final int? dailyCapMin;
  final bool hardBlockEnabled;
  final int cooldownAfterDisableHours;
  final int panicCooldownHours;
  final bool defaultHardBlock;
  final String frictionLevel;
  final List<PolicyRule> rules;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Policy({
    required this.id,
    required this.ownerProfileId,
    required this.name,
    required this.mode,
    this.schedules,
    this.dailyCapMin,
    this.hardBlockEnabled = true,
    this.cooldownAfterDisableHours = 24,
    this.panicCooldownHours = 12,
    this.defaultHardBlock = true,
    this.frictionLevel = 'hard',
    required this.rules,
    required this.createdAt,
    this.updatedAt,
  });

  factory Policy.fromJson(Map<String, dynamic> json) => _$PolicyFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyToJson(this);

  Policy copyWith({
    String? id,
    String? ownerProfileId,
    String? name,
    String? mode,
    List<PolicySchedule>? schedules,
    int? dailyCapMin,
    bool? hardBlockEnabled,
    int? cooldownAfterDisableHours,
    int? panicCooldownHours,
    bool? defaultHardBlock,
    String? frictionLevel,
    List<PolicyRule>? rules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Policy(
      id: id ?? this.id,
      ownerProfileId: ownerProfileId ?? this.ownerProfileId,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      schedules: schedules ?? this.schedules,
      dailyCapMin: dailyCapMin ?? this.dailyCapMin,
      hardBlockEnabled: hardBlockEnabled ?? this.hardBlockEnabled,
      cooldownAfterDisableHours: cooldownAfterDisableHours ?? this.cooldownAfterDisableHours,
      panicCooldownHours: panicCooldownHours ?? this.panicCooldownHours,
      defaultHardBlock: defaultHardBlock ?? this.defaultHardBlock,
      frictionLevel: frictionLevel ?? this.frictionLevel,
      rules: rules ?? this.rules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => hardBlockEnabled;
  bool get requiresFriction => frictionLevel == 'hard';
}

@JsonSerializable()
class PolicySchedule {
  final List<String> daysOfWeek;
  final String startTime;
  final String endTime;
  final String action;

  PolicySchedule({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.action,
  });

  factory PolicySchedule.fromJson(Map<String, dynamic> json) =>
      _$PolicyScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyScheduleToJson(this);
}

@JsonSerializable()
class PolicyRule {
  final String id;
  final String policyId;
  final String app;
  final bool blockShorts;
  final bool blockReels;
  final bool blockStories;
  final bool disableAutoplay;
  final bool approvedChannelsOnly;

  PolicyRule({
    required this.id,
    required this.policyId,
    required this.app,
    this.blockShorts = true,
    this.blockReels = true,
    this.blockStories = false,
    this.disableAutoplay = true,
    this.approvedChannelsOnly = false,
  });

  factory PolicyRule.fromJson(Map<String, dynamic> json) =>
      _$PolicyRuleFromJson(json);

  Map<String, dynamic> toJson() => _$PolicyRuleToJson(this);
}
