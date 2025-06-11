import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final String? profileImageUrl;
  final String? bio;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.profileImageUrl,
    this.bio,
  });

  // This constructor is typically used when you're creating a new user object
  // from an external source or for local representation before it hits Firestore.
  // We'll primarily rely on Firestore to set `createdAt` for new documents.
  UserModel.newUser({
    required this.id,
    required this.email,
    required this.username,
  })  : createdAt = DateTime
            .now(), // Local timestamp, will be overwritten by serverTimestamp in Firestore
        bio = null,
        profileImageUrl = null;

  // Convert Firestore Document to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      // Ensure createdAt is a Timestamp before converting to DateTime
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
    );
  }

  // Convert to Map for Firestore.
  // Note: 'createdAt' is set using FieldValue.serverTimestamp() for new documents.
  // When updating existing documents, you might only send changed fields.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      // Only set serverTimestamp for initial creation.
      // For updates, you generally don't send createdAt again.
      'createdAt': FieldValue.serverTimestamp(),
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (bio != null) 'bio': bio,
    };
  }

  // For JSON serialization (e.g., if saving to local storage or sending over network)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'createdAt':
          createdAt.toIso8601String(), // Convert DateTime to String for JSON
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? email,
    String? username,
    String? profileImageUrl,
    String? bio,
    DateTime?
        createdAt, // Added createdAt to copyWith for completeness, though rarely updated
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt, // Allow createdAt to be copied
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
    );
  }

  // Add equality and hashCode for proper comparison in lists/sets (useful for Bloc state)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username &&
          createdAt == other.createdAt &&
          profileImageUrl == other.profileImageUrl &&
          bio == other.bio);

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      username.hashCode ^
      createdAt.hashCode ^
      profileImageUrl.hashCode ^
      bio.hashCode;
}
