import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/therapist/models/therapist_models.dart';

class TherapistNotifier extends StateNotifier<TherapistProfile?> {
  TherapistNotifier() : super(null);

  void initializeProfile(TherapistProfile profile) {
    state = profile;
  }

  void updateProfile(TherapistProfile profile) {
    state = profile;
  }

  void updateClientCount(int count) {
    if (state != null) {
      state = state!.copyWith(clientCount: count);
    }
  }

  void clearProfile() {
    state = null;
  }
}

class TherapistClientListNotifier extends StateNotifier<List<ClientSummary>> {
  TherapistClientListNotifier() : super([]);

  void setClients(List<ClientSummary> clients) {
    state = clients;
  }

  void addClient(ClientSummary client) {
    state = [...state, client];
  }

  void removeClient(String clientId) {
    state = state.where((c) => c.clientId != clientId).toList();
  }

  void updateClient(String clientId, ClientSummary updated) {
    state = state.map((c) => c.clientId == clientId ? updated : c).toList();
  }

  void updateClientNotes(String clientId, String notes) {
    state = state.map((c) {
      if (c.clientId == clientId) {
        return c.copyWith(
          therapistNotes: notes,
          lastNotesUpdated: DateTime.now(),
        );
      }
      return c;
    }).toList();
  }

  void sortByAdherence() {
    state = [...state]..sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));
  }

  void sortByRisk() {
    state = [...state]..sort((a, b) => a.adherencePercentage.compareTo(b.adherencePercentage));
  }

  void sortByLastActive() {
    state = [...state]..sort((a, b) {
      final aTime = a.lastActiveAt ?? DateTime(2000);
      final bTime = b.lastActiveAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
  }

  List<ClientSummary> filterByStatus(bool protected) {
    return state.where((c) => c.isCurrentlyProtected == protected).toList();
  }

  List<ClientSummary> filterByAdherence(double minPercentage) {
    return state.where((c) => c.adherencePercentage >= minPercentage).toList();
  }

  List<ClientSummary> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return state
        .where((c) =>
            c.clientName.toLowerCase().contains(lowerQuery) ||
            c.clientEmail.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

class TherapistRelationNotifier extends StateNotifier<List<TherapistClientRelation>> {
  TherapistRelationNotifier() : super([]);

  void setRelations(List<TherapistClientRelation> relations) {
    state = relations;
  }

  void addRelation(TherapistClientRelation relation) {
    state = [...state, relation];
  }

  void removeRelation(String relationId) {
    state = state.where((r) => r.relationId != relationId).toList();
  }

  void updateRelation(String relationId, TherapistClientRelation updated) {
    state = state.map((r) => r.relationId == relationId ? updated : r).toList();
  }

  List<TherapistClientRelation> getActiveRelations() {
    return state.where((r) => r.isActive).toList();
  }

  List<TherapistClientRelation> getPendingInvites() {
    return state.where((r) => !r.isActive && r.inviteEmail != null).toList();
  }
}

final therapistProvider = StateNotifierProvider<TherapistNotifier, TherapistProfile?>((ref) {
  return TherapistNotifier();
});

final therapistClientsProvider =
    StateNotifierProvider<TherapistClientListNotifier, List<ClientSummary>>((ref) {
  return TherapistClientListNotifier();
});

final therapistRelationsProvider =
    StateNotifierProvider<TherapistRelationNotifier, List<TherapistClientRelation>>((ref) {
  return TherapistRelationNotifier();
});

final therapistStatsProvider = Provider<({int totalClients, int activeClients, double avgAdherence})>(
  (ref) {
    final clients = ref.watch(therapistClientsProvider);
    final totalClients = clients.length;
    final activeClients = clients.where((c) => c.isCurrentlyProtected).length;
    final avgAdherence = totalClients > 0
        ? clients.fold(0.0, (sum, c) => sum + c.adherencePercentage) / totalClients
        : 0.0;

    return (
      totalClients: totalClients,
      activeClients: activeClients,
      avgAdherence: avgAdherence,
    );
  },
);

final highRiskClientsProvider = Provider<List<ClientSummary>>((ref) {
  final clients = ref.watch(therapistClientsProvider);
  return clients.where((c) => c.adherencePercentage < 50).toList()
    ..sort((a, b) => a.adherencePercentage.compareTo(b.adherencePercentage));
});

final improvingClientsProvider = Provider<List<ClientSummary>>((ref) {
  final clients = ref.watch(therapistClientsProvider);
  return clients.where((c) => c.adherencePercentage >= 80).toList()
    ..sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));
});
