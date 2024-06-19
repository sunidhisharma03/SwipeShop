import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomChewieControls extends StatefulWidget {
  const CustomChewieControls({Key? key}) : super(key: key);

  @override
  _CustomChewieControlsState createState() => _CustomChewieControlsState();
}

class _CustomChewieControlsState extends State<CustomChewieControls> {
  bool _isMuted = false;
  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);
    final VideoPlayerController videoPlayerController = chewieController.videoPlayerController;

    return GestureDetector(
      onTap: () {
        setState(() {
          videoPlayerController.value.isPlaying
              ? videoPlayerController.pause()
              : videoPlayerController.play();
        });
      }
    );
  }

  Widget _buildPlayPause(VideoPlayerController videoPlayerController) {
    return Center(
      child: AnimatedOpacity(
        opacity: videoPlayerController.value.isPlaying ? 0.0 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: IconButton(
          iconSize: 60.0,
          icon: Icon(
            videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              videoPlayerController.value.isPlaying
                  ? videoPlayerController.pause()
                  : videoPlayerController.play();
            });
          },
        ),
      ),
    );
  }
}
 

