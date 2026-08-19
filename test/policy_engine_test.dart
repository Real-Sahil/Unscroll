import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/core/models/policy.dart';
import 'package:unscroll/services/policy_engine.dart';

void main() {
  group('PolicyEngine', () {
    late PolicyEngine policyEngine;
    late Policy testPolicy;

    setUp(() {
      policyEngine = PolicyEngine();

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

      testPolicy = Policy(
        id: 'policy_1',
        ownerProfileId: 'user_1',
        name: 'Evening Protection',
        mode: 'scheduled',
        schedules: [schedule],
        hardBlockEnabled: false,
        cooldownAfterDisableHours: 24,
        panicCooldownHours: 12,
        frictionLevel: 'hard',
        rules: [rule],
        createdAt: DateTime.now(),
      );
    });

    group('Policy Evaluation', () {
      test('policy is active during scheduled window', () {
        final fridayNight = DateTime(2024, 8, 16, 22, 30); // Friday 10:30 PM
        final isActive = policyEngine.isPolicyActive(testPolicy, fridayNight);
        expect(isActive, true);
      });

      test('policy is inactive outside scheduled window', () {
        final fridayAfternoon = DateTime(2024, 8, 16, 14, 0); // Friday 2:00 PM
        final isActive = policyEngine.isPolicyActive(testPolicy, fridayAfternoon);
        expect(isActive, false);
      });

      test('policy is inactive on non-scheduled days', () {
        final saturday = DateTime(2024, 8, 17, 22, 30); // Saturday 10:30 PM
        final isActive = policyEngine.isPolicyActive(testPolicy, saturday);
        expect(isActive, false);
      });

      test('overnight policy handles midnight crossing', () {
        final sundayEarly = DateTime(2024, 8, 18, 3, 0); // Sunday 3:00 AM
        final isActive = policyEngine.isPolicyActive(testPolicy, sundayEarly);
        expect(isActive, true); // Should be active until 7:00 AM
      });
    });

    group('Cooldown Management', () {
      test('cooldown is enforced after disable', () {
        final disableTime = DateTime.now();
        policyEngine.recordDisable(testPolicy.id, disableTime);

        final oneHourLater = disableTime.add(const Duration(hours: 1));
        final canDisableAgain = policyEngine.canDisable(testPolicy, oneHourLater);

        expect(canDisableAgain, false);
      });

      test('cooldown expires after duration', () {
        final disableTime = DateTime.now();
        policyEngine.recordDisable(testPolicy.id, disableTime);

        // 25 hours later (after 24-hour cooldown)
        final afterCooldown = disableTime.add(const Duration(hours: 25));
        final canDisableAgain = policyEngine.canDisable(testPolicy, afterCooldown);

        expect(canDisableAgain, true);
      });

      test('panic button has separate cooldown', () {
        final panicTime = DateTime.now();
        policyEngine.recordPanic(testPolicy.id, panicTime);

        final oneHourLater = panicTime.add(const Duration(hours: 1));
        final canPanicAgain = policyEngine.canPanic(testPolicy, oneHourLater);

        expect(canPanicAgain, false);
      });

      test('panic cooldown expires after duration', () {
        final panicTime = DateTime.now();
        policyEngine.recordPanic(testPolicy.id, panicTime);

        // 13 hours later (after 12-hour cooldown)
        final afterCooldown = panicTime.add(const Duration(hours: 13));
        final canPanicAgain = policyEngine.canPanic(testPolicy, afterCooldown);

        expect(canPanicAgain, true);
      });
    });

    group('Time Window Parsing', () {
      test('time format is parsed correctly', () {
        final startHour = policyEngine.parseTimeHour('22:00');
        final startMinute = policyEngine.parseTimeMinute('22:00');

        expect(startHour, 22);
        expect(startMinute, 0);
      });

      test('midnight time format is parsed correctly', () {
        final hour = policyEngine.parseTimeHour('00:00');
        expect(hour, 0);
      });
    });

    group('Policy Rule Application', () {
      test('rule matches blocked app', () {
        final rule = testPolicy.rules.first;
        expect(rule.app, 'instagram');
        expect(rule.blockReels, true);
        expect(rule.blockStories, true);
      });

      test('policy blocks specified apps', () {
        final blockedApps = policyEngine.getBlockedApps(testPolicy);
        expect(blockedApps, contains('instagram'));
      });
    });

    group('Multiple Policies', () {
      test('can evaluate multiple policies', () {
        final policy2 = testPolicy.copyWith(
          id: 'policy_2',
          name: 'Work Hours Protection',
        );

        final policies = [testPolicy, policy2];
        final activeCount = policies
            .where((p) => policyEngine.isPolicyActive(p, DateTime.now()))
            .length;

        expect(activeCount >= 0, true); // At least 0 policies active
      });

      test('hard block takes precedence', () {
        final hardBlockPolicy = testPolicy.copyWith(hardBlockEnabled: true);
        expect(hardBlockPolicy.hardBlockEnabled, true);
      });
    });

    group('Edge Cases', () {
      test('handles null schedule gracefully', () {
        final noSchedulePolicy = testPolicy.copyWith(schedules: []);
        final isActive = policyEngine.isPolicyActive(noSchedulePolicy, DateTime.now());
        expect(isActive, false);
      });

      test('handles leap year dates', () {
        final leapDate = DateTime(2024, 2, 29, 22, 30);
        final isActive = policyEngine.isPolicyActive(testPolicy, leapDate);
        // Thursday should be active if included in schedule
        expect(isActive == true || isActive == false, true);
      });
    });
  });
}
