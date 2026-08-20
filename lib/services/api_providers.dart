import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

// ============== API SERVICE PROVIDER ==============
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// ============== AUTHENTICATION STATE ==============
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? name;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.name,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? name,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService apiService;

  AuthNotifier(this.apiService) : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await apiService.initialize();
    if (apiService.isAuthenticated) {
      try {
        final profile = await apiService.getUserProfile();
        state = state.copyWith(
          isAuthenticated: true,
          userId: profile['id'],
          email: profile['email'],
          name: profile['name'],
        );
      } catch (e) {
        await logout();
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiService.register(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: response['id'],
        email: response['email'],
        name: name,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiService.login(
        email: email,
        password: password,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: response['id'],
        email: response['email'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await apiService.logout();
    state = AuthState();
  }
}

// ============== POLICIES ==============
final policiesProvider =
    StateNotifierProvider<PoliciesNotifier, List<Map<String, dynamic>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PoliciesNotifier(apiService);
});

class PoliciesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ApiService apiService;

  PoliciesNotifier(this.apiService) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (apiService.isAuthenticated) {
        final policies = await apiService.getPolicies();
        state = policies;
      }
    } catch (e) {
      print('Error loading policies: $e');
    }
  }

  Future<void> createPolicy({
    required String name,
    required List<String> blockedApps,
    required String startTime,
    required String endTime,
    required List<int> daysOfWeek,
    int frictionLevel = 3,
  }) async {
    try {
      await apiService.createPolicy(
        name: name,
        blockedApps: blockedApps,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        frictionLevel: frictionLevel,
      );
      await _initialize();
    } catch (e) {
      rethrow;
    }
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
    try {
      await apiService.updatePolicy(
        policyId: policyId,
        name: name,
        blockedApps: blockedApps,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        frictionLevel: frictionLevel,
      );
      await _initialize();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePolicy(String policyId) async {
    try {
      await apiService.deletePolicy(policyId);
      await _initialize();
    } catch (e) {
      rethrow;
    }
  }
}

// ============== PANIC BUTTON ==============
final panicStatusProvider =
    StateNotifierProvider<PanicNotifier, PanicState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PanicNotifier(apiService);
});

class PanicState {
  final bool isActive;
  final String? eventId;
  final DateTime? expiresAt;
  final int? cooldownSeconds;
  final int? timeRemainingSeconds;

  PanicState({
    this.isActive = false,
    this.eventId,
    this.expiresAt,
    this.cooldownSeconds,
    this.timeRemainingSeconds,
  });

  PanicState copyWith({
    bool? isActive,
    String? eventId,
    DateTime? expiresAt,
    int? cooldownSeconds,
    int? timeRemainingSeconds,
  }) {
    return PanicState(
      isActive: isActive ?? this.isActive,
      eventId: eventId ?? this.eventId,
      expiresAt: expiresAt ?? this.expiresAt,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
    );
  }
}

class PanicNotifier extends StateNotifier<PanicState> {
  final ApiService apiService;

  PanicNotifier(this.apiService) : super(PanicState()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      if (apiService.isAuthenticated) {
        final response = await apiService.getPanicStatus();
        if (response['active'] == true) {
          final event = response['current_event'];
          state = state.copyWith(
            isActive: true,
            eventId: event['id'],
            expiresAt: DateTime.parse(event['expires_at']),
            cooldownSeconds: event['cooldown_period'],
            timeRemainingSeconds: event['time_remaining_seconds'],
          );
        } else {
          state = PanicState();
        }
      }
    } catch (e) {
      print('Error checking panic status: $e');
    }
  }

  Future<void> activate({
    required int cooldownSeconds,
    String? notes,
  }) async {
    try {
      await apiService.activatePanicButton(
        cooldownSeconds: cooldownSeconds,
        notes: notes,
      );
      await _checkStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acknowledge() async {
    if (state.eventId != null) {
      try {
        await apiService.acknowledgePanic(state.eventId!);
        await _checkStatus();
      } catch (e) {
        rethrow;
      }
    }
  }
}

// ============== USER PROFILE ==============
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserProfileNotifier(apiService);
});

class UserProfile {
  final String? id;
  final String? email;
  final String? name;
  final int? relapsedCount;
  final int? streakDays;

  UserProfile({
    this.id,
    this.email,
    this.name,
    this.relapsedCount,
    this.streakDays,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    int? relapsedCount,
    int? streakDays,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      relapsedCount: relapsedCount ?? this.relapsedCount,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final ApiService apiService;

  UserProfileNotifier(this.apiService) : super(UserProfile()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (apiService.isAuthenticated) {
        final profile = await apiService.getUserProfile();
        final stats = await apiService.getUserStats();
        state = state.copyWith(
          id: profile['id'],
          email: profile['email'],
          name: profile['name'],
          relapsedCount: stats['relapse_stats']['total_allowed_attempts'],
          streakDays: stats['relapse_stats']['current_streak_days'],
        );
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> updateName(String name) async {
    try {
      await apiService.updateProfile(name: name);
      state = state.copyWith(name: name);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshStats() async {
    await _initialize();
  }
}

// ============== SYNC ==============
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SyncNotifier(apiService);
});

class SyncState {
  final DateTime lastSync;
  final int policiesChanged;
  final bool panicActive;

  SyncState({
    required this.lastSync,
    this.policiesChanged = 0,
    this.panicActive = false,
  });

  SyncState copyWith({
    DateTime? lastSync,
    int? policiesChanged,
    bool? panicActive,
  }) {
    return SyncState(
      lastSync: lastSync ?? this.lastSync,
      policiesChanged: policiesChanged ?? this.policiesChanged,
      panicActive: panicActive ?? this.panicActive,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final ApiService apiService;

  SyncNotifier(this.apiService)
      : super(SyncState(lastSync: DateTime.now().subtract(Duration(days: 1)))) {
    _initialize();
  }

  Future<void> _initialize() async {
    await sync();
  }

  Future<void> sync() async {
    try {
      if (!apiService.isAuthenticated) return;

      final policies = await apiService.syncPolicies(state.lastSync);
      final panic = await apiService.syncPanicStatus();

      state = state.copyWith(
        lastSync: DateTime.now(),
        policiesChanged: policies['policies_changed'],
        panicActive: panic['active'] == true,
      );
    } catch (e) {
      print('Sync error: $e');
    }
  }
}
