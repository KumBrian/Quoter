library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserBloc() : super(UserInitial()) {
    on<LoadUserData>(_onLoadUserData);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
    on<LoadAllUsers>(_onLoadAllUsers);
  }

  Future<void> _onLoadUserData(
    LoadUserData event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(event.userId)
          .get();
      if (userDoc.exists) {
        emit(UserLoaded(userDoc.data() as Map<String, dynamic>));
      } else {
        emit(UserError('User not found'));
      }
    } catch (e) {
      emit(UserError('Failed to load user data'));
    }
  }

  Future<void> _onFollowUser(FollowUser event, Emitter<UserState> emit) async {
    try {
      // Add to current user's following
      await _firestore.collection('users').doc(event.currentUserId).update({
        'following': FieldValue.arrayUnion([event.targetUserId]),
      });

      // Add to target user's followers
      await _firestore.collection('users').doc(event.targetUserId).update({
        'followers': FieldValue.arrayUnion([event.currentUserId]),
      });

      emit(UserOperationSuccess('Followed successfully'));
    } catch (e) {
      emit(UserError('Failed to follow user'));
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Remove from current user's following
      await _firestore.collection('users').doc(event.currentUserId).update({
        'following': FieldValue.arrayRemove([event.targetUserId]),
      });

      // Remove from target user's followers
      await _firestore.collection('users').doc(event.targetUserId).update({
        'followers': FieldValue.arrayRemove([event.currentUserId]),
      });

      emit(UserOperationSuccess('Unfollowed successfully'));
    } catch (e) {
      emit(UserError('Failed to unfollow user'));
    }
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        users.add({'id': doc.id, ...doc.data() as Map<String, dynamic>});
      }
      emit(UsersListLoaded(users));
    } catch (e) {
      emit(UserError('Failed to load users'));
    }
  }
}
