import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/custom_icon_button.dart';
import 'package:quoter/presentation/components/quotation_mark.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class BottomControls extends StatefulWidget {
  final SwiperController swiperController;

  const BottomControls({
    super.key,
    required this.swiperController,
  });

  @override
  State<BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<BottomControls> {
  // --- NO CHANGE: ScreenshotController remains here
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Renamed contextMain to context for consistency
    // --- NO CHANGE: pixelRatio remains here
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return BlocBuilder<SwiperCubit, int>(
      builder: (context, currentIndex) {
        return BlocBuilder<QuotesBloc, QuotesState>(
          builder: (context, quoteState) {
            // --- REFACTOR: Moved disabled controls to a separate private method for clarity
            if (quoteState is! QuotesLoaded) {
              return _buildDisabledControls();
            }

            // Now we know quoteState is QuotesLoaded:
            final allQuotes = quoteState.allQuotes;

            // Handle potential out-of-bounds index for robustness, though Swiper should prevent this.
            if (allQuotes.isEmpty) {
              return _buildDisabledControls();
            }

            final currentQuote = allQuotes[currentIndex];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ─── Shuffle ───
                CustomIconButton(
                  icon: CupertinoIcons.shuffle_medium,
                  label: 'Shuffle',
                  isLiked: false,
                  onTap: () {
                    final newIndex = Random().nextInt(allQuotes.length);
                    widget.swiperController.move(newIndex);
                    // --- NO CHANGE: Use context.read to update SwiperCubit
                    context.read<SwiperCubit>().updateIndex(newIndex);

                    // --- NO CHANGE: SnackBar remains local as it's a UI effect
                    _showSnackBar(
                        context, 'Shuffled', kSecondaryDark, kPrimaryDark);
                  },
                ),

                // ─── LIKE ───
                // --- NO CHANGE: Nested BlocBuilder here is still valid to react to SwiperCubit changes
                // before checking LikedQuotesBloc state.
                BlocBuilder<SwiperCubit, int>(
                  builder: (context, newIndex) {
                    final quoteForLikeCheck = allQuotes[
                        newIndex]; // Ensure we check the currently displayed quote
                    return BlocBuilder<LikedQuotesBloc, LikedQuotesState>(
                      builder: (context, likedState) {
                        final favoriteSet = <Quote>{};
                        if (likedState is LikedQuotesLoaded) {
                          favoriteSet.addAll(likedState.likedQuotes);
                        }
                        // Check if the actual current quote is liked
                        final isLiked = favoriteSet.contains(quoteForLikeCheck);

                        return CustomIconButton(
                          icon: Icons.favorite,
                          label: 'Like',
                          isLiked: isLiked,
                          onTap: () {
                            final bloc = context.read<LikedQuotesBloc>();
                            if (isLiked) {
                              bloc.add(
                                  RemoveFavorite(quoteForLikeCheck, context));
                            } else {
                              bloc.add(AddFavorite(quoteForLikeCheck, context));
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
                      // --- NO CHANGE: Screenshot widget content is defined here
                      final imageWidget = Screenshot(
                        controller: screenshotController,
                        child: _buildShareableQuoteContent(
                            currentQuote), // REFACTOR: Use helper method
                      );

                      // --- NO CHANGE: Await rendering before capturing
                      await Future.delayed(const Duration(milliseconds: 100));
                      await WidgetsBinding.instance.endOfFrame;

                      // --- NO CHANGE: Capture the image
                      final Uint8List imageFileBytes =
                          await screenshotController.captureFromWidget(
                        imageWidget,
                        pixelRatio: pixelRatio,
                      );

                      // --- NO CHANGE: Save to temporary directory
                      final appDir = await getApplicationDocumentsDirectory();
                      final file = await File(
                              '${appDir.path}/quote${DateTime.now().millisecondsSinceEpoch}.png')
                          .create();
                      await file.writeAsBytes(imageFileBytes);

                      await SharePlus.instance.share(ShareParams(
                          text: "Quote of the Day By ${currentQuote.author}",
                          files: [XFile(file.path)]));

                      // --- ADDED: Clean up the temporary file after sharing (good practice)
                      if (await (file).exists()) {
                        await (file).delete();
                      }
                    } catch (e) {
                      debugPrint("Error sharing quote image: $e");
                      // Optionally show an error snackbar
                      _showSnackBar(context, 'Error sharing quote', Colors.red,
                          Colors.white);
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

  // --- NEW METHOD: Extracted for clarity - provides the widget to be screenshotted
  Widget _buildShareableQuoteContent(Quote quote) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryDark,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: AspectRatio(
            aspectRatio: 12 / 16,
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryLighterDark,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 1,
                    child: QuotationMark(
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child: AutoSizeText(
                          quote.quote, // Use the passed quote
                          style: GoogleFonts.getFont('Montserrat',
                              fontWeight: FontWeight.w500, color: Colors.white),
                          minFontSize: 18,
                          maxLines: 9,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AutoSizeText(
                          quote.author, // Use the passed quote
                          style: GoogleFonts.getFont('Moon Dance',
                              color: kSecondaryDark),
                          minFontSize: 20,
                          maxLines: 1,
                        ),
                        const QuotationMark(
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- NEW METHOD: Extracted for clarity - displays disabled controls
  Widget _buildDisabledControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomIconButton(
          icon: CupertinoIcons.shuffle_medium,
          label: 'Shuffle',
          isLiked: false,
          onTap: null, // Explicitly null to disable
        ),
        CustomIconButton(
          icon: Icons.favorite,
          label: 'Like',
          isLiked: false,
          onTap: null, // Explicitly null to disable
        ),
        CustomIconButton(
          icon: Icons.share,
          label: 'Share',
          isLiked: false,
          onTap: null, // Explicitly null to disable
        ),
      ],
    );
  }

  // --- NEW METHOD: Extracted for clarity - shows a custom snackbar
  void _showSnackBar(
      BuildContext context, String message, Color bgColor, Color textColor) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: bgColor.withAlpha(200),
        textStyle: GoogleFonts.getFont(
          'Montserrat',
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        message: message,
      ),
    );
  }
}
