part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  // Adding props for equality checks in BlocTest
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// CHANGE: Authenticated state now holds the UserModel
class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);

  @override
  List<Object?> get props => [user]; // For equality checks in BlocTest
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message]; // For equality checks in BlocTest
}
