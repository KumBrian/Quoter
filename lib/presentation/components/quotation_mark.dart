import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/constants.dart';

class QuotationMark extends StatelessWidget {
  const QuotationMark({
    super.key,
    required this.alignment,
  });

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: alignment,
        child: AutoSizeText(
          "\"",
          maxLines: 1,
          maxFontSize: 128,
          minFontSize: 50,
          style: GoogleFonts.getFont('Montserrat',
              fontWeight: FontWeight.w900, color: kSecondaryDark),
        ),
      ),
    );
  }
}
