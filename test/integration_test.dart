import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/services/api_service.dart';

void main() {
  late ApiService apiService;

  setUpAll(() {
    apiService = ApiService(baseUrl: 'http://localhost:8787');
  });

  group('Authentication Integration Tests', () {
    test('Register new user', () async {
      final response = await apiService.register(
        email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'testpass123',
        name: 'Test User',
      );

      expect(response['id'], isNotNull);
      expect(response['token'], isNotNull);
      expect(response['expires_in'], 86400);
    });

    test('Login with valid credentials', () async {
      const email = 'test@example.com';
      const password = 'testpass123';

      // First register
      await apiService.register(
        email: email,
        password: password,
        name: 'Test User',
      );

      // Then login
      final response = await apiService.login(
        email: email,
        password: password,
      );

      expect(response['token'], isNotNull);
      expect(response['id'], isNotNull);
    });

    test('Login with invalid credentials throws error', () async {
      expect(
        () => apiService.login(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('Policy Management Tests', () {
    test('Create policy', () async {
      final response = await apiService.createPolicy(
        name: 'Test Policy',
        blockedApps: ['instagram', 'youtube'],
        startTime: '22:00',
        endTime: '07:00',
        daysOfWeek: [0, 1, 2, 3, 4, 5, 6],
        frictionLevel: 4,
      );

      expect(response['id'], isNotNull);
      expect(response['name'], 'Test Policy');
    });

    test('Get all policies', () async {
      final policies = await apiService.getPolicies();
      expect(policies, isA<List>());
    });

    test('Update policy', () async {
      // Create first
      final created = await apiService.createPolicy(
        name: 'Test Policy',
        blockedApps: ['instagram'],
        startTime: '22:00',
        endTime: '07:00',
        daysOfWeek: [0, 1, 2],
      );

      // Update
      await apiService.updatePolicy(
        policyId: created['id'],
        frictionLevel: 5,
      );

      // Verify
      final policies = await apiService.getPolicies();
      final updated = policies.firstWhere((p) => p['id'] == created['id']);
      expect(updated['friction_level'], 5);
    });

    test('Delete policy', () async {
      // Create
      final created = await apiService.createPolicy(
        name: 'Test Policy to Delete',
        blockedApps: ['instagram'],
        startTime: '22:00',
        endTime: '07:00',
        daysOfWeek: [0, 1, 2],
      );

      // Delete
      await apiService.deletePolicy(created['id']);

      // Verify
      final policies = await apiService.getPolicies();
      expect(
        policies.any((p) => p['id'] == created['id']),
        false,
      );
    });
  });

  group('Analytics Tests', () {
    test('Log blocked attempt', () async {
      await apiService.logBlockedAttempt(
        appName: 'instagram',
        contentType: 'reels',
        blocked: true,
        notes: 'Test blocked attempt',
      );

      // Should not throw
      expect(true, true);
    });

    test('Get analytics', () async {
      await apiService.logBlockedAttempt(
        appName: 'youtube',
        contentType: 'shorts',
      );

      final analytics = await apiService.getAnalytics();
      expect(analytics['attempts'], isA<List>());
      expect(analytics['statistics'], isNotNull);
    });
  });

  group('Panic Button Tests', () {
    test('Activate panic button', () async {
      final response = await apiService.activatePanicButton(
        cooldownSeconds: 86400,
        notes: 'Test panic',
      );

      expect(response['id'], isNotNull);
      expect(response['expires_at'], isNotNull);
    });

    test('Check panic status', () async {
      final response = await apiService.getPanicStatus();
      expect(response['active'], isA<bool>());
    });

    test('Invalid cooldown throws error', () async {
      expect(
        () => apiService.activatePanicButton(cooldownSeconds: 12345),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('User Profile Tests', () {
    test('Get user profile', () async {
      final profile = await apiService.getUserProfile();
      expect(profile['id'], isNotNull);
      expect(profile['email'], isNotNull);
    });

    test('Update profile', () async {
      await apiService.updateProfile(name: 'Updated Name');
      final profile = await apiService.getUserProfile();
      expect(profile['name'], 'Updated Name');
    });

    test('Get user stats', () async {
      final stats = await apiService.getUserStats();
      expect(stats['relapse_stats'], isNotNull);
      expect(stats['panic_stats'], isNotNull);
    });
  });

  group('Error Handling Tests', () {
    test('Missing token returns 401', () async {
      final unauthService = ApiService();
      expect(
        () => unauthService.getPolicies(),
        throwsA(isA<AuthException>()),
      );
    });

    test('Invalid JSON response', () async {
      // Mock invalid response
      expect(true, true); // Placeholder
    });

    test('Network timeout', () async {
      final slowService = ApiService(baseUrl: 'http://localhost:1');
      expect(
        () => slowService.getUserProfile(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
