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

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          spacing: 30,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back To Quoter',
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
              label: 'Sign In',
              onPressed: () {
                context.read<AuthBloc>().add(
                      LoginRequested(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    );
              },
              icon: HugeIcons.strokeRoundedAccess,
            ),
            TextButton(
              onPressed: () {
                context.go('/signup');
              },
              child: Text(
                "Don't have an account?",
                style: GoogleFonts.getFont('Montserrat',
                    fontSize: 20, color: kSecondaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
