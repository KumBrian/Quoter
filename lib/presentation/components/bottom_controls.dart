import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/custom_icon_button.dart';
import 'package:quoter/presentation/components/quote_swiper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class BottomControls extends StatelessWidget {
  final SwiperController swiperController;
  final void Function(int) onLikeTapped;

  const BottomControls({
    super.key,
    required this.swiperController,
    required this.onLikeTapped,
  });

  @override
  Widget build(BuildContext contextMain) {
    // We need two pieces of dynamic state:
    //  1) The current swiper index (so we know which quote is visible)
    //  2) The QuotesBloc state (so we know the full List<Quote>, including isLiked)
    //
    // We’ll nest a BlocBuilder for SwiperCubit around a BlocBuilder for QuotesBloc.
    // Whenever the swiper index changes, the SwiperBuilder rebuilds; whenever
    // QuotesBloc emits a new state, the QuotesBuilder rebuilds. Both combine to give us
    // the single “currentQuote” object at index = current swiper index.
    return BlocBuilder<SwiperCubit, int>(
      builder: (context, currentIndex) {
        return BlocBuilder<QuotesBloc, QuotesState>(
          builder: (context, quoteState) {
            // If QuotesBloc isn’t in success state, we can’t show anything meaningful.
            // Just disable all buttons.
            if (quoteState is! QuotesLoaded) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomIconButton(
                    icon: CupertinoIcons.shuffle_medium,
                    label: 'Shuffle',
                    isLiked: false,
                    onTap: () {}, // disabled
                  ),
                  CustomIconButton(
                    icon: Icons.favorite,
                    label: 'Like',
                    isLiked: false,
                    onTap: () {}, // disabled
                  ),
                  CustomIconButton(
                    icon: Icons.share,
                    label: 'Share',
                    isLiked: false,
                    onTap: () {}, // disabled
                  ),
                ],
              );
            }

            // Now we know quoteState is QuotesSuccess:
            final allQuotes = quoteState.allQuotes;

            // Make sure currentIndex is in bounds
            final clampedIndex = currentIndex.clamp(0, allQuotes.length - 1);
            final currentQuote = allQuotes[currentIndex];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ─── Shuffle ───
                CustomIconButton(
                  icon: CupertinoIcons.shuffle_medium,
                  label: 'Shuffle',
                  isLiked: false,
                  onTap: allQuotes.isEmpty
                      ? null
                      : () {
                          // Pick a random new index and move the SwiperController
                          final newIndex = Random().nextInt(allQuotes.length);
                          swiperController.move(newIndex);

                          // Also notify SwiperCubit of the index change so any other
                          // listeners (including this bottom row) rebuild:
                          context.read<SwiperCubit>().updateIndex(newIndex);

                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.info(
                              backgroundColor: kSecondaryDark.withAlpha(200),
                              textStyle: GoogleFonts.getFont(
                                'Montserrat',
                                color: kPrimaryDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                              message: 'Shuffled',
                            ),
                          );
                        },
                ),

                // ─── LIKE ───
                BlocBuilder<SwiperCubit, int>(
                  builder: (context, newIndex) {
                    return BlocBuilder<LikedQuotesBloc, LikedQuotesState>(
                      builder: (context, likedState) {
                        final favoriteSet = <Quote>{};
                        if (likedState is LikedQuotesLoaded) {
                          favoriteSet.addAll(likedState.likedQuotes);
                        }
                        final currentQuote = allQuotes[newIndex];
                        final isLiked = favoriteSet.contains(currentQuote);

                        return CustomIconButton(
                          icon: Icons.favorite,
                          label: 'Like',
                          isLiked: isLiked,
                          onTap: () {
                            final bloc = context.read<LikedQuotesBloc>();
                            if (isLiked) {
                              bloc.add(RemoveFavorite(currentQuote, context));
                            } else {
                              bloc.add(AddFavorite(currentQuote, context));
                            }
                          },
                        );
                      },
                    );
                  },
                ),

                // ─── SHARE ───
                CustomIconButton(
                  icon: Icons.share,
                  label: 'Share',
                  isLiked: false,
                  onTap: () async {
                    try {
                      // Slight delay so the RepaintBoundary is fully painted
                      await Future.delayed(const Duration(milliseconds: 100));
                      await WidgetsBinding.instance.endOfFrame;

                      // Grab the image of the currently visible card
                      final boundary = previewContainer.currentContext!
                          .findRenderObject() as RenderRepaintBoundary;
                      if (boundary.debugNeedsPaint) {
                        await Future.delayed(const Duration(milliseconds: 20));
                      }

                      final image = await boundary.toImage(pixelRatio: 3.0);
                      final byteData = await image.toByteData(
                          format: ui.ImageByteFormat.png);
                      final pngBytes = byteData!.buffer.asUint8List();

                      final tempDir = await getTemporaryDirectory();
                      final file =
                          await File('${tempDir.path}/quote.png').create();
                      await file.writeAsBytes(pngBytes);

                      // **Here’s the fix**: we now use `currentQuote.author`
                      // from the *up‐to‐date* QuotesBloc state, instead of any stale list.

                      await SharePlus.instance.share(ShareParams(
                          text: "Quote of the Day By ${currentQuote.author}",
                          files: [XFile(file.path)]));
                      // await Share.shareXFiles(
                      //   [XFile(file.path)],
                      //   text: "Quote of the Day By ${currentQuote.author}",
                      // );
                    } catch (e) {
                      debugPrint("Error sharing quote image: $e");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
