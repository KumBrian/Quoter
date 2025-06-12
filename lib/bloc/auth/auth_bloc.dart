// lib/bloc/auth/auth_bloc.dart
library;

import 'dart:async';

import 'package:equatable/equatable.dart'; // Ensure Equatable is imported
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart'; // Keep if used for @immutable
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quoter/data/repository/auth_repository.dart';
import 'package:quoter/models/user_model.dart';

part 'auth_events.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<UserModel?> _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthLoading()) {
    // CHANGE: Start with AuthLoading
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<_AuthUserChanged>(_onAuthUserChanged);

    _userSubscription = _authRepository.user.listen((userModel) {
      add(_AuthUserChanged(userModel));
    });
  }

  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.userModel != null) {
      emit(Authenticated(event.userModel!));
    } else {
      emit(Unauthenticated()); // CHANGE: Emit Unauthenticated when user is null
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    // No explicit emit(AuthLoading()) here if you want it to be handled by stream
    // and only show AuthLoading initially or during AuthChecker.
    // If you want a loading state specific to the sign-up button, you can re-add emit(AuthLoading()).
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        username: event.username,
      );
      // DO NOT EMIT Authenticated here. The _userSubscription will handle it.
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign up failed'));
      emit(Unauthenticated()); // Go back to unauthenticated if sign up failed
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
      emit(Unauthenticated()); // Go back to unauthenticated if sign up failed
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // No explicit emit(AuthLoading()) here.
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      // DO NOT EMIT Authenticated here. The _userSubscription will handle it.
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
      emit(Unauthenticated()); // Go back to unauthenticated if login failed
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
      emit(Unauthenticated()); // Go back to unauthenticated if login failed
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // No explicit emit(AuthLoading()) here.
    try {
      await _authRepository.signOut();
      // REMOVE: DO NOT EMIT Unauthenticated here. The _userSubscription will handle it.
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
      // If logout fails, the stream won't emit null, so the state will remain
      // whatever it was (likely Authenticated), which is correct.
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
