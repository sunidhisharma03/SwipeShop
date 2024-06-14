import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/a.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      }).catchError((error) {
        // Handle error here
        print("Error initializing video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isInitialized
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: VideoPlayer(_controller),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.grey.withOpacity(0.5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
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
