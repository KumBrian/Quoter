import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/Components/custom_icon_button.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../Components/quotation_mark.dart';
import '../Models/quote.dart';
import '../constants.dart';

class QuoteCard extends StatefulWidget {
  final List<Quote> likedQuotes;

  const QuoteCard({super.key, required this.quote, required this.likedQuotes});
  final Quote quote;

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  void displaySnackBar(String text) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: kSecondaryDark.withValues(alpha: 0.9),
        textStyle: GoogleFonts.getFont('Montserrat',
            color: kPrimaryDark, fontSize: 20, fontWeight: FontWeight.w700),
        message: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 4,
                child: Hero(
                  tag: 'quote by ${widget.quote.author}',
                  child: Container(
                    height: 500,
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
                          flex: 4,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              child: Text(
                                widget.quote.quote,
                                style: GoogleFonts.getFont('Montserrat',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: QuotationMark(
                            alignment: Alignment.centerRight,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            widget.quote.author,
                            style: GoogleFonts.getFont(
                              'Moon Dance',
                              fontSize: 40,
                              color: kSecondaryDark,
                              decoration: TextDecoration.none,
                            ),
                          ),
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
                    CustomIconButton(
                      icon: Icons.delete,
                      label: 'Copy',
                      onTap: () {
                        setState(() {
                          widget.quote.isLiked = false;
                          widget.likedQuotes.remove(widget.quote);
                        });
                        displaySnackBar('Removed From Favorites');
                        Navigator.pop(context, widget.likedQuotes);
                      },
                      isLiked: false,
                    ),
                    CustomIconButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(
                            text:
                                "`${widget.quote.quote}`\n\nBy ${widget.quote.author}"));
                        displaySnackBar('Copied');
                      },
                      isLiked: false,
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
