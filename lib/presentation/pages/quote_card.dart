import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/custom_icon_button.dart';
import 'package:quoter/presentation/components/quotation_mark.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

final GlobalKey previewContainer2 = GlobalKey();

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext contextMain) {
    void displaySnackBar(String text) {
      showTopSnackBar(
        Overlay.of(contextMain),
        CustomSnackBar.info(
          backgroundColor: kSecondaryDark.withValues(alpha: 0.9),
          textStyle: GoogleFonts.getFont('Montserrat',
              color: kPrimaryDark, fontSize: 20, fontWeight: FontWeight.w700),
          message: text,
        ),
      );
    }

    final Size size = MediaQuery.of(contextMain).size;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: RepaintBoundary(
                key: previewContainer2,
                child: Container(
                  height: size.height * 0.5,
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
                              quote.quote,
                              style: GoogleFonts.getFont('Montserrat',
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AutoSizeText(
                              quote.author,
                              style: GoogleFonts.getFont('Moon Dance',
                                  decoration: TextDecoration.none,
                                  color: kSecondaryDark),
                              maxLines: 2,
                              minFontSize: 22,
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
            Expanded(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<LikedQuotesBloc, LikedQuotesState>(
                    builder: (context, likedState) {
                      return CustomIconButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        onTap: () {
                          final bloc = context.read<LikedQuotesBloc>();
                          context.pop(contextMain);
                          bloc.add(RemoveFavorite(quote, context));
                        },
                        isLiked: false,
                      );
                    },
                  ),
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
                        final boundary = previewContainer2.currentContext!
                            .findRenderObject() as RenderRepaintBoundary;
                        if (boundary.debugNeedsPaint) {
                          await Future.delayed(
                              const Duration(milliseconds: 20));
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
                            text: "Quote of the Day By ${quote.author}",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
