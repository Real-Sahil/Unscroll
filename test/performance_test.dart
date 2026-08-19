import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/services/performance_monitor.dart';
import 'package:unscroll/services/policy_engine.dart';
import 'package:unscroll/core/models/policy.dart';

void main() {
  group('Performance Tests', () {
    late PerformanceMonitor monitor;
    late PerformanceObserver observer;

    setUp(() {
      monitor = PerformanceMonitor();
      observer = PerformanceObserver();
      monitor.clearMetrics();
      observer.clearSlowOperations();
    });

    group('PerformanceMonitor', () {
      test('measures sync operation', () {
        monitor.startTimer('test_sync');
        // Simulate work
        int sum = 0;
        for (int i = 0; i < 10000; i++) {
          sum += i;
        }
        final metric = monitor.endTimer('test_sync');

        expect(metric, isNotNull);
        expect(metric!.durationMs, greaterThan(0));
        expect(metric.name, 'test_sync');
      });

      test('measures async operation', () async {
        final metric = await monitor.measure(
          'test_async',
          () async {
            await Future.delayed(const Duration(milliseconds: 10));
          },
        );

        expect(metric, isNotNull);
        expect(metric!.durationMs, greaterThanOrEqualTo(10));
      });

      test('measureSync returns correct value', () {
        final result = monitor.measureSync(
          'test_sync_return',
          () => 42,
        );

        expect(result, 42);
        expect(monitor.getMetric('test_sync_return'), isNotNull);
      });

      test('tracks multiple operations', () {
        monitor.startTimer('op1');
        monitor.endTimer('op1');

        monitor.startTimer('op2');
        monitor.endTimer('op2');

        monitor.startTimer('op3');
        monitor.endTimer('op3');

        expect(monitor.metricCount, 3);
      });

      test('calculates total duration', () {
        monitor.measureSync('op1', () {
          for (int i = 0; i < 5000; i++) {}
        });

        monitor.measureSync('op2', () {
          for (int i = 0; i < 5000; i++) {}
        });

        final total = monitor.getTotalDuration();
        expect(total, greaterThan(0));
      });

      test('calculates average duration', () {
        for (int i = 0; i < 5; i++) {
          monitor.measureSync('repeated', () {
            for (int j = 0; j < 1000; j++) {}
          });
        }

        final avg = monitor.getAverageDuration('repeated');
        expect(avg, greaterThan(0));
      });

      test('finds slowest operation', () {
        monitor.measureSync('fast', () {
          for (int i = 0; i < 100; i++) {}
        });

        monitor.measureSync('slow', () {
          for (int i = 0; i < 10000; i++) {}
        });

        final slowest = monitor.getSlowest();
        expect(slowest?.name, 'slow');
      });

      test('finds fastest operation', () {
        monitor.measureSync('slow', () {
          for (int i = 0; i < 10000; i++) {}
        });

        monitor.measureSync('fast', () {
          for (int i = 0; i < 100; i++) {}
        });

        final fastest = monitor.getFastest();
        expect(fastest?.name, 'fast');
      });

      test('filters metrics by pattern', () {
        monitor.measureSync('policy_eval', () {});
        monitor.measureSync('policy_update', () {});
        monitor.measureSync('unrelated_op', () {});

        final filtered = monitor.getMetrics(filter: 'policy');
        expect(filtered.length, 2);
      });

      test('clears metrics', () {
        monitor.measureSync('op1', () {});
        monitor.measureSync('op2', () {});
        expect(monitor.metricCount, 2);

        monitor.clearMetrics();
        expect(monitor.metricCount, 0);
      });

      test('stores metadata', () {
        monitor.measureSync(
          'with_metadata',
          () {},
          metadata: {'version': '1.0', 'device': 'test'},
        );

        final metric = monitor.getMetric('with_metadata');
        expect(metric?.metadata['version'], '1.0');
        expect(metric?.metadata['device'], 'test');
      });
    });

    group('PerformanceObserver', () {
      test('detects slow operations', () {
        final slowMetric = PerformanceMetrics(
          name: 'slow_op',
          duration: const Duration(milliseconds: 150),
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(milliseconds: 150)),
        );

        observer.checkPerformance(slowMetric);
        final slowOps = observer.getSlowOperations();

        expect(slowOps.isNotEmpty, true);
        expect(slowOps.first, contains('slow_op'));
      });

      test('ignores fast operations', () {
        final fastMetric = PerformanceMetrics(
          name: 'fast_op',
          duration: const Duration(milliseconds: 50),
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(milliseconds: 50)),
        );

        observer.checkPerformance(fastMetric);
        final slowOps = observer.getSlowOperations();

        expect(slowOps.isEmpty, true);
      });

      test('clears slow operations', () {
        final slowMetric = PerformanceMetrics(
          name: 'slow_op',
          duration: const Duration(milliseconds: 150),
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(milliseconds: 150)),
        );

        observer.checkPerformance(slowMetric);
        expect(observer.getSlowOperations().isNotEmpty, true);

        observer.clearSlowOperations();
        expect(observer.getSlowOperations().isEmpty, true);
      });
    });

    group('PolicyEngine Performance', () {
      late PolicyEngine engine;

      setUp(() {
        engine = PolicyEngine();
      });

      test('policy evaluation completes in < 5ms', () {
        final schedule = PolicySchedule(
          daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
          startTime: '22:00',
          endTime: '07:00',
          action: 'block',
        );

        final rule = PolicyRule(
          id: 'rule_1',
          policyId: 'policy_1',
          app: 'instagram',
          blockReels: true,
          blockStories: true,
          disableAutoplay: true,
        );

        final policy = Policy(
          id: 'policy_1',
          ownerProfileId: 'user_1',
          name: 'Test',
          mode: 'scheduled',
          schedules: [schedule],
          hardBlockEnabled: false,
          cooldownAfterDisableHours: 24,
          panicCooldownHours: 12,
          frictionLevel: 'hard',
          rules: [rule],
          createdAt: DateTime.now(),
        );

        final watch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          engine.isPolicyActive(policy, DateTime.now());
        }
        watch.stop();

        final avgTime = watch.elapsedMilliseconds / 100;
        expect(avgTime, lessThan(5));
      });

      test('multiple policy evaluation < 10ms', () {
        final policies = List.generate(10, (i) {
          final schedule = PolicySchedule(
            daysOfWeek: ['Monday', 'Tuesday'],
            startTime: '22:00',
            endTime: '07:00',
            action: 'block',
          );

          return Policy(
            id: 'policy_$i',
            ownerProfileId: 'user_1',
            name: 'Policy $i',
            mode: 'scheduled',
            schedules: [schedule],
            hardBlockEnabled: false,
            cooldownAfterDisableHours: 24,
            panicCooldownHours: 12,
            frictionLevel: 'hard',
            rules: [],
            createdAt: DateTime.now(),
          );
        });

        final watch = Stopwatch()..start();
        for (final policy in policies) {
          engine.isPolicyActive(policy, DateTime.now());
        }
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(10));
      });
    });

    group('List Operations Performance', () {
      test('filtering 1000 items < 10ms', () {
        final items = List.generate(1000, (i) => i);

        final watch = Stopwatch()..start();
        final filtered = items.where((i) => i % 2 == 0).toList();
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(10));
        expect(filtered.length, 500);
      });

      test('sorting 1000 items < 50ms', () {
        final items = List.generate(1000, (i) => 1000 - i);

        final watch = Stopwatch()..start();
        items.sort();
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(50));
      });

      test('finding item in 1000 items < 5ms', () {
        final items = List.generate(1000, (i) => i);

        final watch = Stopwatch()..start();
        final found = items.firstWhere((i) => i == 500);
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(5));
        expect(found, 500);
      });

      test('map operation on 1000 items < 10ms', () {
        final items = List.generate(1000, (i) => i);

        final watch = Stopwatch()..start();
        final mapped = items.map((i) => i * 2).toList();
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(10));
        expect(mapped.length, 1000);
      });
    });

    group('String Operations Performance', () {
      test('parsing 100 time strings < 5ms', () {
        const timeString = '22:30';

        final watch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          final parts = timeString.split(':');
          int.parse(parts[0]);
          int.parse(parts[1]);
        }
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(5));
      });

      test('regex matching 100 emails < 10ms', () {
        final regex = RegExp(
          r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
        );

        final watch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          regex.hasMatch('test@example.com');
        }
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(10));
      });
    });

    group('DateTime Operations Performance', () {
      test('creating 1000 DateTime objects < 5ms', () {
        final watch = Stopwatch()..start();
        for (int i = 0; i < 1000; i++) {
          DateTime.now();
        }
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(5));
      });

      test('comparing 1000 DateTimes < 5ms', () {
        final dates = List.generate(1000, (i) => DateTime(2024, 8, i % 28 + 1));

        final watch = Stopwatch()..start();
        final target = DateTime(2024, 8, 15);
        final matching = dates.where((d) => d.isAfter(target)).toList();
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(5));
      });
    });

    group('Memory Efficiency', () {
      test('metadata storage minimal overhead', () {
        final metric = PerformanceMetrics(
          name: 'test',
          duration: const Duration(milliseconds: 10),
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          metadata: {
            'key1': 'value1',
            'key2': 'value2',
            'key3': 'value3',
            'key4': 'value4',
            'key5': 'value5',
          },
        );

        expect(metric.metadata.length, 5);
        expect(metric.metadata.containsKey('key1'), true);
      });

      test('large metric list < 100ms to process', () {
        final metrics = List.generate(1000, (i) {
          return PerformanceMetrics(
            name: 'op_$i',
            duration: Duration(milliseconds: i % 100),
            startTime: DateTime.now(),
            endTime: DateTime.now(),
          );
        });

        final watch = Stopwatch()..start();
        final slowest = metrics.reduce((a, b) =>
            a.duration.compareTo(b.duration) > 0 ? a : b);
        final fastest = metrics.reduce((a, b) =>
            a.duration.compareTo(b.duration) < 0 ? a : b);
        final total = metrics.fold(0, (sum, m) => sum + m.durationMs);
        watch.stop();

        expect(watch.elapsedMilliseconds, lessThan(100));
        expect(slowest.durationMs, 99);
      });
    });
  });
}
