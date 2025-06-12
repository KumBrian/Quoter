// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
// Import Blocs and Cubits
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/bloc/cubit/category_cubit.dart';
import 'package:quoter/bloc/cubit/category_suggestion_cubit.dart';
import 'package:quoter/bloc/cubit/show_password_cubit.dart';
import 'package:quoter/bloc/cubit/user_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
// Import service locator
import 'package:quoter/core/service_locator.dart'; // Make sure this initializes all your dependencies
import 'package:quoter/firebase_options.dart';
import 'package:quoter/presentation/pages/auth_checker_page.dart';
import 'package:quoter/presentation/pages/favorites_page.dart';
import 'package:quoter/presentation/pages/homepage.dart';
import 'package:quoter/presentation/pages/sign_in_page.dart';
import 'package:quoter/presentation/pages/sign_up_page.dart';

// You don't need to import pages here if they are only used in my_routes.dart
// import 'package:quoter/presentation/pages/auth_checker_page.dart';
// import 'package:quoter/presentation/pages/favorites_page.dart';
// import 'package:quoter/presentation/pages/homepage.dart';
// import 'package:quoter/presentation/pages/sign_in_page.dart';
// import 'package:quoter/presentation/pages/sign_up_page.dart';

import 'core/helpers.dart'; // Assuming this has other helpers you need

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initDependencies(); // Initialize all your dependencies using GetIt

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  runApp(const MyApp());
}

// Global Navigator Key for context access outside widgets (e.g., in redirects)
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Declare these as late final, but they will be initialized in initState
  late final GoRouter _router;
  late final GoRouterRefreshStream _goRouterRefreshStream;
  late final AuthBloc
      _authBlocInstance; // NEW: Hold reference to the AuthBloc instance from GetIt

  @override
  void initState() {
    super.initState();
    // Get the AuthBloc instance from GetIt
    _authBlocInstance = sl<AuthBloc>();

    // Initialize GoRouterRefreshStream with the AuthBloc's stream
    _goRouterRefreshStream = GoRouterRefreshStream(_authBlocInstance.stream);

    // Initialize GoRouter, passing the refreshListenable
    _router = _buildRouter(); // Call a helper method to build the router
  }

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey, // Keep your global key
      refreshListenable:
          _goRouterRefreshStream, // NEW: Crucial for GoRouter to react
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
          builder: (context, state) => const SignIn(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUp(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'favourites',
              name: 'favourites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        // ... (Add any other top-level routes you have)
      ],
      redirect: (context, state) {
        // Access AuthBloc's current state via context.read
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;

        final bool isAuthenticated = authState is Authenticated;
        final bool isUnauthenticated = authState is Unauthenticated;
        final bool isAuthLoading = authState is AuthLoading;

        // Paths that don't require authentication, or are part of the initial check
        final bool isOnSignIn = state.matchedLocation == '/signin';
        final bool isOnSignUp = state.matchedLocation == '/signup';
        final bool isOnAuthChecker = state.matchedLocation == '/';

        // If still loading auth state, only allow access to auth checker page
        if (isAuthLoading) {
          return isOnAuthChecker
              ? null
              : '/'; // Stay on auth checker until state is known
        }

        // If authenticated, prevent access to sign-in/sign-up/auth checker pages
        if (isAuthenticated) {
          if (isOnSignIn || isOnSignUp || isOnAuthChecker) {
            return '/home'; // Redirect to home if authenticated
          }
        }
        // If unauthenticated, redirect to sign-in from protected routes
        else if (isUnauthenticated) {
          if (!isOnSignIn && !isOnSignUp && !isOnAuthChecker) {
            return '/signin';
          }
        }

        // No redirect needed, proceed to the requested location
        return null;
      },
    );
  }

  @override
  void dispose() {
    // Close the AuthBloc instance obtained from GetIt
    _authBlocInstance.close();
    // Close other BLoCs if they are not singletons and you're manually managing them.
    // If your GetIt setup registers them as singletons and manages their lifecycle,
    // you might not need to dispose them here if GetIt handles it on app shutdown.
    // However, explicitly closing them is safer to prevent memory leaks if they have streams/listeners.
    sl<QuotesBloc>()
        .close(); // Example: if QuotesBloc is also not singleton with auto-dispose
    sl<CategoryCubit>().close(); // and so on for other cubits/blocs
    sl<ShowPasswordCubit>().close();
    sl<CategorySuggestionCubit>().close();
    sl<LikedQuotesBloc>().close();
    sl<UserCubit>().close(); // Make sure to close UserCubit as well

    _goRouterRefreshStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide AuthBloc from the instance obtained in initState
        BlocProvider<AuthBloc>.value(
          value:
              _authBlocInstance, // Use the instance held in _authBlocInstance
        ),
        // UserCubit now gets its initial state from AuthBloc's Authenticated state
        // and also from the AuthBloc instance passed in initstate.
        BlocProvider<UserCubit>(
          create: (context) {
            final authBloc =
                context.read<AuthBloc>(); // Get the provided AuthBloc
            final authState = authBloc.state;
            final userCubit =
                sl<UserCubit>(); // Get the UserCubit instance from GetIt

            // Listen to AuthBloc's stream to update UserCubit when auth state changes
            authBloc.stream.listen((state) {
              if (state is Authenticated) {
                userCubit.setUser(state.user);
              } else if (state is Unauthenticated) {
                userCubit
                    .clearUser(); // Assuming a clearUser method in UserCubit
              }
            });

            // Initialize UserCubit based on current AuthBloc state
            if (authState is Authenticated) {
              userCubit.setUser(authState.user);
            } else if (authState is Unauthenticated) {
              userCubit.clearUser(); // Clear user if initially unauthenticated
            }

            return userCubit;
          },
        ),
        // Provide other Blocs/Cubits as before, getting them from GetIt
        BlocProvider<QuotesBloc>(
          create: (context) => sl<QuotesBloc>()..add(LoadQuotes(category: '')),
        ),
        BlocProvider<CategoryCubit>(
          create: (context) => sl<CategoryCubit>(),
        ),
        BlocProvider<ShowPasswordCubit>(
          create: (context) => sl<ShowPasswordCubit>(),
        ),
        BlocProvider<CategorySuggestionCubit>(
          create: (context) => sl<CategorySuggestionCubit>(),
        ),
        BlocProvider<LikedQuotesBloc>(
          create: (context) => sl<LikedQuotesBloc>()..add(LoadLikedQuotes()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}

// Your my_routes.dart remains mostly the same, as the router configuration is now in main.dart
// You can remove the GoRouter setup from my_routes.dart and only keep other specific routes
// or just keep it as a partial file if you want to reuse it, but make sure the GoRouter
// instance is configured in main.
/*
// lib/my_routes.dart (Example of what it *could* contain if you kept it as a partial)
part of 'main.dart'; // Make sure this is here if you keep it as a part file

// You can define other nested routes or sub-routes here if desired,
// but the main GoRouter instance is now created directly in _MyAppState.
// For instance:
final List<GoRoute> appRoutes = [
  // ... other routes that might be dynamically generated or grouped
];
*/
