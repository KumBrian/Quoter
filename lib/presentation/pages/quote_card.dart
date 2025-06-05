import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/bloc/quotes/quotes_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/custom_icon_button.dart';
import 'package:quoter/presentation/components/quotation_mark.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
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

    final Size size = MediaQuery.of(context).size;

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
            Expanded(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<QuotesBloc, QuotesState>(
                    builder: (context, state) {
                      if (state is QuotesInitial) return Container();
                      if (state is QuotesLoading) return Container();
                      if (state is QuotesError) return Container();
                      if (state is QuotesLoaded) {
                        return CustomIconButton(
                          icon: Icons.delete,
                          label: 'Delete',
                          onTap: () {
                            //TODO: Remove From Favorites
                            displaySnackBar('Removed From Favorites');
                          },
                          isLiked: false,
                        );
                      }
                      return Container();
                    },
                  ),
                  CustomIconButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: () async {
                      // await Clipboard.setData(ClipboardData(
                      //     text:
                      //         "`${widget.quote.quote}`\n\nBy ${widget.quote.author}"));
                      // displaySnackBar('Copied');
                    },
                    isLiked: false,
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
