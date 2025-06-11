import 'package:firebase_auth/firebase_auth.dart';
import 'package:quoter/data/data_provider/firestore_services.dart';
import 'package:quoter/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestoreService;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirestoreService firestoreService,
  })  : _firebaseAuth = firebaseAuth,
        _firestoreService = firestoreService;

  // Stream to listen to Firebase Auth state changes and map to UserModel
  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser != null) {
        // If Firebase user exists, try to fetch their UserModel from Firestore
        return await _firestoreService.getUser(firebaseUser.uid);
      }
      return null; // No Firebase user means no UserModel
    });
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'Firebase user not created');
      }

      // Create a new UserModel instance
      final newUser = UserModel.newUser(
        id: firebaseUser.uid,
        email: email,
        username: username,
      );

      // Save the UserModel to Firestore
      await _firestoreService.createOrUpdateUser(newUser);

      return newUser; // Return the newly created UserModel
    } on FirebaseAuthException {
      rethrow; // Re-throw FirebaseAuthException to be caught by AuthBloc
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Firebase user not found after sign in');
      }

      // Fetch the existing UserModel from Firestore
      final userModel = await _firestoreService.getUser(firebaseUser.uid);
      if (userModel == null) {
        // This scenario might happen if user exists in Auth but not in Firestore (e.g., db error)
        throw Exception('User profile not found in Firestore.');
      }
      return userModel; // Return the fetched UserModel
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Optional: Update user profile in Firestore
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestoreService.createOrUpdateUser(user);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
}
