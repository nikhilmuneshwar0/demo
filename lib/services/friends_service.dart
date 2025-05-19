import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send friend request
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    await _firestore.collection('users').doc(receiverId).update({
      'friendRequests': FieldValue.arrayUnion([senderId]),
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String userId, String friendId) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(userId);
    final friendRef = _firestore.collection('users').doc(friendId);

    batch.update(userRef, {
      'friends': FieldValue.arrayUnion([friendId]),
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });

    batch.update(friendRef, {
      'friends': FieldValue.arrayUnion([userId]),
    });

    await batch.commit();
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String userId, String friendId) async {
    await _firestore.collection('users').doc(userId).update({
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });
  }

  // Get user by email
  Future<DocumentSnapshot?> getUserByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isNotEmpty ? query.docs.first : null;
  }

  // Add this to your FriendsService class
  Future<DocumentSnapshot> getUserById(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // Stream of user data
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}