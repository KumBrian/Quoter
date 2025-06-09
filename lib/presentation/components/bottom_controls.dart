import 'dart:io';
import 'dart:math';

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
  // final void Function(int) onLikeTapped;

  const BottomControls({
    super.key,
    required this.swiperController,
    // required this.onLikeTapped,
  });

  @override
  State<BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<BottomControls> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext contextMain) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return BlocBuilder<SwiperCubit, int>(
      builder: (context, currentIndex) {
        return BlocBuilder<QuotesBloc, QuotesState>(
          builder: (context, quoteState) {
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
                          final newIndex = Random().nextInt(allQuotes.length);
                          widget.swiperController.move(newIndex);
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
                      final imageWidget = Screenshot(
                        controller: screenshotController,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPrimaryDark,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Center(
                                            child: AutoSizeText(
                                              currentQuote.quote,
                                              style: GoogleFonts.getFont(
                                                  'Montserrat',
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white),
                                              minFontSize: 18,
                                              maxLines: 9,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            AutoSizeText(
                                              currentQuote.author,
                                              style: GoogleFonts.getFont(
                                                  'Moon Dance',
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
                        ),
                      );
                      await Future.delayed(const Duration(milliseconds: 100));
                      await WidgetsBinding.instance.endOfFrame;

                      final imageFile =
                          await screenshotController.captureFromWidget(
                        imageWidget,
                        pixelRatio: pixelRatio,
                      );

                      final appDir = await getApplicationDocumentsDirectory();
                      final file = await File(
                              '${appDir.path}/quote${DateTime.now().millisecondsSinceEpoch}.png')
                          .create();
                      await file.writeAsBytes(imageFile);

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
