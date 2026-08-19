import 'package:flutter/material.dart';
import 'package:unscroll/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:unscroll/features/home/presentation/screens/home_screen.dart';
import 'package:unscroll/features/auth/presentation/screens/login_screen.dart';
import 'package:unscroll/features/auth/presentation/screens/signup_screen.dart';
import 'package:unscroll/features/relapse_log/presentation/screens/relapse_log_screen.dart';
import 'package:unscroll/features/settings/presentation/screens/settings_screen.dart';
import 'package:unscroll/features/policies/presentation/screens/policies_list_screen.dart';

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
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      onboarding: (context) => const OnboardingScreen(),
      auth: (context) => const LoginScreen(),
      dashboard: (context) => const HomeScreen(),
      settings: (context) => const SettingsScreen(),
      policies: (context) => const PoliciesListScreen(),
      relapseLog: (context) => const RelapseLogScreen(),
      familyMode: (context) => const SizedBox.shrink(),
      accountability: (context) => const SizedBox.shrink(),
    };
  }
}
