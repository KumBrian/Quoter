import 'dart:io';
import 'dart:typed_data'; // ADDED: Import for Uint8List

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quoter/bloc/liked_quotes/liked_quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/custom_icon_button.dart';
import 'package:quoter/presentation/components/quotation_mark.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key, required this.quote});

  final Quote quote;

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // No specific initialization logic needed here.
  }

  @override
  Widget build(BuildContext context) {
    // CHANGE: Renamed contextMain to context for consistency
    final Size size = MediaQuery.of(context).size;
    // --- NO CHANGE: pixelRatio remains here for screenshotting
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 32.0, vertical: 100), // CHANGE: Added const
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              // --- CHANGE: Use a Material widget for proper dialog background and shape
              child: Material(
                color: kPrimaryLighterDark,
                borderRadius: BorderRadius.circular(30),
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
                            widget.quote.quote,
                            style: GoogleFonts.getFont('Montserrat',
                                fontWeight: FontWeight.w500,
                                // REMOVED: TextDecoration.none is default for Text unless specified
                                // decoration: TextDecoration.none,
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
                            widget.quote.author,
                            style: GoogleFonts.getFont('Moon Dance',
                                // REMOVED: TextDecoration.none is default for Text unless specified
                                // decoration: TextDecoration.none,
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
            // --- ADDED: SizedBox for spacing between card and buttons
            const SizedBox(height: 24),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- DELETE BUTTON ---
                  BlocBuilder<LikedQuotesBloc, LikedQuotesState>(
                    builder: (context, likedState) {
                      return CustomIconButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        onTap: () {
                          final bloc = context.read<LikedQuotesBloc>();
                          // CHANGE: Simply context.pop(), no need to pass context again
                          context.pop();
                          bloc.add(RemoveFavorite(widget.quote, context));
                        },
                        isLiked:
                            false, // This button doesn't represent a liked state
                      );
                    },
                  ),
                  // --- ADDED: Spacer between buttons
                  const SizedBox(width: 24),
                  // --- SHARE BUTTON ---
                  CustomIconButton(
                    icon: Icons.share,
                    label: 'Share',
                    isLiked: false,
                    onTap: () async {
                      try {
                        // --- REFACTOR: Moved the screenshot content to a private helper method
                        final imageWidget = Screenshot(
                          controller: screenshotController,
                          child: _buildShareableQuoteContent(widget.quote),
                        );

                        // --- NO CHANGE: Await rendering before capturing
                        await Future.delayed(const Duration(milliseconds: 100));
                        await WidgetsBinding.instance.endOfFrame;

                        final Uint8List imageFileBytes =
                            await screenshotController.captureFromWidget(
                          imageWidget,
                          pixelRatio: pixelRatio,
                        );

                        final appDir = await getApplicationDocumentsDirectory();
                        final file = await File(
                                '${appDir.path}/quote${DateTime.now().millisecondsSinceEpoch}.png')
                            .create();
                        await file.writeAsBytes(imageFileBytes);

                        await SharePlus.instance.share(ShareParams(
                            text: "Quote of the Day By ${widget.quote.author}",
                            files: [XFile(file.path)]));

                        // --- ADDED: Clean up the temporary file after sharing (good practice)
                        if (await (file).exists()) {
                          await (file).delete();
                        }
                      } catch (e) {
                        debugPrint("Error sharing quote image: $e");
                        // ADDED: Optionally show a snackbar on error
                        _showSnackBar(context, 'Error sharing quote',
                            Colors.red, Colors.white);
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

  // --- NEW METHOD: Extracted for clarity - provides the widget content to be screenshotted
  Widget _buildShareableQuoteContent(Quote quote) {
    return Container(
      // --- CHANGE: Consistent background color for the screenshot context
      color: kPrimaryDark,
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
                          quote.quote,
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
                          quote.author,
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
