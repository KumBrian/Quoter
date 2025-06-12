import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/presentation/extensions/string_extensions.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    required this.labelText,
    required this.suffixIcon,
    this.onIconTap,
  });

  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final String labelText;
  final IconData suffixIcon;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      enableSuggestions: true,
      style: GoogleFonts.getFont(
        'Montserrat',
        fontSize: 20,
        color: Colors.white,
      ),
      obscureText: obscureText,
      cursorColor: kSecondaryDark,
      decoration: InputDecoration(
        labelText: labelText.toTitleCase,
        labelStyle: GoogleFonts.getFont(
          'Montserrat',
          fontSize: 20,
          color: kSecondaryDark,
        ),
        hintText: hintText.toTitleCase,
        hintStyle: GoogleFonts.getFont(
          'Montserrat',
          fontSize: 18,
          color: Colors.white,
        ),
        suffixIcon: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onIconTap,
            child: HugeIcon(
              icon: suffixIcon,
              color: Colors.white,
            ),
          ),
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
