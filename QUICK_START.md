# UnScroll Quick Start Guide

## What is UnScroll?

UnScroll is a Flutter mobile app that helps people recover from doomscrolling addiction (Instagram Reels, YouTube Shorts, TikTok) through relapse-resistant design, friction layers, and accountability.

**Status:** MVP features complete and tested, ready for Supabase integration.

---

## Project Setup

### Prerequisites
- Flutter 3.0+ and Dart 3.0+
- Xcode 14+ (iOS development)
- Android Studio with SDK (Android development)
- Git

### Clone & Setup
```bash
git clone https://github.com/Real-Sahil/Unscroll.git
cd Unscroll
git checkout claude/dart-mobile-content-blocker-11wcm3

# Install dependencies
flutter pub get

# Run on device
flutter run -d ios    # iOS simulator or device
flutter run -d android # Android emulator or device
```

---

## Key Architecture Patterns

### 1. State Management (Riverpod)
All state uses `StateNotifier` for immutability:
```dart
final policyProvider = StateNotifierProvider<PolicyNotifier, PolicyState>((ref) {
  return PolicyNotifier();
});
```

**Usage:**
```dart
final policy = ref.watch(policyProvider);
ref.read(policyProvider.notifier).updatePolicy(policy);
```

### 2. Feature Structure
Each feature has:
- `presentation/screens/` - UI screens
- `presentation/widgets/` - Reusable components
- `providers/` - State management
- `models/` - Data classes

Example: `lib/features/policies/`

### 3. Design System
- **Colors:** `AppColors` in `lib/config/theme.dart`
- **Themes:** Light/dark Material Design 3
- **Typography:** Poppins (headings), Inter (body)

Use via: `Theme.of(context).textTheme.headlineMedium`

### 4. Error Handling
All errors inherit from `AppException`:
```dart
try {
  // code
} on ValidationException catch (e) {
  // Handle validation errors
} on NetworkException catch (e) {
  // Handle network errors
}
```

Validators in `lib/core/utils/validators.dart` prevent errors early.

---

## Feature Quick Reference

| Feature | Screen Path | Provider |
|---------|------------|----------|
| Onboarding | `/onboarding` | `onboardingProvider` |
| Home Dashboard | `/` | `homeProvider` |
| Policies | `/policies` | `policiesProvider` |
| Friction Engine | (part of policy) | `frictionProvider` |
| Panic Button | `/panic-button` | `panicButtonProvider` |
| Relapse Log | `/relapse-log` | `relapseLogProvider` |
| Analytics | `/analytics` | `analyticsProvider` |
| Family Mode | `/family-mode` | `familyModeProvider` |
| Accountability | `/accountability` | `accountabilityProvider` |
| Therapist | `/therapist-dashboard` | `therapistProvider` |
| Profile | `/profile` | `profileProvider` |
| Settings | `/settings` | `settingsProvider` |

---

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test
```bash
flutter test test/validators_test.dart
```

### Generate Coverage
```bash
flutter test --coverage
```

### Test Files
- `test/validators_test.dart` - Input validation
- `test/policy_engine_test.dart` - Policy logic
- `test/error_handler_test.dart` - Error handling
- `test/form_validation_test.dart` - Form state
- `test/performance_test.dart` - Performance benchmarks
- See `docs/TESTING_GUIDE.md` for full list

---

## Common Tasks

### Add a New Screen
1. Create `lib/features/my_feature/presentation/screens/my_screen.dart`
2. Create provider: `lib/features/my_feature/providers/my_provider.dart`
3. Add route in `lib/config/routes.dart`
4. Add to app navigation

Example:
```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);
    return Scaffold(
      // UI here
    );
  }
}
```

### Add a New Provider
```dart
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(const MyState());

  void doSomething() {
    state = state.copyWith(/* updates */);
  }
}
```

### Add Validation
1. Add validator in `lib/core/utils/validators.dart`
2. Use in form: `if (!Validators.isEmail(email)) { ... }`
3. Show error: `ValidationErrorWidget(error: 'Invalid email')`

### Handle Errors
```dart
try {
  // code
} on AppException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
}
```

---

## Platform-Specific Code

### Android (Accessibility Service)
File: `android/app/src/main/kotlin/com/unscroll/services/AccessibilityService.kt`

Handles real-time detection of Reels/Shorts access and shows friction dialog.

**Testing:**
```bash
adb shell dumpsys accessibility | grep UnscrollAccessibility
```

### iOS (Screen Time API)
File: `ios/Runner/ScreenTimeManager.swift`

Manages system-level app blocking via DeviceActivity framework.

**Testing:** Requires physical device and Settings → Family Controls

### Browser Extensions
Files: `extensions/chrome/` and `extensions/firefox/`

DOM-based blocking of Reels/Shorts URLs.

**Testing:** Load unpacked extension in Chrome/Firefox

---

## Next Steps

### Immediate (This Week)
1. ✅ All MVP features implemented
2. ✅ Test coverage (193+ tests)
3. ✅ Platform-specific code ready
4. ⏳ Supabase setup (next phase)

### Supabase Integration (Next 2-3 weeks)
1. Create Supabase project at https://app.supabase.com
2. Run migrations from `docs/` directory
3. Configure authentication
4. Update Supabase service in `lib/services/`
5. Connect Realtime for multi-device sync
6. Implement Edge Functions for workflows

See `IMPLEMENTATION_STATUS.md` for detailed next steps.

### Beta Testing (Weeks after Supabase)
1. Build release APK/IPA
2. Recruit 50-100 beta testers
3. Run internal → closed → open beta phases
4. Iterate based on feedback
5. Fix critical bugs

See `docs/BETA_LAUNCH_GUIDE.md` for launch strategy.

---

## Important Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/config/theme.dart` | Design system & colors |
| `lib/config/routes.dart` | Navigation setup |
| `lib/config/constants.dart` | App-wide constants |
| `lib/core/errors/exceptions.dart` | Error types |
| `lib/core/utils/validators.dart` | Input validation |
| `pubspec.yaml` | Dependencies |
| `CLAUDE.md` | Project documentation |
| `IMPLEMENTATION_STATUS.md` | Detailed feature status |

---

## Performance Tips

### Optimize Startup
- Lazy-load providers: `ref.watch(myProvider.select((s) => s.field))`
- Use `const` constructors everywhere
- Defer non-critical initialization

### Optimize Memory
- Clean up streams in providers
- Use `ListView.builder` for large lists
- Limit cached analytics data

### Optimize Bundle
- Enable shrinking in build.gradle
- Remove unused dependencies
- Use tree-shaking in Dart

See `docs/PERFORMANCE_OPTIMIZATION.md` for details.

---

## Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Tests Fail
- Check test setup in `test/` directory
- Run `flutter test --verbose` for details
- See `docs/TESTING_GUIDE.md`

### Hot Reload Issues
- Use full restart: `R` in Flutter CLI
- Rebuild app on significant changes

### Permission Issues (Android)
- Grant accessibility permission in Settings
- Check AndroidManifest.xml for all required permissions

---

## Key Concepts

### Friction Layers
Designed to prevent impulsive disabling of protection:
1. PIN/biometric required
2. 10-30s countdown screen
3. Typed confirmation phrase
4. Consequence preview
5. 24-hour cooldown

### Panic Button
Emergency protection activation:
- One-tap activation
- Configurable cooldown (2h, 12h, 24h)
- Cannot disable during cooldown
- Activity logging

### Relapse Log
Non-shaming analytics:
- Tracks all protection disable attempts
- Shows patterns (high-risk hours, triggers)
- Simple bar/line charts
- Time-of-day analysis

### Family Mode
Parent controls for children:
- Parent sets policies
- Child can't modify parent policies
- Weekly aggregated summaries
- Non-intrusive monitoring

---

## Resources

- **Flutter Docs:** https://flutter.dev
- **Riverpod Docs:** https://riverpod.dev
- **Material Design:** https://m3.material.io
- **Supabase Docs:** https://supabase.com/docs
- **Project CLAUDE.md:** See project root

---

## Getting Help

1. Check `CLAUDE.md` for project overview
2. Read `IMPLEMENTATION_STATUS.md` for feature details
3. Review `docs/TESTING_GUIDE.md` for testing info
4. See specific feature directories for implementation patterns
5. Check `lib/core/utils/` for utilities like validators

---

**Version:** 1.0 (MVP)  
**Last Updated:** August 19, 2026  
**Status:** Ready for development
