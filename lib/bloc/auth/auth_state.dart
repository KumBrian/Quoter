part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  // This state might not be strictly needed if AuthLoading handles initial check
  // or if Unauthenticated is the definitive "not logged in" state.
  // We'll lean towards Unauthenticated as the primary "not logged in" state.
  @override
  String toString() => 'AuthInitial';
}

class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading';
}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'Authenticated { user: ${user.username} }';
}

class Unauthenticated extends AuthState {
  @override
  String toString() => 'Unauthenticated';
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthError { message: $message }';
}
