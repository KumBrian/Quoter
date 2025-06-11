import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class StretchedButton extends StatelessWidget {
  // Text label displayed on the button
  final String label;

  // Callback triggered when button is pressed
  final VoidCallback? onPressed;

  // Flag to show loading spinner instead of text
  final bool isLoading;

  const StretchedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Make button stretch to fill available width
      width: double.infinity,
      child: ElevatedButton(
        // Disable button interaction when loading
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: kSecondaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // Change color when button is disabled
          disabledBackgroundColor: kPrimaryLighterDark,
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              debugPrint(state.message);
              CustomSnackBar.error(
                  message: state.message,
                  backgroundColor: kSecondaryDark.withAlpha(200),
                  textStyle: GoogleFonts.getFont(
                    'Montserrat',
                    color: kPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ));
            } else if (state is Authenticated) {
              context.go('/HomePage', extra: state.user);
            }
          },
          child: Text(
            label,
            style: GoogleFonts.getFont("Montserrat",
                fontSize: 20, color: kPrimaryDark),
          ),
        ),
      ),
    );
  }
}
