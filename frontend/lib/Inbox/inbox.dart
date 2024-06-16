import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipeshop_frontend/userProfile/user_profile.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  String _email = 'guest@example.com';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _email = currentUser.email ?? 'guest@example.com';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.grey.shade900,
                  Colors.black,
                  Colors.grey.shade900,
                ],
                stops: const [0, 0.25, 0.7, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserProfilePage()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: const AssetImage('assets/images/1901.png'),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _email,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Chats",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var chatDocs = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          var chat = chatDocs[index];
                          return GestureDetector(
                            onTap: () {
                              // Handle chat item tap
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      chat['profileImageUrl'] ??
                                          'assets/images/1901.png',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chat['sellerName'] ?? 'Unknown',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          chat['lastMessage'] ?? 'No message',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: Inbox()));
}
