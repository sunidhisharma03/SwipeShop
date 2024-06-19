import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshop_frontend/signIn/firebase_signin.dart';
import 'package:swipeshop_frontend/signIn/register.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Firebase _firebase = Firebase();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                  title: Text(
                    "SwipeShop",
                    style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600),
                  ),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                        gradient: RadialGradient(radius: 10, colors: [
                      Colors.white,
                      Color.fromRGBO(0, 156, 255, 1)
                    ])),
                  ),
                ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String? result = await _firebase.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        if (result == 'success') {
                          Navigator.pushNamed(context, '/');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result ?? 'Login failed')),
                          );
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(width: 20),
                    const Text('Not registered?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
