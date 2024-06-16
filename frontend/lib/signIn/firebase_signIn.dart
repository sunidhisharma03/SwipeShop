import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Firebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> register(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': name,
        });
      }
      return 'success'; // Registration successful, no error message
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message if registration fails
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success'; // Login successful, no error message
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message if login fails
    }
  }
  Future<String?> logout() async {
    try {
      await _auth.signOut();
      return'success'; // Logout successful, no error message
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message if logout fails
    }
  }
  Future<String?> getCurrentUser() async {
    return _auth.currentUser!.uid;
  }
}
