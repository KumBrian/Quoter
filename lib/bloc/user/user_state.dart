part of 'user_bloc.dart';

sealed class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Map<String, dynamic> userData;

  UserLoaded(this.userData);
}

class UserOperationSuccess extends UserState {
  final String message;

  UserOperationSuccess(this.message);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class UsersListLoaded extends UserState {
  final List<Map<String, dynamic>> users;

  UsersListLoaded(this.users);
}
