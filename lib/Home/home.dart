import 'dart:html';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; // Make sure you have this package in your pubspec.yaml

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                colors: [Colors.black, Colors.grey],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Image.asset(
            'assets/images/1901.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            right: 10,
            top: MediaQuery.of(context).size.height / 1.85 - 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    // Placeholder for user profile icon
                    Iconsax.message_circle,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                IconButton(
                  icon: const Icon(
                    Iconsax.heart,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    // Handle like button press
                  },
                ),
                const SizedBox(height: 12),
                IconButton(
                  icon: const Icon(
                    Iconsax.message,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    // Handle comment button press
                  },
                ),
                const SizedBox(height: 12),
                IconButton(
                  icon: const Icon(
                    Iconsax.send_2,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    // Handle share button press
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
