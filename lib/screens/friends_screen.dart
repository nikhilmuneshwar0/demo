// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/friends_service.dart';
import '../models/user_model.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Check if Firebase is initialized
    final firebaseApp = Firebase.app();
    if (firebaseApp == null) {
      return const Center(child: Text('Firebase not initialized'));
    }
    
    final friendsService = Provider.of<FriendsService>(context);
    final currentUser = Provider.of<User?>(context);

    if (currentUser == null) {
      return const Center(child: Text('Please sign in'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: friendsService.getUserStream(currentUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = AppUser.fromFirestore(snapshot.data!);
        
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Friends'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Friends'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Friends List
                ListView.builder(
                  itemCount: user.friends.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot?>(
                      future: friendsService.getUserById(user.friends[index]),
                      builder: (context, friendSnapshot) {
                        if (!friendSnapshot.hasData) {
                          return const ListTile(title: Text('Loading...'));
                        }
                        final friend = AppUser.fromFirestore(friendSnapshot.data!);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: friend.photoURL != null 
                                ? NetworkImage(friend.photoURL!)
                                : null,
                            child: friend.photoURL == null 
                                ? Text(friend.displayName?[0] ?? '?')
                                : null,
                          ),
                          title: Text(friend.displayName ?? 'Unknown'),
                          subtitle: Text(friend.email ?? ''),
                        );
                      },
                    );
                  },
                ),
                
                // Friend Requests
                ListView.builder(
                  itemCount: user.friendRequests.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot?>(
                      future: friendsService.getUserById(user.friendRequests[index]),
                      builder: (context, requesterSnapshot) {
                        if (!requesterSnapshot.hasData) {
                          return const ListTile(title: Text('Loading...'));
                        }
                        final requester = AppUser.fromFirestore(requesterSnapshot.data!);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: requester.photoURL != null 
                                ? NetworkImage(requester.photoURL!)
                                : null,
                            child: requester.photoURL == null 
                                ? Text(requester.displayName?[0] ?? '?')
                                : null,
                          ),
                          title: Text(requester.displayName ?? 'Unknown'),
                          subtitle: Text(requester.email ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => friendsService.acceptFriendRequest(
                                  user.uid, 
                                  requester.uid,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => friendsService.rejectFriendRequest(
                                  user.uid, 
                                  requester.uid,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showAddFriendDialog(context, friendsService, user.uid);
              },
              child: const Icon(Icons.person_add),
            ),
          ),
        );
      },
    );
  }

  void _showAddFriendDialog(
    BuildContext context, 
    FriendsService friendsService,
    String currentUserId,
  ) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Friend\'s Email',
              hintText: 'Enter email address',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  final userDoc = await friendsService.getUserByEmail(email);
                  if (userDoc != null && userDoc.exists) {
                    await friendsService.sendFriendRequest(
                      currentUserId,
                      userDoc.id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend request sent!')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found')),
                    );
                  }
                }
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }
}