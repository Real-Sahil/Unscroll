class AccountabilityPartner {
  final String id;
  final String userId;
  final String partnerId;
  final String partnerName;
  final String partnerEmail;
  final DateTime connectedAt;
  final bool isVerified;
  final bool receivesWeeklySummary;

  AccountabilityPartner({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerEmail,
    required this.connectedAt,
    this.isVerified = false,
    this.receivesWeeklySummary = true,
  });

  AccountabilityPartner copyWith({
    String? id,
    String? userId,
    String? partnerId,
    String? partnerName,
    String? partnerEmail,
    DateTime? connectedAt,
    bool? isVerified,
    bool? receivesWeeklySummary,
  }) {
    return AccountabilityPartner(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      partnerEmail: partnerEmail ?? this.partnerEmail,
      connectedAt: connectedAt ?? this.connectedAt,
      isVerified: isVerified ?? this.isVerified,
      receivesWeeklySummary: receivesWeeklySummary ?? this.receivesWeeklySummary,
    );
  }
}

class WeeklyAccountabilitySummary {
  final String id;
  final String userId;
  final String partnerId;
  final DateTime weekStart;
  final int totalDisables;
  final int totalPanicPresses;
  final int focusOffMinutes;
  final int avgHourlyDisables;
  final String highRiskHour;
  final String highRiskApp;
  final String encouragementMessage;
  final bool sentAt;

  WeeklyAccountabilitySummary({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.weekStart,
    required this.totalDisables,
    required this.totalPanicPresses,
    required this.focusOffMinutes,
    required this.avgHourlyDisables,
    required this.highRiskHour,
    required this.highRiskApp,
    required this.encouragementMessage,
    this.sentAt = false,
  });

  String getSummaryText() {
    return '''
Weekly Accountability Summary

Hey! Here's how ${DateTime.now().toString().split(' ')[0]} went:

📊 Stats:
• Disable attempts: $totalDisables
• Panic button: $totalPanicPresses
• Focus time saved: $focusOffMinutes minutes
• Average hourly attempts: $avgHourlyDisables

🎯 Insights:
• Most vulnerable hour: $highRiskHour
• Most tempting app: $highRiskApp

💪 Encouragement:
$encouragementMessage

Keep pushing forward! Every day is a chance to build better habits.
    ''';
  }
}

class PartnerInvite {
  final String id;
  final String invitedBy;
  final String invitedEmail;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool accepted;
  final String? inviteToken;

  PartnerInvite({
    required this.id,
    required this.invitedBy,
    required this.invitedEmail,
    required this.createdAt,
    required this.expiresAt,
    this.accepted = false,
    this.inviteToken,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canAccept => !isExpired && !accepted;

  PartnerInvite copyWith({
    String? id,
    String? invitedBy,
    String? invitedEmail,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? accepted,
    String? inviteToken,
  }) {
    return PartnerInvite(
      id: id ?? this.id,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedEmail: invitedEmail ?? this.invitedEmail,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      accepted: accepted ?? this.accepted,
      inviteToken: inviteToken ?? this.inviteToken,
    );
  }
}
