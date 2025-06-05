import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/quotation_mark.dart';
import 'package:vibration/vibration.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.flipCardKey,
    required this.quote,
  });

  final GlobalKey<FlipCardState> flipCardKey;
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: flipCardKey,
      flipOnTouch: true,
      onFlip: () async {
        if (await Vibration.hasAmplitudeControl()) {
          Vibration.vibrate(
            duration: 50,
            amplitude: 9,
          );
        }
      },
      front: Container(
        decoration: BoxDecoration(
          color: kSecondaryDark,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: AutoSizeText(
              quote.author,
              minFontSize: 24,
              maxLines: 2,
              style: GoogleFonts.getFont('Moon Dance', color: kPrimaryDark),
            ),
          ),
        ),
      ),
      back: Container(
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
    );
  }
}
