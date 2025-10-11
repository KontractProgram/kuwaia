import 'package:go_router/go_router.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/routing/routes.dart';
import 'package:provider/provider.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: "/",
      refreshListenable: authProvider,
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        if(auth.isLoading) return '/loading';

        final inAuthFlow = state.matchedLocation.startsWith('/auth_') ||
                           state.matchedLocation.startsWith('/continue_') ||
                           state.matchedLocation.startsWith('/password_') ||
                           state.matchedLocation.startsWith('/username') ||
                           state.matchedLocation.startsWith('/forgot_') ||
                           state.matchedLocation.startsWith('/reset_');


        if (!auth.isAuthenticated && !inAuthFlow) return '/auth_options';

        if(auth.isAuthenticated && state.matchedLocation == '/') return '/landing';

        return null;

      },

      routes: routes,
    );
  }
}
