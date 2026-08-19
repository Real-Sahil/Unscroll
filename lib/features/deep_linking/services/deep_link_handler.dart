import 'package:flutter/material.dart';
import 'package:unscroll/features/deep_linking/models/deep_link_models.dart';

class DeepLinkHandler {
  static const String scheme = 'unscroll';

  static bool isValidDeepLink(String url) {
    return url.startsWith('$scheme://');
  }

  static DeepLinkData parseDeepLink(String url) {
    if (!isValidDeepLink(url)) {
      throw ArgumentError('Invalid deep link format: $url');
    }

    final uri = Uri.parse(url);
    final route = uri.host;
    final parameters = Map<String, String>.from(uri.queryParameters);

    return DeepLinkData(
      route: route,
      parameters: parameters,
      timestamp: DateTime.now(),
    );
  }

  static String createDeepLink(
    String route, {
    Map<String, String>? parameters,
    String? action,
  }) {
    final params = parameters ?? {};
    if (action != null) {
      params['action'] = action;
    }

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    if (queryString.isEmpty) {
      return '$scheme://$route';
    }
    return '$scheme://$route?$queryString';
  }

  static Future<void> handleDeepLink(
    BuildContext context,
    DeepLinkData data,
  ) async {
    switch (data.route) {
      case 'home':
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        break;

      case 'policy-editor':
        final policyId = data.parameters['policyId'];
        Navigator.of(context).pushNamed(
          '/policy-editor',
          arguments: policyId,
        );
        break;

      case 'relapse-log':
        Navigator.of(context).pushNamed('/relapse-log');
        break;

      case 'panic-button':
        // Trigger panic button action
        _handlePanicButtonTrigger(context);
        break;

      case 'family-mode':
        Navigator.of(context).pushNamed('/family-dashboard');
        break;

      case 'accountability':
        Navigator.of(context).pushNamed('/accountability');
        break;

      case 'achievements':
        Navigator.of(context).pushNamed('/achievements');
        break;

      case 'settings':
        Navigator.of(context).pushNamed('/settings');
        break;

      case 'therapist-dashboard':
        Navigator.of(context).pushNamed('/therapist-dashboard');
        break;

      case 'analytics':
        Navigator.of(context).pushNamed('/analytics');
        break;

      case 'notification-action':
        final action = data.parameters['action'];
        _handleNotificationAction(context, action);
        break;

      default:
        // Unknown route, navigate to home
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  static void _handlePanicButtonTrigger(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Panic Button'),
        content: const Text(
          'This will immediately hard-block all protected apps and trigger your panic cooldown.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Execute panic button logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Panic mode activated'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Activate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void _handleNotificationAction(BuildContext context, String? action) {
    if (action == null) return;

    switch (action) {
      case 'view-summary':
        Navigator.of(context).pushNamed('/accountability-summary');
        break;

      case 'view-analytics':
        Navigator.of(context).pushNamed('/analytics');
        break;

      case 'view-achievement':
        Navigator.of(context).pushNamed('/achievements');
        break;

      case 'manage-family':
        Navigator.of(context).pushNamed('/family-dashboard');
        break;

      default:
        break;
    }
  }
}

class DeepLinkValidator {
  static bool isValidRoute(String route) {
    const validRoutes = [
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

    return validRoutes.contains(route);
  }

  static bool isValidAction(String action) {
    const validActions = [
      'view-summary',
      'view-analytics',
      'view-achievement',
      'manage-family',
      'disable-protection',
      'panic-mode',
    ];

    return validActions.contains(action);
  }

  static List<String> validateParameters(
    String route,
    Map<String, String> parameters,
  ) {
    final errors = <String>[];

    if (route == 'policy-editor' && parameters.containsKey('policyId')) {
      if (parameters['policyId']!.isEmpty) {
        errors.add('policyId cannot be empty');
      }
    }

    return errors;
  }
}
