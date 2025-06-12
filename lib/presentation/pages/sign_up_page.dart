import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/bloc/cubit/show_password_cubit.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/presentation/components/auth_text_field.dart';
import 'package:quoter/presentation/components/custom_button.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryLighterDark,
      appBar: AppBar(
        backgroundColor: kPrimaryLighterDark,
        centerTitle: true,
        toolbarHeight: 100,
        elevation: 0,
        title: Text(
          'QUOTER',
          style: GoogleFonts.getFont(
            'Montserrat',
            fontSize: 40,
            color: kSecondaryDark,
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
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
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            spacing: 30,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome To Quoter',
                style: GoogleFonts.getFont('Moon Dance',
                    fontSize: 40, color: Colors.white),
              ),
              AuthTextField(
                controller: _emailController,
                obscureText: false,
                hintText: 'Email',
                labelText: 'Email',
                suffixIcon: HugeIcons.strokeRoundedMail01,
              ),
              AuthTextField(
                controller: _usernameController,
                obscureText: false,
                hintText: 'Username',
                labelText: 'Username',
                suffixIcon: HugeIcons.strokeRoundedUser,
              ),
              BlocBuilder<ShowPasswordCubit, bool>(
                builder: (context, showPassword) {
                  return AuthTextField(
                    controller: _passwordController,
                    obscureText: showPassword,
                    hintText: 'Password',
                    labelText: 'Password',
                    suffixIcon: showPassword
                        ? HugeIcons.strokeRoundedEye
                        : HugeIcons.strokeRoundedViewOffSlash,
                    onIconTap: () {
                      context
                          .read<ShowPasswordCubit>()
                          .togglePasswordVisibility();
                    },
                  );
                },
              ),
              CustomButton(
                label: 'Sign Up',
                onPressed: () {
                  context.read<AuthBloc>().add(
                        SignUpRequested(
                          email: _emailController.text,
                          password: _passwordController.text,
                          username: _usernameController.text,
                        ),
                      );
                },
                icon: HugeIcons.strokeRoundedAccess,
              ),
              TextButton(
                onPressed: () {
                  context.go('/signin');
                },
                child: Text(
                  "Already have an account?",
                  style: GoogleFonts.getFont('Montserrat',
                      fontSize: 20, color: kSecondaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
