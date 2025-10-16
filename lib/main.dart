import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/providers/ai_journal_provider.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/providers/connectivity_provider.dart';
import 'package:kuwaia/providers/notification_provider.dart';
import 'package:kuwaia/providers/shorts_provider.dart';
import 'package:kuwaia/providers/tools_provider.dart';
import 'package:kuwaia/screens/others/no_internet_screen.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/env/.env");

  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!
  );

  runApp(
    OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AiDiaryProvider()),
          ChangeNotifierProvider(create: (_) => ToolsProvider()),
          ChangeNotifierProvider(create: (_) => ShortsProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AiJournalProvider()),

        ],
        child: const KuwaiaApp(),
      ),
    ),
  );
}


class KuwaiaApp extends StatelessWidget {
  const KuwaiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final router = AppRouter(auth).router;

    final connectivity = context.watch<ConnectivityProvider>();

    if (!connectivity.hasInternet) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const NoInternetScreen(),
      );
    }

    return MaterialApp.router(
      title: 'KUWAIA',
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      theme: ThemeData(
        primaryColor: AppColors.dashaSignatureColor,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: AppColors.primaryBackgroundColor,
        appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryBackgroundColor,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: AppColors.headingTextColor,
              fontSize: 20,
              fontFamily: montserratRegular,
              fontWeight: FontWeight.w600,
            ),
          ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent, //AppColors.primaryBackgroundColor,
          showSelectedLabels: false,
          showUnselectedLabels: false
        )
      ),
    );
  }
}