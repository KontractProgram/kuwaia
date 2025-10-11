import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/screens/auth/forgot_password_screen.dart';
import 'package:kuwaia/screens/auth/reset_password_screen.dart';
import 'package:kuwaia/screens/main/in_tool/diary_tool_learning_video_screen.dart';
import 'package:kuwaia/screens/main/in_tool/log_details_screen.dart';
import 'package:kuwaia/screens/main/in_tool/my_prompts_screen.dart';
import 'package:kuwaia/screens/main/in_tool/my_videos_screen.dart';
import 'package:kuwaia/screens/main/in_tool/official_use_case_screen.dart';
import 'package:kuwaia/screens/main/in_tool/tool_view_screen.dart';
import 'package:kuwaia/screens/main/landing_nav_screen.dart';
import 'package:kuwaia/screens/main/tools_in_group_screen.dart';
import 'package:kuwaia/screens/onboarding/onboarding_screen.dart';
import '../models/community/news.dart';
import '../models/group.dart';
import '../models/tool.dart';
import '../screens/auth/auth_options_screen.dart';
import 'package:kuwaia/screens/auth/continue_with_email_screen.dart';
import 'package:kuwaia/screens/auth/password_to_login_screen.dart';
import 'package:kuwaia/screens/auth/password_to_register_screen.dart';
import 'package:kuwaia/screens/auth/username_screen.dart';
import 'package:kuwaia/screens/main/landing_screen.dart';
import 'package:kuwaia/screens/others/loading_screen.dart';
import '../screens/main/in_journal/view_news_screen.dart';
import '../screens/main/in_tool/my_notes_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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
  toolView,
  myPrompts,
  myNotes,
  myVideos,
  officialUseCase,
  logDetails,
  viewNews,
  forgotPassword,
  resetPasswordVerification,
  resetPassword,
  diaryToolLearningVideo
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

  GoRoute(
    path: '/forgot_password',
    name: AppRoute.forgotPassword.name,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),

  GoRoute(
      path: '/reset_password',
      name: AppRoute.resetPassword.name,
    builder: (context, state) {
      final token = state.uri.queryParameters['token'] ?? '';
      return ResetPasswordScreen(token: token);
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
    path: '/tools_in_group',
    name: AppRoute.toolsInGroup.name,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      final group = extra['group'] as Group;
      final tools = extra['tools'] as List<Tool>;

      return ToolsInGroupScreen(group: group, tools: tools);
    },
  ),

  GoRoute(
    path: '/tool_view',
    name: AppRoute.toolView.name,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      final tool = extra['tool'] as Tool;
      return ToolViewScreen(tool: tool);
    }
  ),
  GoRoute(
    path: '/my_prompts',
    name: AppRoute.myPrompts.name,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      final tool = extra['tool'] as Tool;
      return MyPromptsScreen(tool: tool);
    }
  ),
  GoRoute(
      path: '/my_notes',
      name: AppRoute.myNotes.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tool = extra['tool'] as Tool;
        return MyNotesScreen(tool: tool);
      }
  ),
  GoRoute(
      path: '/my_videos',
      name: AppRoute.myVideos.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tool = extra['tool'] as Tool;
        return MyVideosScreen(tool: tool);
      }
  ),
  GoRoute(
      path: '/official_use_case',
      name: AppRoute.officialUseCase.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tool = extra['tool'] as Tool;
        return OfficialUseCaseScreen(tool: tool);
      }
  ),
  GoRoute(
      path: '/log_details',
      name: AppRoute.logDetails.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final tool = extra['tool'] as Tool;
        return LogDetailsScreen(tool: tool);
      }
  ),

  GoRoute(
    path: '/view_news',
    name: AppRoute.viewNews.name,
    builder: (context, state){
      final extra = state.extra as Map<String, dynamic>;
      final news = extra['news'] as News;
      return ViewNewsScreen(news: news);
    }
  ),

  GoRoute(
      path: '/diary_tool_learning_video',
      name: AppRoute.diaryToolLearningVideo.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final videoLink = extra['videoLink'] as String;
        return DiaryToolLearningVideoScreen(videoLink: videoLink);
      }
  ),


];
