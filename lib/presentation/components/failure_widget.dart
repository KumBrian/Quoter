import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/constants.dart';
import 'package:rive/rive.dart';

class FailureWidget extends StatelessWidget {
  const FailureWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size.height * 0.3,
            width: size.width * 0.3,
            child: const RiveAnimation.asset(
              'assets/rive/failure_animation.riv',
              fit: BoxFit.cover,
            ),
          ),
          Text(
            'Failed to load quotes. Please check your connection and try again',
            style: GoogleFonts.getFont(
              'Montserrat',
              fontSize: 24,
              color: kSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
