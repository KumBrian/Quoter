import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/presentation/components/loading_rings.dart';
import 'package:quoter/presentation/pages/quote_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // CHANGE: Renamed contextMain to context
    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        backgroundColor: kPrimaryLighterDark,
        centerTitle: true,
        toolbarHeight: 100,
        elevation: 0,
        title: Text(
          'FAVORITES',
          style: GoogleFonts.getFont(
            'Montserrat',
            fontSize: 40,
            color: kSecondaryDark,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            // CHANGE: Simplified context.pop() call. No need to pass context again.
            onTap: () => context.pop(),
            child: const Icon(
              Icons.home_filled,
              color: kSecondaryDark,
              size: 50,
            ),
          ),
        ),
      ),
      body: BlocBuilder<LikedQuotesBloc, LikedQuotesState>(
        builder: (context, state) {
          if (state is LikedQuotesLoading) {
            return const Center(child: LoadingRings(size: 100));
          }

          if (state is LikedQuotesLoaded) {
            final likedList = state.likedQuotes;
            if (likedList.isEmpty) {
              return const Center(
                child: Text(
                  'No favorites yet.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: likedList.length,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (context, index) {
                final thisQuote = likedList[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Hero(
                    // NO CHANGE: Hero tag is fine as is
                    tag: 'quote by ${thisQuote.author}',
                    child: Dismissible(
                      // CHANGE: Using ObjectKey for Dismissible key, as ValueKey might cause issues
                      // if a quote's content is identical to another (though unlikely here, it's safer).
                      key: ObjectKey(thisQuote),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        // NO CHANGE: Bloc event dispatch remains the same
                        context
                            .read<LikedQuotesBloc>()
                            .add(RemoveFavorite(thisQuote, context));
                      },
                      background: const Padding(
                        padding: EdgeInsets.only(right: 18.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.delete,
                              size: 25,
                              color: kSecondaryDark,
                            ),
                          ],
                        ),
                      ),
                      child: Material(
                        // ADDED: Material widget to provide ink effects and elevation
                        borderRadius: BorderRadius.circular(20),
                        color: kPrimaryLighterDark,
                        child: InkWell(
                          // CHANGE: Using InkWell for tap detection to get ripple effect
                          borderRadius: BorderRadius.circular(
                              20), // Match Material's border radius
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => QuoteCard(quote: thisQuote),
                            );
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 24.0),
                            title: Text(
                              thisQuote.author.toUpperCase(),
                              style: GoogleFonts.getFont(
                                'Montserrat',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kSecondaryDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // REMOVED: onTap from ListTile as InkWell handles it
                            // onTap: () {
                            //   showDialog(
                            //     context: context,
                            //     builder: (_) => QuoteCard(quote: thisQuote),
                            //   );
                            // },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // NO CHANGE: Default return for unexpected states
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
