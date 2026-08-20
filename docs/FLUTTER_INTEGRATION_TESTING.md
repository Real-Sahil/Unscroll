# Flutter Integration Testing Guide

This guide covers end-to-end integration testing of the Flutter app against the production Cloudflare backend.

## Prerequisites

- Flutter 3.0+ with Dart 3.0+
- Production API running: `https://unscroll-api-prod.sahilxleo916.workers.dev`
- API bindings verified (D1, KV namespaces connected)
- Physical iOS or Android device (or emulator/simulator)

## Test Environment Setup

### 1. Configure Test API URL

**File:** `lib/.env` (already configured)
```
API_BACKEND_URL=https://unscroll-api-prod.sahilxleo916.workers.dev
API_TIMEOUT_SECONDS=30
ENVIRONMENT=production
```

### 2. Enable Test Logging

**File:** `lib/services/api_service.dart`

Add debug logging to see all API calls:
```dart
// In ApiService class constructor
if (kDebugMode) {
  debugPrint('API Client initialized: $apiUrl');
}
```

For actual requests:
```dart
// In each method, before curl request:
debugPrint('[API] $method $endpoint');
debugPrint('[API] Request body: $requestBody');

// After response:
debugPrint('[API] Response ($statusCode): $responseBody');
```

### 3. Create Test User Account

Before running integration tests, create a dedicated test account:

```bash
# Register test user
curl -X POST https://unscroll-api-prod.sahilxleo916.workers.dev/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "flutter-test-$(date +%s)@example.com",
    "password": "TestPass123!SecureOne"
  }'

# Save the response token and user ID
# Token: eyJ...
# User ID: user_...
```

**Store credentials in `test/fixtures/test_credentials.json`:**
```json
{
  "email": "flutter-test-1692547200@example.com",
  "password": "TestPass123!SecureOne",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "userId": "user_abcd1234"
}
```

---

## Integration Test Scenarios

### Test 1: Authentication Flow

**File:** `test/integration/auth_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/services/api_service.dart';

void main() {
  group('Authentication Integration Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('Register new user', () async {
      final email = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      final password = 'TestPass123!Secure';

      final response = await apiService.register(email, password);

      expect(response, isNotNull);
      expect(response['token'], isNotEmpty);
      expect(response['id'], isNotEmpty);
      expect(response['expires_in'], isPositive);
    });

    test('Login with valid credentials', () async {
      final credentials = _loadTestCredentials();
      final response = await apiService.login(
        credentials['email'],
        credentials['password'],
      );

      expect(response, isNotNull);
      expect(response['token'], isNotEmpty);
    });

    test('Login with invalid password returns error', () async {
      final credentials = _loadTestCredentials();
      
      expect(
        () => apiService.login(credentials['email'], 'WrongPassword123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('Token refresh works', () async {
      final credentials = _loadTestCredentials();
      final newToken = await apiService.refreshToken();

      expect(newToken, isNotEmpty);
      expect(newToken, isNotEqualTo(credentials['token']));
    });
  });
}

Map<String, dynamic> _loadTestCredentials() {
  // In real test, load from test/fixtures/test_credentials.json
  return {
    'email': 'flutter-test-1692547200@example.com',
    'password': 'TestPass123!SecureOne',
    'token': 'eyJ...',
  };
}
```

**Expected Results:**
- ✅ User registration succeeds with valid email/password
- ✅ Login returns valid JWT token (24-hour expiry)
- ✅ Invalid password rejected with 401
- ✅ Token refresh generates new token

---

### Test 2: Policy Management

**File:** `test/integration/policy_test.dart`

```dart
test('Create policy with risk windows', () async {
  final policy = {
    'name': 'Evening Reels Block',
    'description': 'Block Instagram Reels after 10pm',
    'target_apps': ['instagram', 'tiktok'],
    'blocked_content': ['reels', 'shorts'],
    'friction_level': 'high',
    'risk_windows': [
      {
        'day': 1, // Monday
        'start_time': '22:00',
        'end_time': '06:00',
      },
      {
        'day': 5, // Friday
        'start_time': '22:00',
        'end_time': '06:00',
      },
    ],
    'enabled': true,
  };

  final response = await apiService.createPolicy(policy);

  expect(response, isNotNull);
  expect(response['id'], isNotEmpty);
  expect(response['name'], equals('Evening Reels Block'));
  expect(response['enabled'], isTrue);
});

test('Update policy friction level', () async {
  final policies = await apiService.getPolicies();
  final policyId = policies[0]['id'];

  final updated = await apiService.updatePolicy(policyId, {
    'friction_level': 'extreme',
  });

  expect(updated['friction_level'], equals('extreme'));
});

test('Delete policy', () async {
  final policies = await apiService.getPolicies();
  final policyId = policies[0]['id'];

  await apiService.deletePolicy(policyId);

  final updatedPolicies = await apiService.getPolicies();
  expect(updatedPolicies.any((p) => p['id'] == policyId), isFalse);
});

test('List policies returns all user policies', () async {
  final policies = await apiService.getPolicies();

  expect(policies, isList);
  for (var policy in policies) {
    expect(policy['id'], isNotEmpty);
    expect(policy['name'], isNotEmpty);
    expect(policy['risk_windows'], isList);
  }
});
```

**Expected Results:**
- ✅ Policy creation with all required fields
- ✅ Risk windows properly stored (day, start_time, end_time)
- ✅ Policy updates persist (friction_level change)
- ✅ Policy deletion removes from list
- ✅ List policies returns all user-owned policies

---

### Test 3: Panic Button Flow

**File:** `test/integration/panic_button_test.dart`

```dart
test('Activate panic button with 24h cooldown', () async {
  final response = await apiService.activatePanicButton(
    cooldownDuration: '24h',
  );

  expect(response['status'], equals('active'));
  expect(response['cooldown_duration'], equals('24h'));
  expect(response['activated_at'], isNotEmpty);
});

test('Get panic button status returns active', () async {
  // First activate
  await apiService.activatePanicButton(cooldownDuration: '24h');

  // Then check status
  final status = await apiService.getPanicStatus();

  expect(status['is_active'], isTrue);
  expect(status['can_disable'], isFalse);
});

test('Acknowledge panic button', () async {
  // Activate first
  await apiService.activatePanicButton(cooldownDuration: '24h');

  // Acknowledge
  final response = await apiService.acknowledgePanic();

  expect(response['acknowledged'], isTrue);
});

test('Cannot disable during cooldown', () async {
  // Activate with 24h cooldown
  await apiService.activatePanicButton(cooldownDuration: '24h');

  final status = await apiService.getPanicStatus();
  expect(status['can_disable'], isFalse);
  expect(status['cooldown_remaining'], isPositive);
});
```

**Expected Results:**
- ✅ Panic button activates with specified cooldown (2h, 12h, 24h)
- ✅ Status shows is_active=true, can_disable=false during cooldown
- ✅ Acknowledgment records user awareness
- ✅ Remaining cooldown decreases over time (in real scenario)

---

### Test 4: Blocked Attempts & Analytics

**File:** `test/integration/analytics_test.dart`

```dart
test('Log blocked attempt', () async {
  final timestamp = DateTime.now().toUtc().toIso8601String();

  final response = await apiService.logBlockedAttempt(
    app: 'instagram',
    contentType: 'reels',
    blocked: true,
    timestamp: timestamp,
  );

  expect(response['id'], isNotEmpty);
  expect(response['app'], equals('instagram'));
  expect(response['content_type'], equals('reels'));
  expect(response['blocked'], isTrue);
});

test('Get analytics for Instagram Reels', () async {
  // Log several attempts first
  for (int i = 0; i < 5; i++) {
    await apiService.logBlockedAttempt(
      app: 'instagram',
      contentType: 'reels',
      blocked: true,
      timestamp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  // Retrieve analytics
  final analytics = await apiService.getAnalytics(
    app: 'instagram',
    days: 7,
  );

  expect(analytics, isList);
  expect(analytics.length, greaterThanOrEqualTo(1));

  // First entry should have aggregated data
  final entry = analytics[0];
  expect(entry['app'], equals('instagram'));
  expect(entry['count'], greaterThanOrEqualTo(5));
});

test('Analytics supports filtering by app', () async {
  // Log for both Instagram and TikTok
  for (int i = 0; i < 3; i++) {
    await apiService.logBlockedAttempt(
      app: 'instagram',
      contentType: 'reels',
      blocked: true,
      timestamp: DateTime.now().toUtc().toIso8601String(),
    );
    
    await apiService.logBlockedAttempt(
      app: 'tiktok',
      contentType: 'videos',
      blocked: true,
      timestamp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  // Get Instagram-only analytics
  final instagramAnalytics = await apiService.getAnalytics(
    app: 'instagram',
    days: 7,
  );

  for (var entry in instagramAnalytics) {
    expect(entry['app'], equals('instagram'));
  }
});
```

**Expected Results:**
- ✅ Blocked attempts logged with app, content_type, timestamp
- ✅ Analytics aggregates attempts by app and time
- ✅ Filtering by app returns only matching entries
- ✅ Time-series data shows daily breakdown

---

### Test 5: User Profile & Stats

**File:** `test/integration/user_test.dart`

```dart
test('Get user profile', () async {
  final profile = await apiService.getUserProfile();

  expect(profile, isNotNull);
  expect(profile['id'], isNotEmpty);
  expect(profile['email'], isNotEmpty);
  expect(profile['created_at'], isNotEmpty);
});

test('Update user profile name', () async {
  const newName = 'Test User Name';

  final updated = await apiService.updateProfile(name: newName);

  expect(updated['name'], equals(newName));
});

test('Get user stats calculates streak', () async {
  final stats = await apiService.getUserStats();

  expect(stats, isNotNull);
  expect(stats['total_blocked_attempts'], isNonNegative);
  expect(stats['panic_activations'], isNonNegative);
  expect(stats['current_streak'], isNonNegative);
});
```

**Expected Results:**
- ✅ Profile contains user email, ID, timestamps
- ✅ Name updates persist
- ✅ Stats aggregate panic activations and blocked attempts
- ✅ Streak calculation works (days without disabling protection)

---

### Test 6: Sync & Real-time Updates

**File:** `test/integration/sync_test.dart`

```dart
test('Sync policies gets latest version', () async {
  // Create a policy
  final policy = await apiService.createPolicy({
    'name': 'Sync Test Policy',
    'target_apps': ['instagram'],
    'blocked_content': ['reels'],
    'friction_level': 'high',
    'enabled': true,
  });

  // Simulate 30-second polling interval
  await Future.delayed(Duration(seconds: 1));

  // Sync should return updated policies
  final syncedPolicies = await apiService.syncPolicies();

  expect(syncedPolicies, isList);
  expect(syncedPolicies.any((p) => p['id'] == policy['id']), isTrue);
});

test('Get panic status via sync endpoint', () async {
  await apiService.activatePanicButton(cooldownDuration: '12h');

  final status = await apiService.syncPanicStatus();

  expect(status['is_active'], isTrue);
  expect(status['cooldown_duration'], equals('12h'));
});
```

**Expected Results:**
- ✅ Sync endpoint returns latest policies
- ✅ Panic status reflects current activation state
- ✅ Multi-device sync enables consistent state

---

## Running Integration Tests

### From Command Line

```bash
# Run all integration tests
flutter test test/integration/

# Run specific test file
flutter test test/integration/auth_test.dart

# Run with verbose output
flutter test test/integration/ -v

# Run with coverage
flutter test test/integration/ --coverage
```

### From IDE

**VS Code:**
1. Open test file (e.g., `test/integration/auth_test.dart`)
2. Click **Run** or **Debug** above `void main() {`
3. Watch test output in terminal

**Android Studio:**
1. Open test file
2. Right-click test name
3. Select **Run** or **Debug**

### On Physical Device

```bash
# iOS
flutter test test/integration/ -d <iPhone device ID>

# Android
flutter test test/integration/ -d <Android device ID>
```

---

## Test Data Cleanup

After running integration tests, clean up test data to avoid polluting production:

```bash
# Manual cleanup: Delete test user account via API
curl -X DELETE https://unscroll-api-prod.sahilxleo916.workers.dev/api/user \
  -H "Authorization: Bearer <TEST_USER_TOKEN>"

# Or re-use same test email by deleting old account first
```

**Automatic cleanup in test teardown:**

```dart
tearDown(() async {
  // Optionally delete all test data after each test
  // Note: Requires DELETE /api/user endpoint implementation
  await apiService.deleteAccount();
});
```

---

## Performance Benchmarks

Expected response times for production backend:

| Endpoint | Expected Time |
|----------|--------------|
| Health check (`GET /`) | <50ms |
| User registration (`POST /api/auth/register`) | <200ms |
| Login (`POST /api/auth/login`) | <200ms (includes rate limit check) |
| Create policy (`POST /api/policies`) | <100ms |
| Get policies (`GET /api/policies`) | <100ms |
| Log blocked attempt (`POST /api/blocked-attempts`) | <50ms |
| Get analytics (`GET /api/blocked-attempts?app=instagram`) | <150ms |
| Activate panic button (`POST /api/panic-button/activate`) | <100ms |

**Test for performance regressions:**

```dart
test('Create policy completes within 100ms', () async {
  final stopwatch = Stopwatch()..start();

  await apiService.createPolicy({
    'name': 'Perf Test',
    'target_apps': ['instagram'],
    'blocked_content': ['reels'],
    'friction_level': 'high',
    'enabled': true,
  });

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});
```

---

## Troubleshooting Integration Tests

### Test Fails with "Network Error"

**Cause:** API unreachable from device/emulator

**Solution:**
1. Verify production API is running: `curl https://unscroll-api-prod.sahilxleo916.workers.dev/`
2. Check `.env` has correct API_BACKEND_URL
3. On emulator, use `10.0.2.2` instead of `localhost` for host machine
4. Check device/emulator internet connectivity

### Test Fails with "401 Unauthorized"

**Cause:** Token expired or invalid

**Solution:**
1. Regenerate test user token
2. Update `test/fixtures/test_credentials.json`
3. Call `apiService.login()` at start of test to get fresh token

### Test Fails with "Database not found"

**Cause:** D1 database binding not connected

**Solution:**
1. Verify D1 binding in Cloudflare > Workers > unscroll-api-prod > Settings > Bindings
2. Ensure binding variable name is exactly `DB` (case-sensitive)
3. Restart Worker (re-deploy from Cloudflare dashboard)

### Rate Limiting Blocks Tests

**Cause:** Test user exceeded 5 login attempts/minute

**Solution:**
1. Wait 60 seconds before retrying
2. Use different test email for each test run
3. Implement test fixtures that reuse tokens instead of logging in repeatedly

---

## Continuous Integration

To run integration tests in GitHub Actions CI/CD:

**File:** `.github/workflows/integration-tests.yml`

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run integration tests
        env:
          API_BACKEND_URL: https://unscroll-api-prod.sahilxleo916.workers.dev
          API_TIMEOUT_SECONDS: 30
        run: flutter test test/integration/
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## Next Steps

1. ✅ Set up test credentials and fixtures
2. ✅ Run each integration test scenario
3. ✅ Verify all endpoints respond correctly
4. ✅ Check response times meet benchmarks
5. ✅ Clean up test data after validation
6. → Proceed to **platform-specific testing** (iOS Screen Time, Android AccessibilityService)
7. → Test **browser extensions** (Chrome content script)
8. → Launch **beta testing** with real users

---

**Last Updated:** 2026-08-20  
**Status:** Integration testing framework ready for production API
