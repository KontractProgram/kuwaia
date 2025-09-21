import 'package:go_router/go_router.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/routing/routes.dart';
import 'package:provider/provider.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  GoRouter get router {
    return GoRouter(
      initialLocation: "/",
      refreshListenable: authProvider,
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        if(auth.isLoading) return '/loading';
        if(auth.isAuthenticated) return '/landing';

        final inAuthFlow = state.matchedLocation.startsWith('/auth_') ||
                           state.matchedLocation.startsWith('/continue_') ||
                           state.matchedLocation.startsWith('/password_') ||
                           state.matchedLocation.startsWith('/username');

        if (!auth.isAuthenticated && !inAuthFlow) return '/auth_options';

        return null;

      },

      routes: routes,
    );
  }
}
