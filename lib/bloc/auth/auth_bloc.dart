// lib/bloc/auth/auth_bloc.dart (or wherever your AuthBloc file is located)

library; // Keep this if your file is part of a library directive

import 'dart:async'; // Keep if you use Futures or Streams directly in the Bloc

import 'package:firebase_auth/firebase_auth.dart'; // Keep if you use FirebaseAuthException
import 'package:flutter/cupertino.dart'; // Keep if you use Cupertino widgets/types (e.g., @immutable)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quoter/data/repository/auth_repository.dart'; // NEW: Import AuthRepository
import 'package:quoter/models/user_model.dart'; // NEW: Import UserModel

part 'auth_events.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // CHANGE: AuthBloc now depends on AuthRepository, not direct Firebase instances
  final AuthRepository _authRepository;
  late StreamSubscription<UserModel?>
      _userSubscription; // NEW: To manage the stream subscription

  // CHANGE: Update constructor to take AuthRepository
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<_AuthUserChanged>(
        _onAuthUserChanged); // NEW: Handler for internal stream event

    // NEW: Listen to AuthRepository's user stream and dispatch internal events
    _userSubscription = _authRepository.user.listen((userModel) {
      add(_AuthUserChanged(userModel)); // Dispatch internal event
    });
  }

  // NEW: Handler for when the authentication state changes via stream
  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.userModel != null) {
      emit(
          Authenticated(event.userModel!)); // Emit Authenticated with UserModel
    } else {
      emit(Unauthenticated()); // Emit Unauthenticated
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // CHANGE: Call AuthRepository's signUp method
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        username: event.username,
      );
      // State will be handled by the _authRepository.user stream listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Sign up failed'));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // CHANGE: Call AuthRepository's signIn method
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      // State will be handled by the _authRepository.user stream listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // CHANGE: Call AuthRepository's signOut method
      await _authRepository.signOut();
      // State will be handled by the _authRepository.user stream listener
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel(); // NEW: Cancel the stream subscription on close
    return super.close();
  }
}

// --- NEW INTERNAL EVENT ---
// This event is dispatched internally when the auth state changes via the stream
@immutable // Good practice for Bloc events
class _AuthUserChanged extends AuthEvent {
  final UserModel? userModel;
  _AuthUserChanged(this.userModel);

  @override
  List<Object?> get props => [userModel]; // For equality checks in BlocTest
}
