import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:quoter/Components/quotation_mark.dart';
import 'package:quoter/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.flipCardKeys,
    required this.quotes,
    required this.index,
  });

  final List<GlobalKey<FlipCardState>> flipCardKeys;
  final int index;
  final List quotes;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: flipCardKeys[index],
      flipOnTouch: true,
      onFlip: () async {
        final canVibrate = await Haptics.canVibrate();
        await Haptics.vibrate(HapticsType.light);
      },
      front: Container(
        decoration: BoxDecoration(
          color: kSecondaryDark,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            quotes.isNotEmpty ? quotes[index].author : 'Loading...',
            style: GoogleFonts.getFont('Moon Dance',
                fontSize: 40, color: kPrimaryDark),
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
                    quotes.isNotEmpty ? quotes[index].quote : 'Loading...',
                    style: GoogleFonts.getFont('Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
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
                    quotes.isNotEmpty ? quotes[index].author : 'Loading...',
                    style: GoogleFonts.getFont('Moon Dance',
                        fontSize: 32, color: kSecondaryDark),
                    maxLines: 1,
                  ),
                  const QuotationMark(
                    alignment: Alignment.centerRight,
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
