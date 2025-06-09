import 'dart:io';

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
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext contextMain) {
    final Size size = MediaQuery.of(contextMain).size;
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
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
                            widget.quote.quote,
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
                            widget.quote.author,
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
                          bloc.add(RemoveFavorite(widget.quote, context));
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                widget.quote.quote,
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
                                                widget.quote.author,
                                                style: GoogleFonts.getFont(
                                                    'Moon Dance',
                                                    color: kSecondaryDark),
                                                minFontSize: 20,
                                                maxLines: 1,
                                              ),
                                              const QuotationMark(
                                                alignment:
                                                    Alignment.centerRight,
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
                            text: "Quote of the Day By ${widget.quote.author}",
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
