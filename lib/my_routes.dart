import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/core/helpers.dart';
import 'package:quoter/presentation/pages/auth_checker_page.dart';
import 'package:quoter/presentation/pages/homepage.dart';
import 'package:quoter/presentation/pages/sign_in_page.dart';
import 'package:quoter/presentation/pages/sign_up_page.dart';

class AppRouter {
  static GoRouter setupRouter(GoRouterRefreshStream authStream) {
    return GoRouter(
      refreshListenable:
          authStream, // This tells GoRouter to rebuild on stream changes
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'authChecker',
          builder: (context, state) => const AuthCheckerPage(),
        ),
        GoRoute(
          path: '/signin',
          name: 'signin',
          builder: (context, state) => const SignIn(), // Your actual SignInPage
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUp(), // Your actual SignUpPage
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(), // Your actual HomePage
        ),
        // Add more routes as needed
      ],
      redirect: (context, state) {
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;

        // Determine if the user is authenticated from the BLoC's current state
        final bool isAuthenticated = authState is Authenticated;
        final bool isUnauthenticated = authState is Unauthenticated;
        final bool isAuthLoading = authState is AuthLoading;

        // Paths that don't require authentication
        final bool isOnSignIn = state.matchedLocation == '/signin';
        final bool isOnSignUp = state.matchedLocation == '/signup';
        final bool isOnAuthChecker = state.matchedLocation == '/';

        // If still loading auth state, allow access to auth checker page only
        if (isAuthLoading) {
          return isOnAuthChecker
              ? null
              : '/'; // Stay on auth checker until state is known
        }

        // If authenticated, prevent access to sign-in/sign-up pages
        if (isAuthenticated) {
          if (isOnSignIn || isOnSignUp || isOnAuthChecker) {
            return '/home'; // Redirect to home if authenticated
          }
        } else if (isUnauthenticated) {
          // If unauthenticated, redirect to sign-in from protected routes
          if (!isOnSignIn && !isOnSignUp && !isOnAuthChecker) {
            return '/signin';
          }
        }

        // No redirect needed, proceed to the requested location
        return null;
      },
    );
  }
}
