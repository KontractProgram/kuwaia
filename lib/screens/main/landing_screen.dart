import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/screens/main/landing_nav_screen.dart';
import 'package:kuwaia/screens/onboarding/onboarding_screen.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../system/constants.dart';
import '../../widgets/texts.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.subscribePromptShare(context);
      notificationProvider.subscribeToolShare(context);
      notificationProvider.fetchAllNotifications();

      // If no user → send to auth options
      if (!authProvider.isAuthenticated) {
        context.go('/auth_options');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Case 1: Still bootstrapping or refreshing
          if (authProvider.isLoading) {
            return Center(
              child: Lottie.asset(
                threeDotsLoading,
                width: size.width*0.7
              ),
            );
          }

          // Case 2: User logged in but profile missing → safe fallback
          if (authProvider.profile == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                reusableText(text: 'No profile...',),
                shortActionButton(
                  text: 'Sign out',
                  size: MediaQuery.of(context).size,
                  onPressed: () async {
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).signOut();
                  },
                ),
              ]
            );
          }

          if (!authProvider.profile!.onboarded){
            return OnboardingScreen();
          }

          // Case 3: All good → show landing page
          return LandingNavScreen();
        },
      ),
    );
  }
}
