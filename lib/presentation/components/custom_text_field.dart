import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quoter/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.categoryDescriptionController,
  });

  final TextEditingController categoryDescriptionController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: categoryDescriptionController,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      enableSuggestions: true,
      style: GoogleFonts.getFont(
        'Montserrat',
        fontSize: 20,
        color: Colors.white,
      ),
      cursorColor: kSecondaryDark,
      decoration: InputDecoration(
        hintText: 'Describe category',
        hintStyle: GoogleFonts.getFont(
          'Montserrat',
          fontSize: 18,
          color: Colors.white,
        ),
        suffixIcon: HugeIcon(
          icon: HugeIcons.strokeRoundedAiIdea,
          color: Colors.white,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: kSecondaryDark,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: kSecondaryDark,
            width: 2,
          ),
        ),
      ),
    );
  }
}
