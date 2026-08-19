import 'package:json_annotation/json_annotation.dart';

part 'relapse_event.g.dart';

@JsonSerializable()
class RelapseEvent {
  final String id;
  final String profileId;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  RelapseEvent({
    required this.id,
    required this.profileId,
    required this.eventType,
    required this.timestamp,
    this.metadata,
  });

  factory RelapseEvent.fromJson(Map<String, dynamic> json) =>
      _$RelapseEventFromJson(json);

  Map<String, dynamic> toJson() => _$RelapseEventToJson(this);

  // Event type constants
  static const String protectionDisabled = 'protection_disabled';
  static const String panicButton = 'panic_button';
  static const String frictionBypassed = 'friction_bypassed';

  bool get isProtectionDisabled => eventType == protectionDisabled;
  bool get isPanicButton => eventType == panicButton;
  bool get isFrictionBypassed => eventType == frictionBypassed;

  String get displayLabel {
    switch (eventType) {
      case protectionDisabled:
        return 'Protection Disabled';
      case panicButton:
        return 'Panic Button Used';
      case frictionBypassed:
        return 'Friction Bypassed';
      default:
        return 'Unknown Event';
    }
  }
}

class RelapseSummary {
  final DateTime weekStart;
  final int relapseCount;
  final int totalFocusOffMinutes;
  final int panicButtonCount;

  RelapseSummary({
    required this.weekStart,
    required this.relapseCount,
    required this.totalFocusOffMinutes,
    required this.panicButtonCount,
  });

  bool get hasRelapses => relapseCount > 0;
  bool get isProgressWeek => relapseCount < 3;

  String get displayMessage {
    if (relapseCount == 0) {
      return 'Perfect week! No relapses.';
    } else if (relapseCount <= 2) {
      return 'Great effort! Only $relapseCount relapse(s).';
    } else if (relapseCount <= 5) {
      return '$relapseCount relapses this week. You\'re learning.';
    } else {
      return '$relapseCount relapses. Consider strengthening your boundaries.';
    }
  }
}
