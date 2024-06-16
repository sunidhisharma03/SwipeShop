import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshop_frontend/signIn/firebaseSignin.dart';
import 'package:swipeshop_frontend/signIn/register.dart';
import 'package:swipeshop_frontend/Home/home.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

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
            color: Colors.grey.shade600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 10,
              colors: [
                Colors.white,
                Color.fromRGBO(0, 156, 255, 1)
              ],
            ),
          ),
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
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: const InputDecoration(
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
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Home()),
                          );
                        } else {
                          if (!mounted) return;
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
                          MaterialPageRoute(builder: (context) => const Register()),
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
