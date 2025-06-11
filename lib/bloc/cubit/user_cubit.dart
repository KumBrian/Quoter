// lib/bloc/cubit/user_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quoter/data/data_provider/firestore_services.dart';
import 'package:quoter/models/user_model.dart'; // Make sure this import is correct

class UserCubit extends Cubit<UserModel?> {
  // Changed to UserModel?
  final FirestoreService
      _firestoreService; // UserCubit now depends on FirestoreService

  UserCubit({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(null); // Initial state is null (no user loaded)

  // This method will be called from main.dart after AuthBloc authenticates
  Future<void> setUser(UserModel user) async {
    emit(user);
    // Potentially you'd fetch the latest user data here if needed,
    // but AuthBloc already provides the latest on auth changes.
    // So, this is mainly for setting the cubit's state.
  }

  // Example: update username
  Future<void> updateUsername(String newUsername) async {
    if (state == null) return; // Cannot update if no user is set

    emit(state!.copyWith(username: newUsername)); // Optimistic update

    try {
      final updatedUser = state!.copyWith(username: newUsername);
      await _firestoreService.createOrUpdateUser(updatedUser);
    } catch (e) {
      // Revert if update fails (or fetch original user)
      // emit(originalState);
      debugPrint('Failed to update username: $e');
    }
  }

  void clearUser() {
    emit(null);
  }
}
