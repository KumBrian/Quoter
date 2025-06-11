import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/presentation/components/stretched_button.dart';

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
      body: Padding(
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
            StretchedButton(
              label: 'Sign In',
              onPressed: () {
                context.read<AuthBloc>().add(
                      LoginRequested(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    );
              },
            ),
            TextButton(
              onPressed: () {
                context.go('/signup');
              },
              child: Text("Don't have an account?"),
            ),
          ],
        ),
      ),
    );
  }
}
