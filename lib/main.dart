import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/providers/ai_journal_provider.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/providers/connectivity_provider.dart';
import 'package:kuwaia/providers/notification_provider.dart';
import 'package:kuwaia/providers/updates_provider.dart';
import 'package:kuwaia/providers/tools_provider.dart';
import 'package:kuwaia/providers/version_provider.dart';
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
          ChangeNotifierProvider(create: (_) => UpdatesProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => AiJournalProvider()),
          ChangeNotifierProvider(create: (_) => VersionProvider()),

        ],
        child: const KuwaiaApp(),
      ),
    ),
  );
}

class VersionInitializer extends StatefulWidget {
  final Widget child;
  const VersionInitializer({super.key, required this.child});

  @override
  State<VersionInitializer> createState() => _VersionInitializerState();
}

class _VersionInitializerState extends State<VersionInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure the fetch happens after build completes
    // and context is stable.
    Future.microtask(() {
      Provider.of<VersionProvider>(context, listen: false)
          .fetchVersionDates(context);

      // Since this check is fast, we can set initialized to true immediately
      // if you don't need a loading spinner here.
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return the child immediately. The notifications/dialogs will appear
    // asynchronously if needed. If you had a loading spinner, you would return it here
    // while !_initialized.
    return widget.child;
  }
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

    return VersionInitializer(
      child: MaterialApp.router(
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
      ),
    );
  }
}