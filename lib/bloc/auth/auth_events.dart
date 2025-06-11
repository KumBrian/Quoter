part of "auth_bloc.dart";

@immutable
abstract class AuthEvent {
  // Adding props for equality checks in BlocTest
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  SignUpRequested(
      {required this.email, required this.password, required this.username});

  @override
  List<Object?> get props =>
      [email, password, username]; // For equality checks in BlocTest
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props =>
      [email, password]; // For equality checks in BlocTest
}

class LogoutRequested extends AuthEvent {}
