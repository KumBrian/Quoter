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
        // Log states for debugging
        debugPrint('AuthCheckerPage Listener - Current State: $state');

        if (state is AuthLoading) {
          // Stay on the loading screen until a definitive auth state is known
          // (This listener won't redirect, but it's good to know what's happening)
        } else if (state is Authenticated) {
          context.go('/home'); // User is authenticated, go to home
        } else if (state is Unauthenticated) {
          context.go('/signin'); // User is not authenticated, go to signin
        } else if (state is AuthError) {
          // Optionally, show a SnackBar or dialog for the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          // After showing error, ensure they are sent to signin if not authenticated
          // (The AuthBloc should have already emitted Unauthenticated if the login/signup failed)
        }
      },
      child: const Scaffold(
        backgroundColor: kPrimaryDark,
        body: Center(
          child: LoadingRings(size: 100), // Show loading indicator
        ),
      ),
    );
  }
}
