import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomChewieControls extends StatefulWidget {
  const CustomChewieControls({Key? key}) : super(key: key);

  @override
  _CustomChewieControlsState createState() => _CustomChewieControlsState();
}

class _CustomChewieControlsState extends State<CustomChewieControls> {
  ChewieController? _chewieController;
  bool _showControls = true; // Track if controls should be shown or hidden

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to ChewieController changes
    _chewieController = ChewieController.of(context);
    _chewieController?.addListener(_updateState);
  }

  @override
  void dispose() {
    _chewieController?.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    // Update local state based on ChewieController state
    if (_chewieController?.videoPlayerController.value.isPlaying ?? false) {
      _showControls = false; // Hide controls when video is playing
    } else {
      _showControls = true; // Show controls when video is paused
    }
    setState(() {}); // Trigger a rebuild
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = _chewieController!;
    final videoPlayerController = chewieController.videoPlayerController;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_showControls) {
            if (videoPlayerController.value.isPlaying) {
              videoPlayerController.pause();
            } else {
              videoPlayerController.play();
            }
          } else {
            _showControls = true; // Show controls when tapped while video is playing
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: videoPlayerController.value.aspectRatio,
            child: VideoPlayer(videoPlayerController),
          ),
          if (_showControls) ...[
            // _buildPlayPause(videoPlayerController),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayPause(VideoPlayerController videoPlayerController) {
    return Center(
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IconButton(
          iconSize: 60.0,
          icon: Icon(
            videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              if (videoPlayerController.value.isPlaying) {
                videoPlayerController.pause();
              } else {
                videoPlayerController.play();
              }
            });
          },
        ),
      ),
    );
  }
}
