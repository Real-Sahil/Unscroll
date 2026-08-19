# UnScroll Performance Optimization Guide

## Overview
This document outlines performance optimization strategies for the UnScroll Flutter app, targeting startup time, memory usage, and bundle size. All recommendations follow Flutter best practices and are tailored for addiction-recovery use cases where reliable, fast performance is critical.

---

## 1. Startup Time Optimization

### Target: < 2 seconds to interactive

#### 1.1 App Initialization
- **Lazy Load Providers**: Use `FutureProvider` for non-critical initialization (analytics, notifications)
- **Defer Heavy Operations**: Move policy engine initialization to background via `compute()`
- **Preload Critical Data**: Load user policies and preferences before home screen renders

```dart
// Before: Blocks startup
void main() {
  runApp(const UnscrollApp());
}

// After: Non-blocking initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Critical: Load only user auth state
  await SecureStorage.init();
  
  // Non-critical: Load async in background
  unawaited(NotificationService.init());
  unawaited(AnalyticsService.init());
  
  runApp(const UnscrollApp());
}
```

#### 1.2 Providers Setup
- Use `select()` in ConsumerWidgets to reduce rebuild triggers
- Implement provider caching for expensive computations
- Use `AsyncValue` for lazy loading screens

```dart
// Good: Only rebuilds when policies change
ConsumerWidget(
  builder: (context, ref, _) {
    final policies = ref.watch(
      policiesProvider.select((state) => state.policies)
    );
    return PolicyList(policies: policies);
  },
);
```

#### 1.3 Widget Tree Optimization
- Split large widgets into smaller composable units
- Use `const` constructors where possible to prevent unnecessary rebuilds
- Lazy-load tab content via `ListView.builder` or `PageView`

---

## 2. Memory Usage Optimization

### Target: < 100MB for normal operation, < 150MB peak

#### 2.1 Image Optimization
- Use `CachedNetworkImage` with size limits
- Compress local images (max 512x512 for thumbnails)
- Lazy-load images in lists with `Image(gaplessPlayback: true)`

```dart
// Good: Limited cache size
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => SizedBox.shrink(),
  cacheManager: CacheManager(
    Config(
      'image_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50,  // Limit memory
    ),
  ),
);
```

#### 2.2 State Management
- Don't hold large collections in memory (policies, analytics)
- Use `FutureProvider` or `StreamProvider` for paginated data
- Implement `select()` to watch only needed fields
- Clear old analytics/relapse logs periodically

```dart
// Good: Paginated analytics
class AnalyticsNotifier extends StateNotifier<List<DailyAnalytic>> {
  void loadMore(int page) {
    final startIndex = (page - 1) * 30;
    final endIndex = startIndex + 30;
    // Only load 30 days at a time
  }
}
```

#### 2.3 Hive/SharedPreferences
- Set max storage size limits (max 50MB for local policies)
- Prune old relapse logs after 90 days
- Use `CompactionStrategy` to optimize Hive box files

```dart
final box = await Hive.openBox('policies');
await box.compact(); // Reclaim space
```

#### 2.4 Stream & Future Management
- Cancel subscriptions when widgets dispose
- Use `ref.onDispose()` in Riverpod for cleanup
- Avoid holding long-lived streams without purpose

---

## 3. Bundle Size Optimization

### Target: < 40MB release APK, < 60MB release IPA

#### 3.1 Dependencies
- Audit pubspec.yaml for unused packages
- Prefer lightweight alternatives:
  - `intl` → `jiffy` for date formatting (smaller)
  - `get_it` → `Riverpod` (already in use)
  - Avoid Firebase bloat for non-analytics features

#### 3.2 Code Shrinking
- Enable ProGuard/R8 for Android in `build.gradle`:
  ```gradle
  release {
    minifyEnabled true
    shrinkResources true
    proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
  }
  ```

- iOS: Use tree-shaking via `--split-debug-info` flag
  ```bash
  flutter build ios --release --split-debug-info=debugSymbols/
  ```

#### 3.3 Asset Optimization
- Use WebP format for images (50% smaller than PNG)
- Compress SVGs with `svgz`
- Exclude unused assets from pubspec.yaml

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    # Exclude: assets/design/ (dev-only)
```

#### 3.4 Platform-Specific Optimization
**Android:**
- Target latest SDK (reduces bloat)
- Use split APKs by ABI: `enableSplit = true`
- Minimize native libraries (AccessibilityService is lightweight)

**iOS:**
- Use App Thinning for bitcode
- Exclude unused frameworks
- Minimize custom Screen Time integration code

---

## 4. Runtime Performance

### 4.1 Build Performance
- Use `const` constructors in widgets
- Avoid rebuilding entire lists (use `ListView.builder`)
- Profile with Flutter DevTools:

```bash
flutter run --profile
# In DevTools: View > Performance
```

### 4.2 Frame Rate
- Target 60 FPS (mobile standard)
- Friction UI (breathing animation) should not drop below 55 FPS
- Use `Rive` animations (GPU-accelerated) instead of custom SVG animations

```dart
// Profile frame drops
import 'dart:developer' as developer;

void onFrameDropped() {
  developer.Timeline.instantSync('Frame dropped');
}
```

### 4.3 Policy Engine Performance
- Cache schedule evaluation results (no recalculation every render)
- Use binary search for time-based lookups
- Batch policy updates to prevent cascading rebuilds

```dart
// Optimized: Cache evaluation result
class PolicyEvaluationCache {
  final Map<String, bool> _cache = {};
  
  bool isPolicyActive(Policy policy, DateTime time) {
    final key = '${policy.id}_${time.hour}';
    return _cache.putIfAbsent(key, () => _evaluate(policy, time));
  }
  
  void invalidate(String policyId) => _cache.removeWhere((k, _) => k.startsWith(policyId));
}
```

### 4.4 Notification Performance
- Batch notification updates (max 1 update/second)
- Use `throttle` for real-time notification streams
- Lazy-load notification history (pagination)

---

## 5. Profiling & Measurement

### 5.1 Using PerformanceMonitor
```dart
final monitor = PerformanceMonitor();

// Measure startup
monitor.startTimer('app_startup');
// ... initialization code
monitor.endTimer('app_startup');
monitor.printReport();

// Measure async operation
await monitor.measure(
  'fetch_policies',
  () => policyService.fetchPolicies(),
  metadata: {'count': 42},
);

// Get metrics
final slowest = monitor.getSlowest();
final avgTime = monitor.getAverageDuration('friction_engine');
```

### 5.2 Performance Monitoring
```dart
// Check for slow operations
final observer = PerformanceObserver();
final metric = monitor.endTimer('build_policy_list');
observer.checkPerformance(metric);
observer.printSlowOperations();
```

### 5.3 DevTools Integration
```bash
flutter run --profile
# In DevTools:
# - Timeline: Identify janky frames
# - Memory: Track allocations
# - CPU: Identify hot functions
```

---

## 6. Specific Optimization Opportunities

### 6.1 Friction Engine
- **Problem**: Friction dialog with breathing animation may stutter
- **Solution**: 
  - Pre-render Rive animation (GPU cache)
  - Use `RepaintBoundary` to isolate animation from other UI
  - Limit animation FPS to 30 (sufficient for breathing effect)

```dart
class FrictionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RiveAnimation.asset('assets/animations/breathing.riv'),
    );
  }
}
```

### 6.2 Relapse Log Charts
- **Problem**: 30-day analytics chart may cause jank with 500+ data points
- **Solution**:
  - Downsample data (aggregate by hour instead of minute)
  - Use `fl_chart` with `RepaintBoundary`
  - Limit visible range to 7-14 days at a time

```dart
// Downsample hourly
final hourlyData = dailyData.fold<Map<int, int>>({}, (acc, entry) {
  final hour = entry.date.hour;
  acc[hour] = (acc[hour] ?? 0) + entry.focusMinutesLost;
  return acc;
});
```

### 6.3 Therapist Dashboard
- **Problem**: Large client list (100+ clients) causes scroll lag
- **Solution**:
  - Use `LazyLoadScrollView` with pagination
  - Virtual scrolling via `indexed_list_view`
  - Limit client cards in viewport to 5-10

```dart
ListView.builder(
  itemCount: clients.length,
  itemBuilder: (context, index) {
    // Only build visible items
    return ClientCard(client: clients[index]);
  },
)
```

### 6.4 Local Storage
- **Problem**: Hive queries on large relapse logs are slow
- **Solution**:
  - Index by date range
  - Archive old data (older than 90 days)
  - Use batch operations

```dart
// Archival strategy
void archiveOldData() {
  final cutoff = DateTime.now().subtract(Duration(days: 90));
  final old = relapseBox.values.where((r) => r.date.isBefore(cutoff));
  relapseBox.deleteAll(old.map((r) => r.key));
}
```

---

## 7. Testing Performance

### 7.1 Benchmark Tests
```dart
void main() {
  group('Performance Benchmarks', () {
    testWidgets('PolicyEngine evaluation < 10ms', (tester) async {
      final engine = PolicyEngine();
      final policy = createTestPolicy();
      
      final watch = Stopwatch()..start();
      engine.isPolicyActive(policy, DateTime.now());
      watch.stop();
      
      expect(watch.elapsedMilliseconds, lessThan(10));
    });
  });
}
```

### 7.2 Memory Profiling
```bash
# Capture memory snapshot
flutter run --profile --trace-startup=out.timeline

# Analyze with DevTools
open chrome://devtools
```

### 7.3 Build Analysis
```bash
flutter build apk --analyze-size
# Shows breakdown of code/assets/native libs
```

---

## 8. Deployment Checklist

- [ ] Release APK < 40MB
- [ ] Release IPA < 60MB
- [ ] App startup < 2s
- [ ] Friction UI animation 55+ FPS
- [ ] Relapse log scroll smooth at 60 FPS
- [ ] Memory peak < 150MB
- [ ] No ANR (Android Not Responding) on low-end devices
- [ ] Proguard minification enabled
- [ ] Old data archival working (>90 days)
- [ ] Performance metrics integrated

---

## 9. Quick Reference: Common Optimizations

| Issue | Solution | Improvement |
|-------|----------|-------------|
| Slow startup | Lazy-load providers | 500ms - 1s faster |
| High memory | Pagination + archival | 30-50MB reduction |
| Large bundle | Remove unused deps | 5-10MB reduction |
| Frame drops (60→50 FPS) | RepaintBoundary + const | Restore to 60 FPS |
| Slow queries | Index + pagination | 100ms → 10ms |
| Jank on list scroll | LazyLoad + builder | Smooth scroll |

---

## 10. Future Improvements

1. **Code-splitting**: Load therapist features only when needed
2. **WebAssembly**: Compile policy engine to WASM for speed
3. **Native modules**: C++ implementation of policy evaluation (if needed)
4. **Caching strategy**: HTTP caching for future Supabase integration
5. **Offline-first**: Reduce network roundtrips via aggressive local caching

---

**Last Updated**: August 19, 2026
**Status**: Production-Ready Optimization Guide
**Next Review**: After beta testing (v1.0.0)
