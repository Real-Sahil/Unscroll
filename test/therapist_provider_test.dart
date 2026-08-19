import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/features/therapist/models/therapist_models.dart';
import 'package:unscroll/features/therapist/providers/therapist_provider.dart';

void main() {
  group('TherapistProvider', () {
    late TherapistNotifier therapistNotifier;
    late TherapistClientListNotifier clientListNotifier;

    setUp(() {
      therapistNotifier = TherapistNotifier();
      clientListNotifier = TherapistClientListNotifier();
    });

    group('TherapistNotifier', () {
      test('initializes with empty profile', () {
        expect(therapistNotifier.state, isNull);
      });

      test('creates therapist profile', () {
        final profile = TherapistProfile(
          id: 'therapist_1',
          email: 'dr.smith@example.com',
          displayName: 'Dr. Smith',
          licenseNumber: 'LIC123456',
          specialty: 'Addiction Recovery',
        );

        therapistNotifier.createProfile(profile);
        expect(therapistNotifier.state, equals(profile));
        expect(therapistNotifier.state?.email, 'dr.smith@example.com');
      });

      test('updates therapist profile', () {
        final profile = TherapistProfile(
          id: 'therapist_1',
          email: 'dr.smith@example.com',
          displayName: 'Dr. Smith',
          licenseNumber: 'LIC123456',
          specialty: 'Addiction Recovery',
        );

        therapistNotifier.createProfile(profile);
        final updated = profile.copyWith(specialty: 'Digital Wellness');
        therapistNotifier.updateProfile(updated);

        expect(therapistNotifier.state?.specialty, 'Digital Wellness');
      });

      test('clears therapist profile', () {
        final profile = TherapistProfile(
          id: 'therapist_1',
          email: 'dr.smith@example.com',
          displayName: 'Dr. Smith',
          licenseNumber: 'LIC123456',
          specialty: 'Addiction Recovery',
        );

        therapistNotifier.createProfile(profile);
        therapistNotifier.clearProfile();
        expect(therapistNotifier.state, isNull);
      });
    });

    group('TherapistClientListNotifier', () {
      test('initializes with empty list', () {
        expect(clientListNotifier.state, isEmpty);
      });

      test('adds client', () {
        final client = ClientSummary(
          clientId: 'client_1',
          name: 'John Doe',
          email: 'john@example.com',
          totalDaysProtected: 45,
          currentStreak: 12,
          longestStreak: 30,
          relapsesThisMonth: 3,
          panicPressesThisMonth: 2,
          adherencePercentage: 85.0,
          consecutiveDaysWithProtection: 12,
          highRiskHour: 23,
          highRiskApp: 'instagram',
          improvingAreas: ['sleep', 'focus'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: true,
          therapistNotes: 'Good progress',
        );

        clientListNotifier.addClient(client);
        expect(clientListNotifier.state.length, 1);
        expect(clientListNotifier.state.first.clientId, 'client_1');
      });

      test('removes client', () {
        final client = ClientSummary(
          clientId: 'client_1',
          name: 'John Doe',
          email: 'john@example.com',
          totalDaysProtected: 45,
          currentStreak: 12,
          longestStreak: 30,
          relapsesThisMonth: 3,
          panicPressesThisMonth: 2,
          adherencePercentage: 85.0,
          consecutiveDaysWithProtection: 12,
          highRiskHour: 23,
          highRiskApp: 'instagram',
          improvingAreas: ['sleep', 'focus'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: true,
          therapistNotes: 'Good progress',
        );

        clientListNotifier.addClient(client);
        clientListNotifier.removeClient('client_1');
        expect(clientListNotifier.state, isEmpty);
      });

      test('updates client', () {
        final client = ClientSummary(
          clientId: 'client_1',
          name: 'John Doe',
          email: 'john@example.com',
          totalDaysProtected: 45,
          currentStreak: 12,
          longestStreak: 30,
          relapsesThisMonth: 3,
          panicPressesThisMonth: 2,
          adherencePercentage: 85.0,
          consecutiveDaysWithProtection: 12,
          highRiskHour: 23,
          highRiskApp: 'instagram',
          improvingAreas: ['sleep', 'focus'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: true,
          therapistNotes: 'Good progress',
        );

        clientListNotifier.addClient(client);
        final updated = client.copyWith(
          currentStreak: 20,
          therapistNotes: 'Excellent progress',
        );
        clientListNotifier.updateClient(updated);

        expect(clientListNotifier.state.first.currentStreak, 20);
        expect(clientListNotifier.state.first.therapistNotes, 'Excellent progress');
      });

      test('filters clients by adherence threshold', () {
        final client1 = ClientSummary(
          clientId: 'client_1',
          name: 'John Doe',
          email: 'john@example.com',
          totalDaysProtected: 45,
          currentStreak: 12,
          longestStreak: 30,
          relapsesThisMonth: 3,
          panicPressesThisMonth: 2,
          adherencePercentage: 85.0,
          consecutiveDaysWithProtection: 12,
          highRiskHour: 23,
          highRiskApp: 'instagram',
          improvingAreas: ['sleep'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: true,
          therapistNotes: 'Good progress',
        );

        final client2 = ClientSummary(
          clientId: 'client_2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          totalDaysProtected: 20,
          currentStreak: 5,
          longestStreak: 10,
          relapsesThisMonth: 8,
          panicPressesThisMonth: 1,
          adherencePercentage: 55.0,
          consecutiveDaysWithProtection: 5,
          highRiskHour: 22,
          highRiskApp: 'youtube',
          improvingAreas: ['focus', 'mood'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: false,
          therapistNotes: 'Needs support',
        );

        clientListNotifier.addClient(client1);
        clientListNotifier.addClient(client2);

        final filtered = clientListNotifier.state
            .where((c) => c.adherencePercentage < 70)
            .toList();

        expect(filtered.length, 1);
        expect(filtered.first.clientId, 'client_2');
      });

      test('sorts clients by adherence descending', () {
        final client1 = ClientSummary(
          clientId: 'client_1',
          name: 'John Doe',
          email: 'john@example.com',
          totalDaysProtected: 45,
          currentStreak: 12,
          longestStreak: 30,
          relapsesThisMonth: 3,
          panicPressesThisMonth: 2,
          adherencePercentage: 85.0,
          consecutiveDaysWithProtection: 12,
          highRiskHour: 23,
          highRiskApp: 'instagram',
          improvingAreas: ['sleep'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: true,
          therapistNotes: 'Good progress',
        );

        final client2 = ClientSummary(
          clientId: 'client_2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          totalDaysProtected: 20,
          currentStreak: 5,
          longestStreak: 10,
          relapsesThisMonth: 8,
          panicPressesThisMonth: 1,
          adherencePercentage: 55.0,
          consecutiveDaysWithProtection: 5,
          highRiskHour: 22,
          highRiskApp: 'youtube',
          improvingAreas: ['focus'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: false,
          therapistNotes: 'Needs support',
        );

        clientListNotifier.addClient(client2);
        clientListNotifier.addClient(client1);

        final sorted = List<ClientSummary>.from(clientListNotifier.state)
          ..sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));

        expect(sorted.first.adherencePercentage, 85.0);
        expect(sorted.last.adherencePercentage, 55.0);
      });
    });

    group('Client Statistics', () {
      test('calculates average adherence', () {
        final client1 = ClientSummary(
          clientId: 'client_1',
          name: 'John Doe',
          email: 'john@example.com',
          totalDaysProtected: 45,
          currentStreak: 12,
          longestStreak: 30,
          relapsesThisMonth: 3,
          panicPressesThisMonth: 2,
          adherencePercentage: 80.0,
          consecutiveDaysWithProtection: 12,
          highRiskHour: 23,
          highRiskApp: 'instagram',
          improvingAreas: ['sleep'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: true,
          therapistNotes: 'Good progress',
        );

        final client2 = ClientSummary(
          clientId: 'client_2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          totalDaysProtected: 20,
          currentStreak: 5,
          longestStreak: 10,
          relapsesThisMonth: 8,
          panicPressesThisMonth: 1,
          adherencePercentage: 60.0,
          consecutiveDaysWithProtection: 5,
          highRiskHour: 22,
          highRiskApp: 'youtube',
          improvingAreas: ['focus'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: false,
          therapistNotes: 'Needs support',
        );

        clientListNotifier.addClient(client1);
        clientListNotifier.addClient(client2);

        final average = clientListNotifier.state
            .map((c) => c.adherencePercentage)
            .reduce((a, b) => a + b) / clientListNotifier.state.length;

        expect(average, 70.0);
      });

      test('counts protected clients', () {
        final client1 = ClientSummary(
          clientId: 'client_1',
          name: 'John Doe',
          email: 'john@example.com',
          totalDaysProtected: 45,
          currentStreak: 12,
          longestStreak: 30,
          relapsesThisMonth: 3,
          panicPressesThisMonth: 2,
          adherencePercentage: 85.0,
          consecutiveDaysWithProtection: 12,
          highRiskHour: 23,
          highRiskApp: 'instagram',
          improvingAreas: ['sleep'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: true,
          therapistNotes: 'Good progress',
        );

        final client2 = ClientSummary(
          clientId: 'client_2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          totalDaysProtected: 20,
          currentStreak: 5,
          longestStreak: 10,
          relapsesThisMonth: 8,
          panicPressesThisMonth: 1,
          adherencePercentage: 55.0,
          consecutiveDaysWithProtection: 5,
          highRiskHour: 22,
          highRiskApp: 'youtube',
          improvingAreas: ['focus'],
          lastActiveAt: DateTime.now(),
          isCurrentlyProtected: false,
          therapistNotes: 'Needs support',
        );

        clientListNotifier.addClient(client1);
        clientListNotifier.addClient(client2);

        final protectedCount = clientListNotifier.state
            .where((c) => c.isCurrentlyProtected)
            .length;

        expect(protectedCount, 1);
      });
    });
  });
}
