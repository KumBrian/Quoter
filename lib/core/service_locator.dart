import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/bloc/cubit/category_cubit.dart';
import 'package:quoter/bloc/cubit/category_suggestion_cubit.dart';
import 'package:quoter/bloc/cubit/share_image_cubit.dart'; // Don't forget this new cubit!
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/bloc/cubit/user_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart'; // Adjust paths as needed
import 'package:quoter/data/data_provider/data_provider.dart';
import 'package:quoter/data/data_provider/firestore_services.dart';
import 'package:quoter/data/repository/auth_repository.dart';
import 'package:quoter/data/repository/category_repository.dart';
import 'package:quoter/data/repository/hive_quote.dart';
import 'package:quoter/data/repository/quotes_repository.dart';

final sl = GetIt.instance; // 'sl' is a common convention for service locator

Future<void> initDependencies() async {
  // Initialize Hive for LikedQuotesRepository
  await LikedQuotesRepository.init();

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  // Register Firebase Firestore instance as a singleton
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<FirestoreService>(
    () => FirestoreService(
        firestore: sl()), // sl() resolves FirebaseFirestore.instance
  );

  // --- Data Providers ---
  sl.registerFactory<QuotesDataProvider>(() => QuotesDataProvider());
  sl.registerLazySingleton<CategoryDataProvider>(() => CategoryDataProvider());

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepository(firebaseAuth: sl(), firestoreService: sl()));
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepository());
  sl.registerLazySingleton<QuotesRepository>(
      () => QuotesRepository(quotesDataProvider: sl()));
  sl.registerLazySingleton<LikedQuotesRepository>(
      () => LikedQuotesRepository());

  // --- Cubits & Blocs ---
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));
  sl.registerFactory<UserCubit>(() => UserCubit(firestoreService: sl()));
  sl.registerFactory<QuotesBloc>(() => QuotesBloc(sl()));
  sl.registerFactory<LikedQuotesBloc>(() => LikedQuotesBloc(sl()));
  sl.registerFactory<CategoryCubit>(() => CategoryCubit());
  sl.registerFactory<CategorySuggestionCubit>(() => CategorySuggestionCubit());
  sl.registerFactory<SwiperCubit>(() => SwiperCubit());
  sl.registerFactory<ShareImageCubit>(() => ShareImageCubit());
}
