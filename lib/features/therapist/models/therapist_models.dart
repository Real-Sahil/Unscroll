import 'package:flutter/foundation.dart';

@immutable
class TherapistProfile {
  final String id;
  final String email;
  final String displayName;
  final String? licenseNumber;
  final String? specialty;
  final int clientCount;
  final DateTime createdAt;

  const TherapistProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.licenseNumber,
    this.specialty,
    required this.clientCount,
    required this.createdAt,
  });

  TherapistProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? licenseNumber,
    String? specialty,
    int? clientCount,
    DateTime? createdAt,
  }) {
    return TherapistProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialty: specialty ?? this.specialty,
      clientCount: clientCount ?? this.clientCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@immutable
class ClientSummary {
  final String clientId;
  final String clientName;
  final String clientEmail;
  final DateTime connectedSince;

  // Recovery metrics
  final int totalDaysProtected;
  final int currentStreak;
  final int longestStreak;
  final int totalRelapsesThisMonth;
  final int panicButtonPressesThisMonth;

  // Adherence
  final double adherencePercentage; // 0-100
  final int consecutiveDaysWithProtection;

  // Risk patterns
  final int? highRiskHour;
  final String? highRiskApp;
  final List<String> improvingAreas;

  // Recent activity
  final DateTime? lastActiveAt;
  final bool isCurrentlyProtected;

  // Notes
  final String? therapistNotes;
  final DateTime? lastNotesUpdated;

  const ClientSummary({
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.connectedSince,
    required this.totalDaysProtected,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalRelapsesThisMonth,
    required this.panicButtonPressesThisMonth,
    required this.adherencePercentage,
    required this.consecutiveDaysWithProtection,
    this.highRiskHour,
    this.highRiskApp,
    required this.improvingAreas,
    this.lastActiveAt,
    required this.isCurrentlyProtected,
    this.therapistNotes,
    this.lastNotesUpdated,
  });

  TherapistProfile copyWith({
    String? clientId,
    String? clientName,
    String? clientEmail,
    DateTime? connectedSince,
    int? totalDaysProtected,
    int? currentStreak,
    int? longestStreak,
    int? totalRelapsesThisMonth,
    int? panicButtonPressesThisMonth,
    double? adherencePercentage,
    int? consecutiveDaysWithProtection,
    int? highRiskHour,
    String? highRiskApp,
    List<String>? improvingAreas,
    DateTime? lastActiveAt,
    bool? isCurrentlyProtected,
    String? therapistNotes,
    DateTime? lastNotesUpdated,
  }) {
    return ClientSummary(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      connectedSince: connectedSince ?? this.connectedSince,
      totalDaysProtected: totalDaysProtected ?? this.totalDaysProtected,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalRelapsesThisMonth: totalRelapsesThisMonth ?? this.totalRelapsesThisMonth,
      panicButtonPressesThisMonth: panicButtonPressesThisMonth ?? this.panicButtonPressesThisMonth,
      adherencePercentage: adherencePercentage ?? this.adherencePercentage,
      consecutiveDaysWithProtection: consecutiveDaysWithProtection ?? this.consecutiveDaysWithProtection,
      highRiskHour: highRiskHour ?? this.highRiskHour,
      highRiskApp: highRiskApp ?? this.highRiskApp,
      improvingAreas: improvingAreas ?? this.improvingAreas,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isCurrentlyProtected: isCurrentlyProtected ?? this.isCurrentlyProtected,
      therapistNotes: therapistNotes ?? this.therapistNotes,
      lastNotesUpdated: lastNotesUpdated ?? this.lastNotesUpdated,
    );
  }

  String getStatusLabel() {
    if (isCurrentlyProtected) return 'Protected';
    return 'Unprotected';
  }

  String getAdherenceLabel() {
    if (adherencePercentage >= 90) return 'Excellent';
    if (adherencePercentage >= 75) return 'Good';
    if (adherencePercentage >= 50) return 'Moderate';
    return 'Needs Attention';
  }
}

@immutable
class TherapistClientRelation {
  final String relationId;
  final String therapistId;
  final String clientId;
  final DateTime connectedAt;
  final bool isActive;
  final String? inviteEmail;

  const TherapistClientRelation({
    required this.relationId,
    required this.therapistId,
    required this.clientId,
    required this.connectedAt,
    required this.isActive,
    this.inviteEmail,
  });

  TherapistClientRelation copyWith({
    String? relationId,
    String? therapistId,
    String? clientId,
    DateTime? connectedAt,
    bool? isActive,
    String? inviteEmail,
  }) {
    return TherapistClientRelation(
      relationId: relationId ?? this.relationId,
      therapistId: therapistId ?? this.therapistId,
      clientId: clientId ?? this.clientId,
      connectedAt: connectedAt ?? this.connectedAt,
      isActive: isActive ?? this.isActive,
      inviteEmail: inviteEmail ?? this.inviteEmail,
    );
  }
}
