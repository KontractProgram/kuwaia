import 'package:go_router/go_router.dart';
import 'package:kuwaia/screens/main/landing_nav_screen.dart';
import 'package:kuwaia/screens/main/tools_in_group_screen.dart';
import 'package:kuwaia/screens/onboarding/onboarding_screen.dart';

import '../models/Group.dart';
import '../models/tools.dart';
import '../screens/auth/auth_options_screen.dart';
import 'package:kuwaia/screens/auth/continue_with_email_screen.dart';
import 'package:kuwaia/screens/auth/password_to_login_screen.dart';
import 'package:kuwaia/screens/auth/password_to_register_screen.dart';
import 'package:kuwaia/screens/auth/username_screen.dart';
import 'package:kuwaia/screens/main/landing_screen.dart';
import 'package:kuwaia/screens/others/loading_screen.dart';


enum AppRoute {
  authOptions,
  continueWithEmail,
  passwordToLogin,
  passwordToRegister,
  username,
  landing,
  landingNav,
  loading,
  onboarding,
  toolsInGroup,
}

final routes = [
  // Auth routes
  GoRoute(
    path: '/auth_options',
    name: AppRoute.authOptions.name,
    builder: (context, state) => const AuthOptionsScreen(),
  ),
  GoRoute(
    path: '/continue_with_email',
    name: AppRoute.continueWithEmail.name,
    builder: (context, state) => const ContinueWithEmailScreen(),
  ),
  GoRoute(
    path: '/password_to_login/:email',
    name: AppRoute.passwordToLogin.name,
    builder: (context, state) {
      final email = state.pathParameters['email']!;
      return PasswordToLoginScreen(email: email);
    },
  ),
  GoRoute(
    path: '/password_to_register/:email/:username',
    name: AppRoute.passwordToRegister.name,
    builder: (context, state) {
      final email = state.pathParameters['email']!;
      final username = state.pathParameters['username']!;
      return PasswordToRegisterScreen(email: email, username: username);
    },
  ),
  GoRoute(
    path: '/username/:email',
    name: AppRoute.username.name,
    builder: (context, state) {
      final email = state.pathParameters['email']!;
      return UsernameScreen(email: email);
    },
  ),

  // In-app routes
  GoRoute(
    path: '/landing',
    name: AppRoute.landing.name,
    builder: (context, state) => const LandingScreen(),
  ),
  GoRoute(
    path: '/landing_nav',
    name: AppRoute.landingNav.name,
    builder: (context, state) => const LandingNavScreen(),
  ),
  GoRoute(
    path: '/loading',
    name: AppRoute.loading.name,
    builder: (context, state) => const LoadingScreen(),
  ),
  GoRoute(
    path: '/onboarding',
    name: AppRoute.onboarding.name,
    builder: (context, state) => const OnboardingScreen(),
  ),
  GoRoute(
    path: '/tools_in_group/:group/:tools',
    name: AppRoute.toolsInGroup.name,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      final group = extra['group'] as Group;
      final tools = extra['tools'] as List<Tools>;

      return ToolsInGroupScreen(group: group, tools: tools);
    },
  ),
];