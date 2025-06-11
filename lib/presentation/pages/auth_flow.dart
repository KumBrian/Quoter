import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quoter/bloc/auth/auth_bloc.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/presentation/components/loading_rings.dart';

class AuthCheckerPage extends StatelessWidget {
  const AuthCheckerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/home'); // Go to home once authenticated
        } else if (state is Unauthenticated) {
          context.go('/signin'); // Go to signin once unauthenticated
        }
        // AuthLoading/AuthInitial will keep showing the loading indicator
      },
      child: const Scaffold(
        backgroundColor: kPrimaryDark, // Or your app's background color
        body: Center(
          child: LoadingRings(
            size: 100,
          ), // Or a splash screen
        ),
      ),
    );
  }
}
