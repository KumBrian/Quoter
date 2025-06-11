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
import 'package:quoter/bloc/cubit/user_cubit.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/data/repository/category_repository.dart';
import 'package:quoter/models/user_model.dart';
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

// --- CHANGE: Removed TickerProviderStateMixin as it's not currently used (no AnimationController)
class _HomePageState extends State<HomePage> {
  final SwiperController _swiperController =
      SwiperController(); // CHANGE: Made private
  final TextEditingController
      _categoryDescriptionController = // CHANGE: Made private
      TextEditingController();
  // --- REMOVED: _lastLikedIndex logic will be handled directly in LikedQuotesBloc listener in main
  // int? _lastLikedIndex;

  @override
  void initState() {
    super.initState();
    // No specific initialization needed here, as Blocs handle data loading.
    // Ensure initial quotes are loaded in main.dart or a parent Bloc.
  }

  // --- ADDED: Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _swiperController.dispose();
    _categoryDescriptionController.dispose();
    super.dispose();
  }

  // --- REFACTOR: Extracted SnackBar display logic into a private method
  void _displaySnackBar(BuildContext context, String text,
      {Color? backgroundColor, Color? textColor}) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: backgroundColor ??
            kSecondaryDark.withAlpha(200), // Default to kSecondaryDark
        textStyle: GoogleFonts.getFont(
          'Montserrat',
          color: textColor ?? kPrimaryDark, // Default to kPrimaryDark
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
          // --- CHANGE: Added a Column for direct children with fixed spacing where appropriate
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // spacing: 30, // Removed, use SizedBox for explicit spacing
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
              const SizedBox(height: 70), // Explicit spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: BlocBuilder<UserCubit, UserModel?>(
                  builder: (context, userModel) {
                    return Row(
                      // Using Row for consistent layout with other drawer items
                      children: [
                        Text(
                          'Hi ${userModel?.username.toUpperCase() ?? 'User'}',
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 70), // Explicit spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GestureDetector(
                  onTap: () {
                    context.pop(); // Close drawer
                    context.go('/home/favourites'); // Navigate to favorites
                  },
                  child: Row(
                    // Using Row for consistent layout with other drawer items
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
              const SizedBox(
                  height: 30), // Explicit spacing for CategoriesDropdown
              const CategoriesDropdown(), // CHANGE: Made const as it's stateless
              const SizedBox(height: 30), // Explicit spacing
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GestureDetector(
                  onTap: () {
                    context.pop(); // Close drawer
                    _showCategorySuggestionSheet(
                        context); // REFACTOR: Extracted modal sheet logic
                  },
                  child: Row(
                    // Using Row for consistent layout with other drawer items
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
              const SizedBox(height: 30), // Explicit spacing
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
                              value:
                                  false, // You'll link this to a ThemeCubit/Provider later
                              onChanged: (value) {
                                // TODO: Implement theme switching logic here (e.g., via a ThemeCubit)
                              },
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
                    // --- REFACTOR: Use the private snackbar method
                    context
                        .read<QuotesBloc>()
                        .add(LoadQuotes(category: category));
                    _displaySnackBar(context, 'Loading new quotes...',
                        backgroundColor: kSecondaryDark.withAlpha(200),
                        textColor: kPrimaryDark);
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

      // ─── IMPORTANT: Provide SwiperCubit here for QuoteSwiper and BottomControls ───
      body: BlocProvider(
        create: (_) => SwiperCubit(),
        child: BlocConsumer<QuotesBloc, QuotesState>(
          // --- CHANGE: Simplified buildWhen for initial load/error state for the main content
          buildWhen: (previous, current) {
            return current is QuotesLoading ||
                current is QuotesError ||
                current is QuotesLoaded ||
                current is QuotesInitial;
          },
          listener: (context, state) {
            if (state is QuotesError) {
              _displaySnackBar(context, state.message,
                  backgroundColor: Colors.red.withAlpha(200),
                  textColor: Colors.white);
            }
            if (state is QuotesLoaded) {
              // Reset swiper index to 0 on refresh.
              // --- CHANGE: Only reset if not already at 0, or if quotes actually changed.
              // This is a subtle optimization to avoid unnecessary state updates.
              if (context.read<SwiperCubit>().state != 0) {
                context.read<SwiperCubit>().updateIndex(0);
                _swiperController.move(0); // Also move the physical swiper
              }

              // --- REMOVED: _lastLikedIndex notification logic.
              // This logic is better handled in the LikedQuotesBloc's listener itself
              // or within the CustomIconButton's onTap where the like/dislike action occurs.
              // Doing it here based on `QuotesLoaded` state is indirectly tied to the core
              // quotes data, not directly to the liked status change.
              // To notify on like/dislike, the LikedQuotesBloc should emit a state
              // that a listener can react to, or the action itself triggers a snackbar.
            }
          },
          builder: (context, quoteState) {
            if (quoteState is QuotesLoading || quoteState is QuotesInitial) {
              return const Center(
                child: LoadingRings(
                  size: 100,
                ),
              );
            }
            if (quoteState is QuotesError) {
              return Center(
                child: FailureWidget(size: size),
              );
            }

            // At this point, quoteState MUST be QuotesLoaded
            final allQuotes = (quoteState as QuotesLoaded).allQuotes;

            if (allQuotes.isEmpty) {
              return Center(
                child: Text(
                  'No quotes found for this category.',
                  style: GoogleFonts.getFont('Montserrat',
                      color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: [
                // ─── Top: QuoteSwiper ───
                Expanded(
                  flex: 8,
                  child: QuoteSwiper(
                    allQuotes: allQuotes,
                    swiperController:
                        _swiperController, // CHANGE: Use the private controller
                  ),
                ),

                // ─── Bottom: BottomControls ───
                Expanded(
                  flex: 2,
                  // --- REMOVED: Redundant BlocBuilder<LikedQuotesBloc, LikedQuotesState>
                  // BottomControls itself already contains the BlocBuilder for liked status,
                  // so no need to wrap it here.
                  child: BottomControls(
                    swiperController:
                        _swiperController, // CHANGE: Use the private controller
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- NEW METHOD: Extracted the logic for showing the category suggestion modal bottom sheet
  void _showCategorySuggestionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // CHANGE: AnimationStyle for better control, though default might be fine
      // sheetAnimationStyle: AnimationStyle(curve: Curves.decelerate),
      barrierColor: Colors.transparent,
      builder: (ctx) {
        // CHANGE: Renamed builder context to ctx to avoid conflict
        return Container(
            padding: const EdgeInsets.symmetric(
                // CHANGE: Added const
                horizontal: 40,
                vertical: 40),
            height: 700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: kPrimaryLighterDark,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // --- CHANGE: Use explicit SizedBox for spacing in Column
                // spacing: 20, // Removed
                children: [
                  CustomTextField(
                      categoryDescriptionController:
                          _categoryDescriptionController), // CHANGE: Use private controller
                  const SizedBox(height: 20), // Explicit spacing
                  CustomButton(
                    label: 'get suggestions',
                    onPressed: () async {
                      try {
                        ctx
                            .read<CategorySuggestionCubit>()
                            .setLoading(); // Use ctx
                        final String suggestion = await CategoryRepository()
                            .fetchCategory(_categoryDescriptionController
                                .text.toTitleCase); // Use private controller
                        ctx
                            .read<CategorySuggestionCubit>()
                            .updateSuggestion(suggestion); // Use ctx
                      } catch (e) {
                        _displaySnackBar(ctx, '$e',
                            backgroundColor: Colors.red.withAlpha(200),
                            textColor: Colors.white); // Use ctx
                      }
                    },
                    icon: HugeIcons.strokeRoundedArtificialIntelligence08,
                  ),
                  const SizedBox(height: 20), // Explicit spacing
                  BlocBuilder<CategorySuggestionCubit, CategorySuggestionState>(
                    builder: (blocContext, categoryState) {
                      // CHANGE: Renamed context to blocContext
                      if (categoryState is CategorySuggestionLoading) {
                        return const LoadingRings(
                          size: 50,
                        );
                      }

                      if (categoryState is CategorySuggestionError) {
                        return FailureWidget(size: Size(100, 100));
                      }
                      if (categoryState is CategorySuggestionLoaded) {
                        return InkWell(
                          onTap: () {
                            blocContext // Use blocContext
                                .read<CategoryCubit>()
                                .updateCategory(
                                    categoryState.suggestion.toTitleCase);
                            blocContext // Use blocContext
                                .read<CategorySuggestionCubit>()
                                .clearSuggestion();
                            _categoryDescriptionController
                                .clear(); // Use private controller
                            blocContext.pop(); // Use blocContext
                            blocContext
                                .read<QuotesBloc>()
                                .add(// Use blocContext
                                    LoadQuotes(
                                        category: blocContext // Use blocContext
                                            .read<CategoryCubit>()
                                            .state));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: kPrimaryDark,
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 30),
                            child: Text(
                              categoryState.suggestion.toTitleCase,
                              style: GoogleFonts.getFont('Montserrat',
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink(); // CHANGE: Added const
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }
}
