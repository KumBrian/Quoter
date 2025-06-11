part of "main.dart";

final routes = GoRouter(
  navigatorKey: _rootNavigatorKey, // Assign the global key
  initialLocation: '/', // Start at a splash screen or initial check page
  routes: [
    GoRoute(
      path: '/',
      name: 'splash', // A temporary splash or loading route
      builder: (context, state) =>
          const AuthCheckerPage(), // NEW: A simple page to check auth state
    ),
    GoRoute(
      path: '/signin',
      name: 'signin',
      builder: (context, state) => const SignIn(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUp(), // Ensure you have this page
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'favourites', // Path relative to /home
          name: 'favourites',
          builder: (context, state) => const FavoritesPage(),
        ),
        // Add other nested routes under /home if any
      ],
    ),
    // Add other top-level routes as needed
  ],
  // This is the core of auth flow management with GoRouter
  redirect: (BuildContext context, GoRouterState state) {
    // Read the current authentication state from the AuthBloc
    final authBlocState = context.read<AuthBloc>().state;
    final bool isAuthenticated = authBlocState is Authenticated;
    final bool isAuthLoading =
        authBlocState is AuthLoading || authBlocState is AuthInitial;

    // List of routes that are considered 'authentication routes'
    final bool isGoingToAuthRoute =
        state.uri.path == '/signin' || state.uri.path == '/signup';

    // --- Logic for redirection ---
    if (isAuthLoading) {
      // If auth state is still loading, allow initial route to build
      // (which should be _AuthCheckerPage to show a loading indicator)
      return null;
    }

    if (!isAuthenticated) {
      // If not authenticated, and trying to access a protected route, redirect to signin
      // (e.g., trying to go to /home but not logged in)
      return isGoingToAuthRoute ? null : '/signin';
    } else {
      // If authenticated, and trying to go to signin/signup, redirect to home
      if (isGoingToAuthRoute) {
        return '/home';
      }
    }

    // No redirect needed for any other case (e.g., authenticated user going to /home)
    return null;
  },
  // This tells GoRouter to re-evaluate redirects whenever AuthBloc's state changes
  refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
  debugLogDiagnostics: true, // Good for debugging routing issues
);
