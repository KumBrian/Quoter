import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
// Import Blocs and Cubits (needed for MultiBlocProvider)
import 'package:quoter/bloc/cubit/category_cubit.dart';
import 'package:quoter/bloc/cubit/category_suggestion_cubit.dart';
import 'package:quoter/bloc/cubit/share_image_cubit.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
// Import service locator
import 'package:quoter/core/service_locator.dart';
import 'package:quoter/firebase_options.dart';
import 'package:quoter/presentation/pages/favorites_page.dart';
import 'package:quoter/presentation/pages/homepage.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext contextMain) {
    GoRouter router = GoRouter(routes: [
      GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'favourites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ]),
    ], initialLocation: '/home');

    // No need for RepositoryProvider now, as repositories are managed by GetIt.
    return MultiBlocProvider(
      providers: [
        // Retrieve instances from GetIt
        BlocProvider(
            create: (context) =>
                sl<QuotesBloc>()..add(LoadQuotes(category: ''))),
        BlocProvider(create: (context) => sl<SwiperCubit>()),
        BlocProvider(create: (context) => sl<CategoryCubit>()),
        BlocProvider(create: (context) => sl<CategorySuggestionCubit>()),
        BlocProvider(create: (context) => sl<ShareImageCubit>()),
        BlocProvider(
          create: (context) => sl<LikedQuotesBloc>()
            ..add(
              LoadLikedQuotes(),
            ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
