import 'package:flutter/foundation.dart';

class PerformanceMetrics {
  final String name;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic> metadata;

  PerformanceMetrics({
    required this.name,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.metadata = const {},
  });

  double get durationMs => duration.inMilliseconds.toDouble();

  @override
  String toString() => 'PerformanceMetrics($name: ${durationMs}ms)';
}

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  final List<PerformanceMetrics> _metrics = [];
  final Map<String, DateTime> _timers = {};

  factory PerformanceMonitor() {
    return _instance;
  }

  PerformanceMonitor._internal();

  void startTimer(String name) {
    _timers[name] = DateTime.now();
    if (kDebugMode) {
      print('[Performance] Timer started: $name');
    }
  }

  PerformanceMetrics? endTimer(String name, {Map<String, dynamic>? metadata}) {
    final startTime = _timers.remove(name);
    if (startTime == null) {
      if (kDebugMode) {
        print('[Performance] WARNING: Timer $name not found');
      }
      return null;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final metric = PerformanceMetrics(
      name: name,
      duration: duration,
      startTime: startTime,
      endTime: endTime,
      metadata: metadata ?? {},
    );

    _metrics.add(metric);

    if (kDebugMode) {
      print('[Performance] $metric');
    }

    return metric;
  }

  Future<T> measure<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    startTimer(name);
    try {
      return await operation();
    } finally {
      endTimer(name, metadata: metadata);
    }
  }

  T measureSync<T>(
    String name,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    startTimer(name);
    try {
      return operation();
    } finally {
      endTimer(name, metadata: metadata);
    }
  }

  List<PerformanceMetrics> getMetrics({String? filter}) {
    if (filter == null) {
      return List.from(_metrics);
    }
    return _metrics.where((m) => m.name.contains(filter)).toList();
  }

  PerformanceMetrics? getMetric(String name) {
    try {
      return _metrics.firstWhere((m) => m.name == name);
    } catch (e) {
      return null;
    }
  }

  double getTotalDuration(String? filter) {
    final filtered = getMetrics(filter: filter);
    return filtered.fold(0.0, (sum, m) => sum + m.durationMs);
  }

  double getAverageDuration(String? filter) {
    final filtered = getMetrics(filter: filter);
    if (filtered.isEmpty) return 0.0;
    return getTotalDuration(filter) / filtered.length;
  }

  PerformanceMetrics? getSlowest(String? filter) {
    final filtered = getMetrics(filter: filter);
    if (filtered.isEmpty) return null;
    return filtered.reduce((a, b) => a.duration.compareTo(b.duration) > 0 ? a : b);
  }

  PerformanceMetrics? getFastest(String? filter) {
    final filtered = getMetrics(filter: filter);
    if (filtered.isEmpty) return null;
    return filtered.reduce((a, b) => a.duration.compareTo(b.duration) < 0 ? a : b);
  }

  void printReport({String? filter}) {
    final filtered = getMetrics(filter: filter);
    if (filtered.isEmpty) {
      print('[Performance] No metrics found');
      return;
    }

    print('\n=== Performance Report ===');
    print('Total measurements: ${filtered.length}');
    print('Total duration: ${getTotalDuration(filter).toStringAsFixed(2)}ms');
    print('Average duration: ${getAverageDuration(filter).toStringAsFixed(2)}ms');
    print('Slowest: ${getSlowest(filter)}');
    print('Fastest: ${getFastest(filter)}');
    print('\nDetailed metrics:');

    for (final metric in filtered) {
      print('  - ${metric.name}: ${metric.durationMs.toStringAsFixed(2)}ms');
      if (metric.metadata.isNotEmpty) {
        print('    Metadata: ${metric.metadata}');
      }
    }
    print('========================\n');
  }

  void clearMetrics() {
    _metrics.clear();
    _timers.clear();
  }

  void reset() {
    clearMetrics();
  }

  int get metricCount => _metrics.length;
}

class PerformanceLogger {
  static void logStartup(Duration duration) {
    print('\n=== App Startup Performance ===');
    print('Time to interactive: ${duration.inMilliseconds}ms');
    if (duration.inMilliseconds < 2000) {
      print('Status: ✓ Excellent (< 2s)');
    } else if (duration.inMilliseconds < 4000) {
      print('Status: ✓ Good (< 4s)');
    } else if (duration.inMilliseconds < 6000) {
      print('Status: ⚠ Acceptable (< 6s)');
    } else {
      print('Status: ✗ Slow (> 6s)');
    }
    print('================================\n');
  }

  static void logMemoryUsage(int usedMB, int totalMB) {
    final percentage = (usedMB / totalMB * 100).toStringAsFixed(1);
    print('\n=== Memory Usage ===');
    print('Used: ${usedMB}MB / ${totalMB}MB ($percentage%)');
    if (percentage.startsWith('2') || percentage.startsWith('3')) {
      print('Status: ✓ Good');
    } else if (percentage.startsWith('4') || percentage.startsWith('5')) {
      print('Status: ⚠ Moderate');
    } else {
      print('Status: ✗ High');
    }
    print('====================\n');
  }

  static void logBuildTime(String screen, Duration duration) {
    print('[Build] $screen: ${duration.inMilliseconds}ms');
  }

  static void logFrameTime(double fps) {
    print('[Frame] FPS: ${fps.toStringAsFixed(1)}');
  }
}

class PerformanceObserver {
  static final PerformanceObserver _instance = PerformanceObserver._internal();
  final List<String> _slowOperations = [];
  static const int slowThresholdMs = 100;

  factory PerformanceObserver() {
    return _instance;
  }

  PerformanceObserver._internal();

  void checkPerformance(PerformanceMetrics metric) {
    if (metric.durationMs > slowThresholdMs) {
      _slowOperations.add('${metric.name} took ${metric.durationMs.toStringAsFixed(2)}ms');
      if (kDebugMode) {
        print('[Performance] ⚠️ Slow operation detected: ${metric.name}');
      }
    }
  }

  List<String> getSlowOperations() => List.from(_slowOperations);

  void clearSlowOperations() => _slowOperations.clear();

  void printSlowOperations() {
    if (_slowOperations.isEmpty) {
      print('[Performance] No slow operations detected');
      return;
    }

    print('\n=== Slow Operations (> ${slowThresholdMs}ms) ===');
    for (final operation in _slowOperations) {
      print('  ⚠️ $operation');
    }
    print('====================================\n');
  }
}
