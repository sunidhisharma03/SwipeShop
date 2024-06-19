import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshop_frontend/main.dart'; // Your main page
import 'package:swipeshop_frontend/signIn/authgate.dart'; // Your login page
import 'package:swipeshop_frontend/signIn/register.dart'; // Your login page

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return IndexPage(); // User is authenticated, show main page
        } else {
          return AuthGate(); // User is not authenticated, show login page
        }
      },
    );
  }
}
