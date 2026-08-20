import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Custom exceptions for API errors
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

/// Main API service for Cloudflare Workers backend
class ApiService {
  static const _secureStorage = FlutterSecureStorage();
  final String baseUrl;
  String? _authToken;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BACKEND_URL'] ?? 'http://localhost:8787';

  /// Initialize by restoring stored token
  Future<void> initialize() async {
    try {
      _authToken = await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      print('Error restoring token: $e');
    }
  }

  /// Get current auth token
  String? get authToken => _authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  /// Make HTTP request with error handling
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
        response = await http.get(uri, headers: headers).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw NetworkException('Request timeout'),
        );
      } else if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw NetworkException('Request timeout'),
        );
      } else if (method == 'PUT') {
        response = await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw NetworkException('Request timeout'),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw NetworkException('Request timeout'),
        );
      } else {
        throw ValidationException('Unsupported HTTP method: $method');
      }
    } catch (e) {
      if (e is AppException) rethrow;
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
      if (e is AppException) rethrow;
      throw ApiException('Invalid response format', response.statusCode);
    }
  }

  /// Store token securely
  Future<void> _storeToken(String token) async {
    _authToken = token;
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
    } catch (e) {
      print('Error storing token: $e');
    }
  }

  // ============== AUTHENTICATION ==============

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw ValidationException('Invalid email');
    }
    if (password.length < 8) {
      throw ValidationException('Password must be at least 8 characters');
    }

    final response = await request(
      method: 'POST',
      endpoint: '/auth/register',
      body: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    await _storeToken(response['token']);
    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw ValidationException('Email and password required');
    }

    final response = await request(
      method: 'POST',
      endpoint: '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    await _storeToken(response['token']);
    return response;
  }

  Future<void> refreshToken() async {
    if (_authToken == null) throw AuthException('No token to refresh');

    try {
      final response = await request(
        method: 'POST',
        endpoint: '/auth/refresh',
        body: {'refresh_token': _authToken},
      );

      await _storeToken(response['token']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _authToken = null;
    try {
      await _secureStorage.delete(key: 'auth_token');
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  // ============== POLICIES ==============

  Future<Map<String, dynamic>> createPolicy({
    required String name,
    required List<String> blockedApps,
    required String startTime,
    required String endTime,
    required List<int> daysOfWeek,
    int frictionLevel = 3,
  }) async {
    return await request(
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

  Future<List<Map<String, dynamic>>> getPolicies() async {
    final response = await request(
      method: 'GET',
      endpoint: '/policies',
    );
    return List<Map<String, dynamic>>.from(response['policies'] ?? []);
  }

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

    await request(
      method: 'PUT',
      endpoint: '/policies/$policyId',
      body: body,
    );
  }

  Future<void> deletePolicy(String policyId) async {
    await request(
      method: 'DELETE',
      endpoint: '/policies/$policyId',
    );
  }

  // ============== ANALYTICS ==============

  Future<void> logBlockedAttempt({
    required String appName,
    String? contentType,
    bool blocked = true,
    String? notes,
  }) async {
    await request(
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

    return await request(
      method: 'GET',
      endpoint: '/blocked-attempts',
      queryParams: queryParams,
    );
  }

  // ============== PANIC BUTTON ==============

  Future<Map<String, dynamic>> activatePanicButton({
    required int cooldownSeconds,
    String? notes,
  }) async {
    const validPeriods = [7200, 43200, 86400];
    if (!validPeriods.contains(cooldownSeconds)) {
      throw ValidationException(
          'Cooldown must be 7200 (2h), 43200 (12h), or 86400 (24h)');
    }

    return await request(
      method: 'POST',
      endpoint: '/panic-button/activate',
      body: {
        'cooldown_period': cooldownSeconds,
        'notes': notes,
      },
    );
  }

  Future<Map<String, dynamic>> getPanicStatus() async {
    return await request(
      method: 'GET',
      endpoint: '/panic-button/status',
    );
  }

  Future<void> acknowledgePanic(String eventId) async {
    await request(
      method: 'POST',
      endpoint: '/panic-button/acknowledge',
      body: {'event_id': eventId},
    );
  }

  // ============== USER PROFILE ==============

  Future<Map<String, dynamic>> getUserProfile() async {
    return await request(
      method: 'GET',
      endpoint: '/user/profile',
    );
  }

  Future<void> updateProfile({required String name}) async {
    await request(
      method: 'PUT',
      endpoint: '/user/profile',
      body: {'name': name},
    );
  }

  Future<Map<String, dynamic>> getUserStats() async {
    return await request(
      method: 'POST',
      endpoint: '/user/stats',
    );
  }

  // ============== FAMILY MODE ==============

  Future<Map<String, dynamic>> inviteChild(String childEmail) async {
    return await request(
      method: 'POST',
      endpoint: '/family/invite-child',
      body: {'child_email': childEmail},
    );
  }

  Future<void> acceptFamilyInvite(String inviteCode) async {
    await request(
      method: 'POST',
      endpoint: '/family/accept-invite',
      body: {'invite_code': inviteCode},
    );
  }

  Future<List<Map<String, dynamic>>> getChildren() async {
    final response = await request(
      method: 'GET',
      endpoint: '/family/children',
    );
    return List<Map<String, dynamic>>.from(response['children'] ?? []);
  }

  Future<Map<String, dynamic>> getChildSummary(String childId) async {
    return await request(
      method: 'GET',
      endpoint: '/family/child/$childId/summary',
    );
  }

  Future<void> updateChildPolicy({
    required String childId,
    required String policyId,
    String? name,
    List<String>? blockedApps,
    String? startTime,
    String? endTime,
    List<int>? daysOfWeek,
    int? frictionLevel,
  }) async {
    final body = <String, dynamic>{
      'policy_id': policyId,
      if (name != null) 'name': name,
      if (blockedApps != null) 'blocked_apps': blockedApps,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (frictionLevel != null) 'friction_level': frictionLevel,
    };

    await request(
      method: 'PUT',
      endpoint: '/family/child/$childId/policies',
      body: body,
    );
  }

  // ============== ACCOUNTABILITY ==============

  Future<void> invitePartner(String partnerEmail) async {
    await request(
      method: 'POST',
      endpoint: '/accountability/invite-partner',
      body: {'partner_email': partnerEmail},
    );
  }

  Future<List<Map<String, dynamic>>> getPartners() async {
    final response = await request(
      method: 'GET',
      endpoint: '/accountability/partners',
    );
    return List<Map<String, dynamic>>.from(response['partners'] ?? []);
  }

  // ============== SYNC ==============

  Future<Map<String, dynamic>> syncPolicies(DateTime lastSync) async {
    return await request(
      method: 'GET',
      endpoint: '/sync/policies/last-sync',
      queryParams: {'last_sync': lastSync.toIso8601String()},
    );
  }

  Future<Map<String, dynamic>> syncPanicStatus() async {
    return await request(
      method: 'GET',
      endpoint: '/sync/panic-status',
    );
  }

  // ============== NOTIFICATIONS ==============

  Future<void> logEvent({
    required String eventType,
    Map<String, dynamic>? eventData,
  }) async {
    await request(
      method: 'POST',
      endpoint: '/notifications/log-event',
      body: {
        'event_type': eventType,
        'event_data': eventData ?? {},
      },
    );
  }
}
