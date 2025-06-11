import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
// Import Blocs and Cubits (needed for MultiBlocProvider)
import 'package:quoter/bloc/cubit/category_cubit.dart';
import 'package:quoter/bloc/cubit/category_suggestion_cubit.dart';
import 'package:quoter/bloc/cubit/user_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
// Import service locator
import 'package:quoter/core/service_locator.dart';
import 'package:quoter/firebase_options.dart';
import 'package:quoter/presentation/pages/auth_flow.dart';
import 'package:quoter/presentation/pages/favorites_page.dart';
import 'package:quoter/presentation/pages/homepage.dart';
import 'package:quoter/presentation/pages/sign_in_page.dart';
import 'package:quoter/presentation/pages/sign_up_page.dart';

import 'core/helpers.dart';

part 'my_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize all your dependencies using GetIt
  await initDependencies();

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
  late final GoRouter _router; // Declare router as late final

  @override
  void initState() {
    super.initState();
    // Initialize GoRouter in initState as it depends on context (via refreshListenable)
    _router = routes;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide AuthBloc at the very top of the widget tree
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        // UserCubit will now get its initial state from AuthBloc's Authenticated state
        BlocProvider<UserCubit>(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              return sl<UserCubit>()
                ..setUser(
                    authState.user); // Initialize UserCubit with UserModel
            }
            return sl<
                UserCubit>(); // Or create an empty UserCubit if not authenticated yet
          },
        ),
        // Provide other Blocs/Cubits as before
        BlocProvider<QuotesBloc>(
          create: (context) => sl<QuotesBloc>()..add(LoadQuotes(category: '')),
        ),
        BlocProvider<CategoryCubit>(
          create: (context) => sl<CategoryCubit>(),
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
