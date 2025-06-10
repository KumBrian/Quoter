import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quoter/bloc/cubit/category_cubit.dart';
import 'package:quoter/bloc/cubit/category_suggestion_cubit.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/data/repository/category_repository.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/bottom_controls.dart';
import 'package:quoter/presentation/components/categories_dropdown.dart';
import 'package:quoter/presentation/components/custom_button.dart';
import 'package:quoter/presentation/components/custom_text_field.dart';
import 'package:quoter/presentation/components/failure_widget.dart';
import 'package:quoter/presentation/components/loading_rings.dart';
import 'package:quoter/presentation/components/quote_swiper.dart';
import 'package:quoter/presentation/extensions/string_extensions.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final SwiperController swiperController = SwiperController();
  final TextEditingController categoryDescriptionController =
      TextEditingController();
  int? _lastLikedIndex;

  @override
  void initState() {
    super.initState();
  }

  void displaySnackBar(String text) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: kSecondaryDark.withValues(alpha: 0.9),
        textStyle: GoogleFonts.getFont(
          'Montserrat',
          color: kPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        message: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      drawer: SafeArea(
        child: Drawer(
          width: 300,
          backgroundColor: kPrimaryDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 30,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.cancel_sharp,
                    size: 50,
                    color: kSecondaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                    context.go('/home/favourites');
                  },
                  child: Row(
                    children: [
                      Text(
                        'FAVOURITES',
                        style: GoogleFonts.getFont(
                          'Montserrat',
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CategoriesDropdown(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                    showModalBottomSheet(
                        context: context,
                        elevation: 0,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        sheetAnimationStyle:
                            AnimationStyle(curve: Curves.decelerate),
                        barrierColor: Colors.transparent,
                        builder: (context) {
                          return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 40),
                              height: 700,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: kPrimaryLighterDark,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  spacing: 20,
                                  children: [
                                    CustomTextField(
                                        categoryDescriptionController:
                                            categoryDescriptionController),
                                    CustomButton(
                                      label: 'get suggestions',
                                      onPressed: () async {
                                        try {
                                          context
                                              .read<CategorySuggestionCubit>()
                                              .setLoading();
                                          context
                                              .read<CategorySuggestionCubit>()
                                              .updateSuggestion(
                                                  await CategoryRepository()
                                                      .fetchCategory(
                                                          categoryDescriptionController
                                                              .text
                                                              .toTitleCase));
                                        } catch (e) {
                                          displaySnackBar('$e');
                                        }
                                      },
                                      icon: HugeIcons
                                          .strokeRoundedArtificialIntelligence08,
                                    ),
                                    BlocBuilder<CategorySuggestionCubit,
                                        CategorySuggestionState>(
                                      builder: (context, categoryState) {
                                        if (categoryState
                                            is CategorySuggestionLoading) {
                                          return const LoadingRings(
                                            size: 50,
                                          );
                                        }

                                        if (categoryState
                                            is CategorySuggestionError) {
                                          return FailureWidget(size: size);
                                        }
                                        if (categoryState
                                            is CategorySuggestionLoaded) {
                                          return InkWell(
                                            onTap: () {
                                              context
                                                  .read<CategoryCubit>()
                                                  .updateCategory(categoryState
                                                      .suggestion.toTitleCase);
                                              context
                                                  .read<
                                                      CategorySuggestionCubit>()
                                                  .clearSuggestion();
                                              categoryDescriptionController
                                                  .clear();
                                              context.pop();
                                              context.read<QuotesBloc>().add(
                                                  LoadQuotes(
                                                      category: context
                                                          .read<CategoryCubit>()
                                                          .state));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryDark,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 30),
                                              child: Text(
                                                categoryState
                                                    .suggestion.toTitleCase,
                                                style: GoogleFonts.getFont(
                                                    'Montserrat',
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          );
                                        }
                                        return SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ));
                        });
                  },
                  child: Row(
                    children: [
                      Text(
                        'Describe category',
                        style: GoogleFonts.getFont(
                          'Montserrat',
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  children: [
                    Text(
                      'THEME',
                      style: GoogleFonts.getFont(
                        'Montserrat',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Expanded(
                            child: Icon(
                              CupertinoIcons.moon_fill,
                              color: kSecondaryDark,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 35),
                          Expanded(
                            child: Switch(
                              value: false,
                              onChanged: (value) {},
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Icon(
                              CupertinoIcons.sun_min_fill,
                              color: kSecondaryDark,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        actions: [
          BlocBuilder<CategoryCubit, String>(
            builder: (context, category) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    try {
                      context
                          .read<QuotesBloc>()
                          .add(LoadQuotes(category: category));
                    } catch (e) {
                      displaySnackBar('$e');
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.refresh_circled,
                    color: kSecondaryDark,
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ],
        backgroundColor: kPrimaryLighterDark,
        centerTitle: true,
        toolbarHeight: 100,
        elevation: 0,
        title: Text(
          'QUOTER',
          style: GoogleFonts.getFont(
            'Montserrat',
            fontSize: 40,
            color: kSecondaryDark,
          ),
        ),
        leading: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(
                Icons.menu,
                color: kSecondaryDark,
                size: 50,
              ),
            ),
          );
        }),
      ),

      // ─── IMPORTANT: Provide a single SwiperCubit here (so QuoteSwiper and BottomControls share it)
      body: BlocProvider(
        create: (_) => SwiperCubit(),
        child: BlocConsumer<QuotesBloc, QuotesState>(
          buildWhen: (previous, current) {
            // Only rebuild on the *initial* success/failure/loading. If we toggle "like"
            // (which emits another QuotesSuccess), we do NOT rebuild the Swiper.
            if (current is QuotesLoading && previous is! QuotesLoading) {
              return true;
            }
            if (current is QuotesError && previous is! QuotesError) {
              return true;
            }
            if (current is QuotesLoaded && previous is! QuotesLoaded) {
              return true;
            }
            return false;
          },
          listener: (context, state) {
            if (state is QuotesError) {
              displaySnackBar(state.message);
            }
            if (state is QuotesLoaded) {
              // ✅ Reset swiper index to 0 on refresh
              context.read<SwiperCubit>().updateIndex(0);

              // Handle like notification if needed
              if (_lastLikedIndex != null) {
                final toggledQuote = state.allQuotes[_lastLikedIndex!];
                final isNowLiked = toggledQuote.isLiked;

                showTopSnackBar(
                  Overlay.of(context),
                  CustomSnackBar.info(
                    backgroundColor: isNowLiked
                        ? kSecondaryDark.withAlpha(200)
                        : kPrimaryDark.withAlpha(200),
                    textStyle: GoogleFonts.getFont(
                      'Montserrat',
                      color: isNowLiked ? kPrimaryDark : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                    ),
                    message: isNowLiked
                        ? 'You Liked a Quote By ${toggledQuote.author}'
                        : 'You Disliked the Quote By ${toggledQuote.author}',
                  ),
                );

                _lastLikedIndex = null;
              }
            }
          },
          builder: (context, quoteState) {
            if (quoteState is QuotesLoading) {
              return const LoadingRings(
                size: 100,
              );
            }
            if (quoteState is QuotesError) {
              return FailureWidget(size: size);
            }
            if (quoteState is QuotesInitial) {
              return const LoadingRings(
                size: 100,
              );
            }
            final allQuotes = (quoteState as QuotesLoaded).allQuotes;

            return Column(
              children: [
                // ─── Top: QuoteSwiper (only built once on initial success) ───
                Expanded(
                  flex: 8,
                  child: QuoteSwiper(
                    allQuotes: allQuotes,
                    swiperController: swiperController,
                  ),
                ),

                // ─── Bottom: BottomControls (reads live index + live quotes) ───
                Expanded(
                  flex: 2,
                  child: BlocBuilder<LikedQuotesBloc, LikedQuotesState>(
                    builder: (context, likedState) {
                      final favoriteSet = <Quote>{};
                      if (likedState is LikedQuotesLoaded) {
                        favoriteSet.addAll(likedState.likedQuotes);
                      }
                      final currentQuote = allQuotes[swiperController.index];
                      final isLiked = favoriteSet
                          .contains(allQuotes[swiperController.index]);
                      return BottomControls(
                        swiperController: swiperController,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
