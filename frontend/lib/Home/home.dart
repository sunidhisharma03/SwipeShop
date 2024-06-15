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
  bool _isPlaying = true;
  int _currentIndex = 0;

  final List<String> _videos = [
    'assets/videos/a.mp4',
    'assets/videos/a.mp4',
    'assets/videos/a.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(_videos[_currentIndex]);
  }

  void _initializeVideoPlayer(String videoPath) {
    _controller = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
        _controller.setLooping(true);
        _controller.play();
      }).catchError((error) {
        print("Error initializing video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // You can adjust sensitivity by changing this value
    const double sensitivity = 5.0;
    if (details.primaryDelta! < -sensitivity) {
      // Swiping up
      _nextVideo();
    } else if (details.primaryDelta! > sensitivity) {
      // Swiping down
      _previousVideo();
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // You can add additional logic here if needed
  }

  void _nextVideo() {
    if (_currentIndex < _videos.length - 1) {
      setState(() {
        _currentIndex++;
        _isInitialized = false;
        _controller.dispose();
        _initializeVideoPlayer(_videos[_currentIndex]);
      });
    }
  }

  void _previousVideo() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isInitialized = false;
        _controller.dispose();
        _initializeVideoPlayer(_videos[_currentIndex]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _togglePlayPause,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _isInitialized
                  ? Container(
                      key: ValueKey<int>(_currentIndex),
                      width: double.infinity,
                      height: double.infinity,
                      child: VideoPlayer(_controller),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.grey.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height / 2 - 75,
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
                  const SizedBox(height: 12),
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
            if (!_isPlaying && _isInitialized)
              Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 100,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: Home()));
}
