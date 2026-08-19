import 'package:flutter/material.dart';
import 'package:unscroll/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:unscroll/features/home/presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String policies = '/policies';
  static const String relapseLog = '/relapse-log';
  static const String familyMode = '/family-mode';
  static const String accountability = '/accountability';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      onboarding: (context) => const OnboardingScreen(),
      auth: (context) => const SizedBox.shrink(),
      dashboard: (context) => const HomeScreen(),
      settings: (context) => const SizedBox.shrink(),
      policies: (context) => const SizedBox.shrink(),
      relapseLog: (context) => const SizedBox.shrink(),
      familyMode: (context) => const SizedBox.shrink(),
      accountability: (context) => const SizedBox.shrink(),
    };
  }
}
