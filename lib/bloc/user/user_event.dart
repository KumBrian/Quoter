part of 'user_bloc.dart';

sealed class UserEvent {}

class LoadUserData extends UserEvent {
  final String userId;

  LoadUserData(this.userId);
}

class FollowUser extends UserEvent {
  final String currentUserId;
  final String targetUserId;

  FollowUser(this.currentUserId, this.targetUserId);
}

class UnfollowUser extends UserEvent {
  final String currentUserId;
  final String targetUserId;

  UnfollowUser(this.currentUserId, this.targetUserId);
}

class LoadAllUsers extends UserEvent {}
