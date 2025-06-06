import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/bottom_controls.dart';
import 'package:quoter/presentation/components/failure_widget.dart';
import 'package:quoter/presentation/components/loading_rings.dart';
import 'package:quoter/presentation/components/quote_swiper.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final SwiperController swiperController = SwiperController();
  int? _lastLikedIndex;

  @override
  void initState() {
    super.initState();
    context.read<QuotesBloc>().add(LoadQuotes());
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
          width: 250,
          backgroundColor: kPrimaryDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                try {
                  context.read<QuotesBloc>().add(LoadQuotes());
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
            if (state is QuotesLoaded && _lastLikedIndex != null) {
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
          },
          builder: (context, quoteState) {
            if (quoteState is QuotesLoading) {
              return const LoadingRings();
            }
            if (quoteState is QuotesError) {
              return FailureWidget(size: size);
            }
            if (quoteState is QuotesInitial) {
              return const LoadingRings();
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
                        onLikeTapped: (index) {
                          _lastLikedIndex = index;
                          final bloc = context.read<LikedQuotesBloc>();
                          if (isLiked) {
                            bloc.add(RemoveFavorite(currentQuote, context));
                          } else {
                            bloc.add(AddFavorite(currentQuote, context));
                          }
                        },
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
