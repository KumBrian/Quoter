import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/presentation/extensions/string_extensions.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(
            EdgeInsets.symmetric(vertical: 20, horizontal: 15)),
        shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        )),
        backgroundColor: WidgetStateProperty.all<Color>(kSecondaryDark),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
      icon: HugeIcon(icon: icon, color: Colors.white),
      label: Text(
        label.toTitleCase,
        style: GoogleFonts.getFont(
          'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
