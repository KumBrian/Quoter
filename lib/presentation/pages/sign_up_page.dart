import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/constants.dart';
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
              TextField(
                controller: _emailController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(
                  label: Text('Email'),
                  hint: Text('Email'),
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _usernameController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(
                  label: Text('Username'),
                  hint: Text('Username'),
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _passwordController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  label: Text('Password'),
                  hint: Text('Password'),
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        SignUpRequested(
                          email: _emailController.text,
                          password: _passwordController.text,
                          username: _usernameController.text,
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      debugPrint(state.message);
                    } else if (state is Authenticated) {
                      context.go('/home');
                    }
                  },
                  child: Text('Sign Up'),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go('/signin');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SignIn()),
                  // );
                },
                child: Text('Already have an account?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
