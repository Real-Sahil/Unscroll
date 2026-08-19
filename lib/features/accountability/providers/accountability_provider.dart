import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/accountability_models.dart';

class AccountabilityNotifier
    extends StateNotifier<List<AccountabilityPartner>> {
  AccountabilityNotifier() : super([]);

  /// Add accountability partner
  void addPartner(AccountabilityPartner partner) {
    state = [...state, partner];
  }

  /// Remove accountability partner
  void removePartner(String partnerId) {
    state = state.where((p) => p.partnerId != partnerId).toList();
  }

  /// Verify partner connection
  void verifyPartner(String partnerId) {
    state = [
      for (final partner in state)
        if (partner.partnerId == partnerId)
          partner.copyWith(isVerified: true)
        else
          partner,
    ];
  }

  /// Toggle weekly summary
  void toggleWeeklySummary(String partnerId) {
    state = [
      for (final partner in state)
        if (partner.partnerId == partnerId)
          partner.copyWith(
            receivesWeeklySummary: !partner.receivesWeeklySummary,
          )
        else
          partner,
    ];
  }

  /// Clear all partners
  void clearPartners() {
    state = [];
  }
}

final accountabilityProvider =
    StateNotifierProvider<AccountabilityNotifier, List<AccountabilityPartner>>(
  (ref) => AccountabilityNotifier(),
);

class PartnerInviteNotifier extends StateNotifier<List<PartnerInvite>> {
  PartnerInviteNotifier() : super([]);

  /// Create partner invite
  void createInvite(PartnerInvite invite) {
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

final partnerInviteProvider =
    StateNotifierProvider<PartnerInviteNotifier, List<PartnerInvite>>((ref) {
  return PartnerInviteNotifier();
});

/// Provider for pending invites
final pendingPartnerInvitesProvider = Provider((ref) {
  final invites = ref.watch(partnerInviteProvider);
  return invites.where((i) => !i.accepted && i.canAccept).toList();
});

class AccountabilitySummaryNotifier
    extends StateNotifier<List<WeeklyAccountabilitySummary>> {
  AccountabilitySummaryNotifier() : super([]);

  /// Add summary
  void addSummary(WeeklyAccountabilitySummary summary) {
    state = [...state, summary];
  }

  /// Mark summary as sent
  void markAsSent(String summaryId) {
    state = [
      for (final summary in state)
        if (summary.id == summaryId)
          WeeklyAccountabilitySummary(
            id: summary.id,
            userId: summary.userId,
            partnerId: summary.partnerId,
            weekStart: summary.weekStart,
            totalDisables: summary.totalDisables,
            totalPanicPresses: summary.totalPanicPresses,
            focusOffMinutes: summary.focusOffMinutes,
            avgHourlyDisables: summary.avgHourlyDisables,
            highRiskHour: summary.highRiskHour,
            highRiskApp: summary.highRiskApp,
            encouragementMessage: summary.encouragementMessage,
            sentAt: true,
          )
        else
          summary,
    ];
  }

  /// Get summaries for partner
  List<WeeklyAccountabilitySummary> getSummariesForPartner(String partnerId) {
    return state.where((s) => s.partnerId == partnerId).toList();
  }
}

final accountabilitySummaryProvider = StateNotifierProvider<
    AccountabilitySummaryNotifier,
    List<WeeklyAccountabilitySummary>>((ref) {
  return AccountabilitySummaryNotifier();
});
