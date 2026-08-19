import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PanicButtonCooldown {
  twoHours('2 Hours'),
  twelveHours('12 Hours'),
  twentyFourHours('24 Hours');

  const PanicButtonCooldown(this.label);
  final String label;

  Duration get duration {
    switch (this) {
      case PanicButtonCooldown.twoHours:
        return const Duration(hours: 2);
      case PanicButtonCooldown.twelveHours:
        return const Duration(hours: 12);
      case PanicButtonCooldown.twentyFourHours:
        return const Duration(hours: 24);
    }
  }

  int get durationMinutes => duration.inMinutes;
}

class PanicButtonEvent {
  final DateTime timestamp;
  final PanicButtonCooldown cooldownPeriod;
  final String? note;
  final bool acknowledged;

  PanicButtonEvent({
    required this.timestamp,
    required this.cooldownPeriod,
    this.note,
    this.acknowledged = false,
  });

  DateTime get expiresAt => timestamp.add(cooldownPeriod.duration);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isActive => !isExpired && !acknowledged;

  Duration get remainingDuration {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get remainingTimeFormatted {
    final remaining = remainingDuration;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else {
      return '${minutes}m remaining';
    }
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'cooldownPeriod': cooldownPeriod.name,
    'note': note,
    'acknowledged': acknowledged,
  };

  factory PanicButtonEvent.fromJson(Map<String, dynamic> json) {
    final cooldownName = json['cooldownPeriod'] as String;
    final cooldown = PanicButtonCooldown.values
        .firstWhere((e) => e.name == cooldownName);

    return PanicButtonEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      cooldownPeriod: cooldown,
      note: json['note'] as String?,
      acknowledged: json['acknowledged'] as bool? ?? false,
    );
  }
}

class PanicButtonState {
  final List<PanicButtonEvent> events;
  final PanicButtonCooldown defaultCooldown;
  final bool isProtectionActive;
  final PanicButtonEvent? latestEvent;

  const PanicButtonState({
    this.events = const [],
    this.defaultCooldown = PanicButtonCooldown.twentyFourHours,
    this.isProtectionActive = false,
    this.latestEvent,
  });

  PanicButtonState copyWith({
    List<PanicButtonEvent>? events,
    PanicButtonCooldown? defaultCooldown,
    bool? isProtectionActive,
    PanicButtonEvent? latestEvent,
  }) =>
      PanicButtonState(
        events: events ?? this.events,
        defaultCooldown: defaultCooldown ?? this.defaultCooldown,
        isProtectionActive: isProtectionActive ?? this.isProtectionActive,
        latestEvent: latestEvent ?? this.latestEvent,
      );

  bool get isOnCooldown => latestEvent?.isActive ?? false;

  Duration get cooldownRemaining =>
      isOnCooldown ? latestEvent!.remainingDuration : Duration.zero;

  int get totalPressedCount => events.length;

  int get thisWeekCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return events.where((e) => e.timestamp.isAfter(weekAgo)).length;
  }

  int get todayCount {
    final today = DateTime.now();
    return events
        .where((e) =>
            e.timestamp.year == today.year &&
            e.timestamp.month == today.month &&
            e.timestamp.day == today.day)
        .length;
  }
}

class PanicButtonNotifier extends StateNotifier<PanicButtonState> {
  PanicButtonNotifier() : super(const PanicButtonState());

  void activatePanic({
    PanicButtonCooldown cooldown = PanicButtonCooldown.twentyFourHours,
    String? note,
  }) {
    final event = PanicButtonEvent(
      timestamp: DateTime.now(),
      cooldownPeriod: cooldown,
      note: note,
    );

    state = state.copyWith(
      events: [...state.events, event],
      isProtectionActive: true,
      latestEvent: event,
    );
  }

  void acknowledgePanic() {
    if (state.latestEvent == null) return;

    final updatedEvent = PanicButtonEvent(
      timestamp: state.latestEvent!.timestamp,
      cooldownPeriod: state.latestEvent!.cooldownPeriod,
      note: state.latestEvent!.note,
      acknowledged: true,
    );

    final updatedEvents = state.events.map((e) {
      if (e.timestamp == state.latestEvent!.timestamp) {
        return updatedEvent;
      }
      return e;
    }).toList();

    state = state.copyWith(
      events: updatedEvents,
      latestEvent: updatedEvent,
      isProtectionActive: false,
    );
  }

  void setDefaultCooldown(PanicButtonCooldown cooldown) {
    state = state.copyWith(defaultCooldown: cooldown);
  }

  void clearEvents() {
    state = state.copyWith(
      events: [],
      latestEvent: null,
      isProtectionActive: false,
    );
  }

  void removeEvent(PanicButtonEvent event) {
    final updatedEvents = state.events
        .where((e) => e.timestamp != event.timestamp)
        .toList();

    state = state.copyWith(events: updatedEvents);
  }
}
