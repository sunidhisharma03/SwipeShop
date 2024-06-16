import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeshop_frontend/signIn/auth_gate.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _username = '';
  String _email = '';
  String? userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _username = currentUser.displayName ?? 'Unknown User';
        _email = currentUser.email ?? 'No Email';
        userId = currentUser.uid;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                FirebaseAuth.instance.currentUser?.photoURL ??
                    'https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.webp',
              ),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            Text(
              'Username: $_username',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Email: $_email',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
