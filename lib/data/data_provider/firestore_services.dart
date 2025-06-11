import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quoter/models/user_model.dart';

class FirestoreService {
  // CHANGE: Make _firestore a final instance field, initialized in constructor
  final FirebaseFirestore _firestore;

  // ADDED: Constructor to inject FirebaseFirestore instance
  FirestoreService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // CHANGE: Remove 'static' keyword from all methods
  DocumentReference<Map<String, dynamic>> userRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // CHANGE: Remove 'static' keyword
  CollectionReference<Map<String, dynamic>> usersRef() {
    return _firestore.collection('users');
  }

  // CHANGE: Remove 'static' keyword
  Future<UserModel?> getUser(String userId) async {
    final doc = await userRef(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // CHANGE: Remove 'static' keyword
  Future<void> createOrUpdateUser(UserModel user) async {
    await userRef(user.id).set(user.toFirestore(), SetOptions(merge: true));
  }
}
