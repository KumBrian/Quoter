import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

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
        child: Text(
          "\"",
          style: GoogleFonts.getFont('Montserrat',
              fontSize: 128,
              fontWeight: FontWeight.w900,
              color: kSecondaryDark),
        ),
      ),
    );
  }
}
