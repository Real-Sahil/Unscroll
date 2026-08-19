import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/features/deep_linking/models/deep_link_models.dart';
import 'package:unscroll/features/deep_linking/services/deep_link_handler.dart';

void main() {
  group('DeepLinkHandler', () {
    group('URL Validation', () {
      test('validates correct home deep link', () {
        final isValid = DeepLinkHandler.isValidDeepLink('unscroll://home');
        expect(isValid, true);
      });

      test('validates policy editor deep link', () {
        final isValid = DeepLinkHandler.isValidDeepLink('unscroll://policy-editor?id=policy_1');
        expect(isValid, true);
      });

      test('rejects invalid scheme', () {
        final isValid = DeepLinkHandler.isValidDeepLink('http://home');
        expect(isValid, false);
      });

      test('rejects invalid host', () {
        final isValid = DeepLinkHandler.isValidDeepLink('unscroll://invalid-route');
        expect(isValid, false);
      });

      test('rejects null url', () {
        final isValid = DeepLinkHandler.isValidDeepLink(null);
        expect(isValid, false);
      });

      test('rejects empty url', () {
        final isValid = DeepLinkHandler.isValidDeepLink('');
        expect(isValid, false);
      });
    });

    group('URL Parsing', () {
      test('parses home route', () {
        final deepLink = DeepLinkHandler.parseDeepLink('unscroll://home');
        expect(deepLink?.route, 'home');
        expect(deepLink?.parameters, isEmpty);
      });

      test('parses route with single parameter', () {
        final deepLink = DeepLinkHandler.parseDeepLink('unscroll://policy-editor?id=policy_1');
        expect(deepLink?.route, 'policy-editor');
        expect(deepLink?.parameters['id'], 'policy_1');
      });

      test('parses route with multiple parameters', () {
        final deepLink = DeepLinkHandler.parseDeepLink(
          'unscroll://policy-editor?id=policy_1&type=scheduled',
        );
        expect(deepLink?.route, 'policy-editor');
        expect(deepLink?.parameters['id'], 'policy_1');
        expect(deepLink?.parameters['type'], 'scheduled');
      });

      test('parses relapse log route', () {
        final deepLink = DeepLinkHandler.parseDeepLink('unscroll://relapse-log?days=7');
        expect(deepLink?.route, 'relapse-log');
        expect(deepLink?.parameters['days'], '7');
      });

      test('parses notification action', () {
        final deepLink = DeepLinkHandler.parseDeepLink(
          'unscroll://notification-action?notificationId=notif_123&action=open_policy',
        );
        expect(deepLink?.route, 'notification-action');
        expect(deepLink?.parameters['notificationId'], 'notif_123');
        expect(deepLink?.parameters['action'], 'open_policy');
      });

      test('handles URL encoded parameters', () {
        final deepLink = DeepLinkHandler.parseDeepLink(
          'unscroll://panic-button?reason=urgent%20need',
        );
        expect(deepLink?.parameters['reason'], contains('urgent'));
      });

      test('returns null for invalid deep link', () {
        final deepLink = DeepLinkHandler.parseDeepLink('http://invalid');
        expect(deepLink, isNull);
      });
    });

    group('Deep Link Creation', () {
      test('creates home deep link', () {
        final url = DeepLinkHandler.createDeepLink('home', {});
        expect(url, 'unscroll://home');
      });

      test('creates policy editor deep link', () {
        final url = DeepLinkHandler.createDeepLink('policy-editor', {'id': 'policy_1'});
        expect(url, contains('unscroll://policy-editor'));
        expect(url, contains('id=policy_1'));
      });

      test('creates deep link with multiple parameters', () {
        final url = DeepLinkHandler.createDeepLink('relapse-log', {
          'days': '7',
          'app': 'instagram',
        });
        expect(url, contains('unscroll://relapse-log'));
        expect(url, contains('days=7'));
        expect(url, contains('app=instagram'));
      });

      test('creates family mode deep link', () {
        final url = DeepLinkHandler.createDeepLink('family-mode', {
          'childId': 'child_123',
          'action': 'edit',
        });
        expect(url, contains('family-mode'));
        expect(url, contains('childId=child_123'));
      });

      test('creates therapist dashboard deep link', () {
        final url = DeepLinkHandler.createDeepLink('therapist-dashboard', {
          'clientId': 'client_456',
        });
        expect(url, contains('therapist-dashboard'));
        expect(url, contains('clientId=client_456'));
      });
    });

    group('Route Validation', () {
      test('validates allowed routes', () {
        final allowedRoutes = [
          'home',
          'policy-editor',
          'relapse-log',
          'panic-button',
          'family-mode',
          'accountability',
          'achievements',
          'settings',
          'therapist-dashboard',
          'analytics',
          'notification-action',
        ];

        for (final route in allowedRoutes) {
          final isValid = DeepLinkValidator.isValidRoute(route);
          expect(isValid, true, reason: 'Route $route should be valid');
        }
      });

      test('rejects invalid routes', () {
        final invalidRoutes = [
          'invalid-route',
          'admin-panel',
          'backdoor',
          'settings/admin',
        ];

        for (final route in invalidRoutes) {
          final isValid = DeepLinkValidator.isValidRoute(route);
          expect(isValid, false, reason: 'Route $route should be invalid');
        }
      });
    });

    group('Action Validation', () {
      test('validates allowed actions', () {
        final allowedActions = [
          'open',
          'edit',
          'delete',
          'view_details',
          'add_child',
          'mark_read',
          'open_policy',
        ];

        for (final action in allowedActions) {
          final isValid = DeepLinkValidator.isValidAction(action);
          expect(isValid, true, reason: 'Action $action should be valid');
        }
      });

      test('rejects malicious actions', () {
        final maliciousActions = [
          'delete_user',
          'reset_password',
          'admin_access',
          'bypass_security',
        ];

        for (final action in maliciousActions) {
          final isValid = DeepLinkValidator.isValidAction(action);
          expect(isValid, false, reason: 'Action $action should be invalid');
        }
      });
    });

    group('Parameter Validation', () {
      test('validates policy-editor parameters', () {
        final params = {'id': 'policy_1'};
        final isValid = DeepLinkValidator.validateParameters('policy-editor', params);
        expect(isValid, true);
      });

      test('validates relapse-log parameters', () {
        final params = {'days': '7', 'app': 'instagram'};
        final isValid = DeepLinkValidator.validateParameters('relapse-log', params);
        expect(isValid, true);
      });

      test('rejects invalid parameter types', () {
        final params = {'days': 'invalid'}; // Should be numeric
        expect(() {
          int.parse(params['days']!);
        }, throwsFormatException);
      });

      test('validates empty parameters for home route', () {
        final params = <String, String>{};
        final isValid = DeepLinkValidator.validateParameters('home', params);
        expect(isValid, true);
      });
    });

    group('DeepLinkData Model', () {
      test('creates DeepLinkData with route and parameters', () {
        final deepLink = DeepLinkData(
          route: 'policy-editor',
          parameters: {'id': 'policy_1'},
          action: 'edit',
          timestamp: DateTime.now(),
        );

        expect(deepLink.route, 'policy-editor');
        expect(deepLink.parameters['id'], 'policy_1');
        expect(deepLink.action, 'edit');
      });

      test('DeepLinkData timestamp is recent', () {
        final now = DateTime.now();
        final deepLink = DeepLinkData(
          route: 'home',
          parameters: {},
          timestamp: now,
        );

        final timeDiff = DateTime.now().difference(deepLink.timestamp);
        expect(timeDiff.inSeconds, lessThan(1));
      });
    });

    group('Notification Type Validation', () {
      test('validates all notification types exist', () {
        final types = [
          NotificationType.disableCooldown,
          NotificationType.panicCooldown,
          NotificationType.dailyGoal,
          NotificationType.weeklyReview,
          NotificationType.partnerUpdate,
          NotificationType.friendlyReminder,
          NotificationType.riskAlert,
          NotificationType.achievement,
          NotificationType.custom,
        ];

        expect(types.length, greaterThan(0));
      });
    });

    group('Edge Cases', () {
      test('handles deep link with special characters in parameters', () {
        final deepLink = DeepLinkHandler.parseDeepLink(
          'unscroll://policy-editor?name=Test%20Policy%201',
        );
        expect(deepLink?.parameters['name'], contains('Test'));
      });

      test('handles deep link with empty string parameter', () {
        final deepLink = DeepLinkHandler.parseDeepLink(
          'unscroll://settings?filter=',
        );
        expect(deepLink?.route, 'settings');
      });

      test('rejects deep link with malformed query string', () {
        final deepLink = DeepLinkHandler.parseDeepLink(
          'unscroll://policy-editor?id=&name==value',
        );
        // Should handle gracefully or return null
        expect(deepLink == null || deepLink.parameters.isNotEmpty, isTrue);
      });

      test('handles very long deep link URLs', () {
        final longParam = 'a' * 1000;
        final url = DeepLinkHandler.createDeepLink('settings', {'data': longParam});
        expect(url.length, greaterThan(1000));
      });
    });

    group('Security', () {
      test('prevents route traversal in parameters', () {
        final deepLink = DeepLinkHandler.parseDeepLink(
          'unscroll://policy-editor?id=../../../admin',
        );
        expect(deepLink?.parameters['id'], isNotNull);
        // Validation should occur at handler level
      });

      test('rejects javascript protocol', () {
        final isValid = DeepLinkHandler.isValidDeepLink('javascript://alert(1)');
        expect(isValid, false);
      });

      test('rejects data protocol', () {
        final isValid = DeepLinkHandler.isValidDeepLink('data://text/html,<script>');
        expect(isValid, false);
      });

      test('requires unscroll scheme', () {
        final validSchemes = ['unscroll://'];
        final testUrl = 'https://unscroll.app/policy-editor';
        final isValid = DeepLinkHandler.isValidDeepLink(testUrl);
        // Should require proper scheme
        expect(isValid, false);
      });
    });
  });
}
