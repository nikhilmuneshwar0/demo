import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final List<String> friends;
  final List<String> friendRequests;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.friends,
    required this.friendRequests,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['uid'] ?? doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      friends: List<String>.from(data['friends'] ?? []),
      friendRequests: List<String>.from(data['friendRequests'] ?? []),
    );
  }
}