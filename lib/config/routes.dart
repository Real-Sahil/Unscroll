import 'package:flutter/material.dart';
import 'package:unscroll/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:unscroll/features/home/presentation/screens/home_screen.dart';
import 'package:unscroll/features/auth/presentation/screens/login_screen.dart';
import 'package:unscroll/features/auth/presentation/screens/signup_screen.dart';
import 'package:unscroll/features/relapse_log/presentation/screens/relapse_log_screen.dart';
import 'package:unscroll/features/settings/presentation/screens/settings_screen.dart';
import 'package:unscroll/features/settings/presentation/screens/premium_screen.dart';
import 'package:unscroll/features/policies/presentation/screens/policies_list_screen.dart';
import 'package:unscroll/features/profile/presentation/screens/profile_screen.dart';
import 'package:unscroll/features/profile/presentation/screens/achievements_screen.dart';
import 'package:unscroll/features/family_mode/presentation/screens/family_dashboard_screen.dart';
import 'package:unscroll/features/family_mode/presentation/screens/add_child_screen.dart';
import 'package:unscroll/features/family_mode/presentation/screens/child_protection_screen.dart';
import 'package:unscroll/features/family_mode/presentation/screens/family_child_summary_screen.dart';
import 'package:unscroll/features/accountability/presentation/screens/accountability_screen.dart';
import 'package:unscroll/features/accountability/presentation/screens/add_partner_screen.dart';
import 'package:unscroll/features/accountability/presentation/screens/accountability_summaries_screen.dart';
import 'package:unscroll/features/policies/presentation/screens/policy_editor_screen.dart';
import 'package:unscroll/features/therapist/presentation/screens/therapist_dashboard_screen.dart';
import 'package:unscroll/features/family_mode/presentation/screens/edit_child_screen.dart';
import 'package:unscroll/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:unscroll/features/deep_linking/presentation/screens/notification_preferences_screen.dart';
import 'package:unscroll/features/panic_button/presentation/screens/panic_button_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String policies = '/policies';
  static const String relapseLog = '/relapse-log';
  static const String profile = '/profile';
  static const String achievements = '/achievements';
  static const String familyMode = '/family-mode';
  static const String familyDashboard = '/family-dashboard';
  static const String familyAddChild = '/family-add-child';
  static const String familyEditChild = '/family-edit-child';
  static const String familyChildSummary = '/family-child-summary';
  static const String childProtection = '/child-protection';
  static const String accountability = '/accountability';
  static const String accountabilityAddPartner = '/accountability-add-partner';
  static const String accountabilitySummary = '/accountability-summary';
  static const String policyEditor = '/policy-editor';
  static const String therapistDashboard = '/therapist-dashboard';
  static const String panicButton = '/panic-button';
  static const String analytics = '/analytics';
  static const String notificationPreferences = '/notification-preferences';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      onboarding: (context) => const OnboardingScreen(),
      auth: (context) => const LoginScreen(),
      dashboard: (context) => const HomeScreen(),
      settings: (context) => const SettingsScreen(),
      premium: (context) => const PremiumScreen(),
      policies: (context) => const PoliciesListScreen(),
      relapseLog: (context) => const RelapseLogScreen(),
      profile: (context) => const ProfileScreen(),
      achievements: (context) => const AchievementsScreen(),
      familyMode: (context) => const FamilyDashboardScreen(),
      familyDashboard: (context) => const FamilyDashboardScreen(),
      familyAddChild: (context) => const AddChildScreen(),
      familyEditChild: (context) => const EditChildScreen(),
      familyChildSummary: (context) {
        // Extract childId from navigation arguments
        return const FamilyChildSummaryScreen(childId: '');
      },
      childProtection: (context) => const ChildProtectionScreen(),
      accountability: (context) => const AccountabilityScreen(),
      accountabilityAddPartner: (context) => const AddPartnerScreen(),
      accountabilitySummary: (context) => const AccountabilitySummariesScreen(),
      policyEditor: (context) => const PolicyEditorScreen(),
      therapistDashboard: (context) => const TherapistDashboardScreen(),
      panicButton: (context) => const PanicButtonScreen(),
      analytics: (context) => const AnalyticsScreen(),
      notificationPreferences: (context) => const NotificationPreferencesScreen(),
    };
  }
}
