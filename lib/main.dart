import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/bloc/quotes_bloc.dart';
import 'package:quoter/data/data_provider/data_provider.dart';
import 'package:quoter/data/repository/hive_quote.dart';
import 'package:quoter/data/repository/quotes_repository.dart';
import 'package:quoter/presentation/pages/favorites_page.dart';
import 'package:quoter/presentation/pages/homepage.dart';

import 'bloc/cubit/share_image_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LikedQuotesRepository.init();
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
    return RepositoryProvider(
      create: (context) =>
          QuotesRepository(quotesDataProvider: QuotesDataProvider()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  QuotesBloc(context.read<QuotesRepository>())),
          BlocProvider(create: (context) => SwiperCubit()),
          BlocProvider(create: (context) => ShareImageCubit()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
