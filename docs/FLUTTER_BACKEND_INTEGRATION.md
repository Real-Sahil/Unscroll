# UnScroll Flutter App - Cloudflare Backend Integration

Complete guide for integrating the Flutter mobile app with the Cloudflare Workers API backend.

---

## Environment Configuration

### Setup .env File

Create `.env` in Flutter project root:

```
BACKEND_URL=https://unscroll-api.yourdomain.workers.dev
API_VERSION=v1
```

Load with `flutter_dotenv`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8787';
```

---

## API Service Setup

### Create API Service (lib/services/api_service.dart)

```dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiService {
  final String baseUrl;
  final _secureStorage = const FlutterSecureStorage();
  
  late String? _authToken;

  ApiService(this.baseUrl);

  // Get stored token
  Future<void> restoreToken() async {
    _authToken = await _secureStorage.read(key: 'auth_token');
  }

  // Make authenticated request
  Future<Map<String, dynamic>> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl/api$endpoint')
        .replace(queryParameters: queryParams);

    final headers = {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };

    http.Response response;

    try {
      if (method == 'GET') {
        response = await http.get(uri, headers: headers);
      } else if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == 'PUT') {
        response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      throw NetworkException('Network error: $e');
    }

    // Handle 401 - token expired
    if (response.statusCode == 401) {
      _authToken = null;
      await _secureStorage.delete(key: 'auth_token');
      throw AuthException('Token expired. Please login again.');
    }

    // Parse response
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          data['error'] ?? 'Unknown error',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Invalid response format', response.statusCode);
    }
  }

  // Store token
  Future<void> _storeToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
  }
}
```

---

## Authentication Flow

### Register

```dart
Future<Map<String, dynamic>> register({
  required String email,
  required String password,
  required String name,
}) async {
  final response = await apiService.request(
    method: 'POST',
    endpoint: '/auth/register',
    body: {
      'email': email,
      'password': password,
      'name': name,
    },
  );

  await apiService._storeToken(response['token']);
  return response;
}
```

### Login

```dart
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final response = await apiService.request(
    method: 'POST',
    endpoint: '/auth/login',
    body: {
      'email': email,
      'password': password,
    },
  );

  await apiService._storeToken(response['token']);
  return response;
}
```

### Refresh Token

```dart
Future<void> refreshToken() async {
  try {
    final oldToken = await _secureStorage.read(key: 'auth_token');
    if (oldToken == null) throw AuthException('No token to refresh');

    final response = await request(
      method: 'POST',
      endpoint: '/auth/refresh',
      body: {'refresh_token': oldToken},
    );

    await _storeToken(response['token']);
  } catch (e) {
    rethrow;
  }
}
```

---

## Policy Management

### Create Policy

```dart
Future<Map<String, dynamic>> createPolicy({
  required String name,
  required List<String> blockedApps,
  required String startTime,
  required String endTime,
  required List<int> daysOfWeek,
  int frictionLevel = 3,
}) async {
  return await apiService.request(
    method: 'POST',
    endpoint: '/policies',
    body: {
      'name': name,
      'blocked_apps': blockedApps,
      'start_time': startTime,
      'end_time': endTime,
      'days_of_week': daysOfWeek,
      'friction_level': frictionLevel,
    },
  );
}
```

### Get Policies

```dart
Future<List<Map<String, dynamic>>> getPolicies() async {
  final response = await apiService.request(
    method: 'GET',
    endpoint: '/policies',
  );
  return List<Map<String, dynamic>>.from(response['policies'] ?? []);
}
```

### Update Policy

```dart
Future<void> updatePolicy({
  required String policyId,
  String? name,
  List<String>? blockedApps,
  String? startTime,
  String? endTime,
  List<int>? daysOfWeek,
  int? frictionLevel,
}) async {
  final body = <String, dynamic>{
    if (name != null) 'name': name,
    if (blockedApps != null) 'blocked_apps': blockedApps,
    if (startTime != null) 'start_time': startTime,
    if (endTime != null) 'end_time': endTime,
    if (daysOfWeek != null) 'days_of_week': daysOfWeek,
    if (frictionLevel != null) 'friction_level': frictionLevel,
  };

  await apiService.request(
    method: 'PUT',
    endpoint: '/policies/$policyId',
    body: body,
  );
}
```

---

## Analytics & Relapse Tracking

### Log Blocked Attempt

```dart
Future<void> logBlockedAttempt({
  required String appName,
  String? contentType,
  bool blocked = true,
  String? notes,
}) async {
  await apiService.request(
    method: 'POST',
    endpoint: '/blocked-attempts',
    body: {
      'app_name': appName,
      'content_type': contentType,
      'blocked': blocked,
      'notes': notes,
    },
  );
}
```

### Get Analytics

```dart
Future<Map<String, dynamic>> getAnalytics({
  DateTime? startDate,
  DateTime? endDate,
  String? appName,
}) async {
  final queryParams = <String, String>{
    if (startDate != null) 'start_date': startDate.toIso8601String(),
    if (endDate != null) 'end_date': endDate.toIso8601String(),
    if (appName != null) 'app_name': appName,
  };

  return await apiService.request(
    method: 'GET',
    endpoint: '/blocked-attempts',
    queryParams: queryParams,
  );
}
```

---

## Panic Button

### Activate Panic Button

```dart
Future<Map<String, dynamic>> activatePanicButton({
  required int cooldownSeconds, // 7200, 43200, or 86400
  String? notes,
}) async {
  return await apiService.request(
    method: 'POST',
    endpoint: '/panic-button/activate',
    body: {
      'cooldown_period': cooldownSeconds,
      'notes': notes,
    },
  );
}
```

### Check Panic Status

```dart
Future<Map<String, dynamic>> getPanicStatus() async {
  return await apiService.request(
    method: 'GET',
    endpoint: '/panic-button/status',
  );
}
```

### Acknowledge Panic Event

```dart
Future<void> acknowledgePanic(String eventId) async {
  await apiService.request(
    method: 'POST',
    endpoint: '/panic-button/acknowledge',
    body: {'event_id': eventId},
  );
}
```

---

## Polling for Sync

Implement polling to sync policy changes every 30 seconds:

```dart
class SyncService {
  final ApiService apiService;
  late Timer _syncTimer;
  DateTime _lastSync = DateTime.now().subtract(Duration(days: 1));

  SyncService(this.apiService);

  void startPolling() {
    _syncTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      await syncPolicies();
      await syncPanicStatus();
    });
  }

  Future<void> syncPolicies() async {
    try {
      final response = await apiService.request(
        method: 'GET',
        endpoint: '/sync/policies/last-sync',
        queryParams: {'last_sync': _lastSync.toIso8601String()},
      );

      final policies = response['policies'] as List?;
      if (policies != null && policies.isNotEmpty) {
        // Update local state with new policies
        ref.read(policiesProvider.notifier).updatePolicies(policies);
        _lastSync = DateTime.now();
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<void> syncPanicStatus() async {
    try {
      final response = await apiService.request(
        method: 'GET',
        endpoint: '/sync/panic-status',
      );

      final active = response['active'] as bool?;
      // Update panic button state
      ref.read(panicButtonProvider.notifier).updateStatus(active ?? false);
    } catch (e) {
      print('Panic sync error: $e');
    }
  }

  void dispose() {
    _syncTimer.cancel();
  }
}
```

---

## Family Mode

### Invite Child

```dart
Future<Map<String, dynamic>> inviteChild(String childEmail) async {
  return await apiService.request(
    method: 'POST',
    endpoint: '/family/invite-child',
    body: {'child_email': childEmail},
  );
}
```

### Accept Invite (as child)

```dart
Future<void> acceptFamilyInvite(String inviteCode) async {
  await apiService.request(
    method: 'POST',
    endpoint: '/family/accept-invite',
    body: {'invite_code': inviteCode},
  );
}
```

### Get Children (as parent)

```dart
Future<List<Map<String, dynamic>>> getChildren() async {
  final response = await apiService.request(
    method: 'GET',
    endpoint: '/family/children',
  );
  return List<Map<String, dynamic>>.from(response['children'] ?? []);
}
```

### Get Child Summary

```dart
Future<Map<String, dynamic>> getChildSummary(String childId) async {
  return await apiService.request(
    method: 'GET',
    endpoint: '/family/child/$childId/summary',
  );
}
```

---

## Error Handling

Define custom exceptions:

```dart
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class AuthException extends AppException {
  AuthException(String message) : super(message);
}

class ApiException extends AppException {
  final int statusCode;
  ApiException(String message, this.statusCode) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}
```

---

## State Management with Riverpod

Example provider for policies:

```dart
final policiesProvider =
    StateNotifierProvider<PoliciesNotifier, List<Policy>>((ref) {
  return PoliciesNotifier(ref.watch(apiServiceProvider));
});

class PoliciesNotifier extends StateNotifier<List<Policy>> {
  final ApiService apiService;

  PoliciesNotifier(this.apiService) : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      final policies = await apiService.getPolicies();
      state = policies.map((p) => Policy.fromJson(p)).toList();
    } catch (e) {
      print('Error loading policies: $e');
    }
  }

  Future<void> createPolicy(PolicyData data) async {
    try {
      await apiService.createPolicy(
        name: data.name,
        blockedApps: data.blockedApps,
        startTime: data.startTime,
        endTime: data.endTime,
        daysOfWeek: data.daysOfWeek,
      );
      await _init(); // Refresh
    } catch (e) {
      rethrow;
    }
  }
}
```

---

## Testing the Integration

### Quick Test Script

```dart
Future<void> testBackendIntegration() async {
  final apiService = ApiService('http://localhost:8787');

  try {
    // 1. Register
    final registerRes = await apiService.request(
      method: 'POST',
      endpoint: '/auth/register',
      body: {
        'email': 'test@example.com',
        'password': 'testpass123',
        'name': 'Test User',
      },
    );
    print('✓ Register: ${registerRes['id']}');

    // Store token
    await apiService._storeToken(registerRes['token']);

    // 2. Create policy
    final policyRes = await apiService.request(
      method: 'POST',
      endpoint: '/policies',
      body: {
        'name': 'Test Policy',
        'blocked_apps': ['instagram', 'youtube'],
        'start_time': '22:00',
        'end_time': '07:00',
        'days_of_week': [0, 1, 2, 3, 4, 5, 6],
      },
    );
    print('✓ Create Policy: ${policyRes['id']}');

    // 3. Log blocked attempt
    await apiService.request(
      method: 'POST',
      endpoint: '/blocked-attempts',
      body: {
        'app_name': 'instagram',
        'content_type': 'reels',
        'blocked': true,
      },
    );
    print('✓ Log Blocked Attempt');

    // 4. Activate panic button
    final panicRes = await apiService.request(
      method: 'POST',
      endpoint: '/panic-button/activate',
      body: {'cooldown_period': 86400},
    );
    print('✓ Panic Button: ${panicRes['id']}');

    // 5. Get stats
    final statsRes = await apiService.request(
      method: 'POST',
      endpoint: '/user/stats',
    );
    print('✓ User Stats: ${statsRes['relapse_stats']}');

    print('\n✅ All integration tests passed!');
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
```

---

## Deployment Checklist

- [ ] Backend URL updated in .env
- [ ] JWT token storage working (flutter_secure_storage)
- [ ] API request method working (GET, POST, PUT, DELETE)
- [ ] Auth token validation on all protected routes
- [ ] Error handling for 401, 403, 404 responses
- [ ] Polling sync every 30 seconds
- [ ] Policy CRUD operations tested
- [ ] Panic button activation/status tested
- [ ] Family mode invite/accept tested
- [ ] Analytics logging tested
- [ ] Network error handling tested
- [ ] Rate limiting errors handled (429)
- [ ] CORS working on both platforms (iOS/Android)

---

## Debugging Tips

### Enable HTTP Logging

```dart
import 'package:http/http.dart' as http;

final client = http.Client();

// Log all requests
class LoggingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    print('${request.method} ${request.url}');
    return super.send(request);
  }
}
```

### Verify Token is Being Sent

```dart
print('Current token: $_authToken');
print('Auth header: Authorization: Bearer $_authToken');
```

### Test with Postman

Import collection:

```json
{
  "info": { "name": "UnScroll API", "version": "1.0" },
  "auth": { "type": "bearer", "bearer": [{ "key": "token", "value": "{{token}}" }] },
  "item": [
    {
      "name": "Register",
      "request": {
        "method": "POST",
        "url": "{{baseUrl}}/api/auth/register",
        "body": { "mode": "raw", "raw": "{...}" }
      }
    }
  ]
}
```

---

## Performance Optimization

1. **Cache policies locally** in Hive for offline access
2. **Batch log attempts** before syncing (every 10 events instead of 1)
3. **Limit polling** to active sessions only
4. **Compress** large payloads (gzip)
5. **Timeout** requests after 30s to prevent hanging

---

## Security Best Practices

1. ✅ Use HTTPS only (no plain HTTP in production)
2. ✅ Store token in flutter_secure_storage (encrypted)
3. ✅ Validate SSL certificates (certificate pinning optional)
4. ✅ Never log sensitive data (passwords, tokens)
5. ✅ Clear token on logout
6. ✅ Implement refresh token rotation
7. ✅ Validate all user inputs before sending

---
