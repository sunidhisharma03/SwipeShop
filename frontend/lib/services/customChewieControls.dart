import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class CustomControls extends StatefulWidget {
  const CustomControls({Key? key}) : super(key: key);

  @override
  _CustomControlsState createState() => _CustomControlsState();
}

class _CustomControlsState extends State<CustomControls> {
  bool _isPaused = false;

  void _onTap() {
    setState(() {
      if (ChewieController.of(context)!.videoPlayerController.value.isPlaying) {
        ChewieController.of(context)!.videoPlayerController.pause();
        _isPaused = true;
      } else {
        ChewieController.of(context)!.videoPlayerController.play();
        _isPaused = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        children: [
          if (_isPaused)
            Center(
              child: Icon(
                Icons.pause,
                color: Colors.white,
                size: 100.0,
              ),
            ),
        ],
      ),
    );
  }
}
