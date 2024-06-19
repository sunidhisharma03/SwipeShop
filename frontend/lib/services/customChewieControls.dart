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
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          _buildPlayPause(videoPlayerController),
          // _buildBottomBar(context, chewieController),
        ],
      ),
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

  Widget _buildBottomBar(BuildContext context, ChewieController chewieController) {
    final videoPlayerController = chewieController.videoPlayerController;
    final position = videoPlayerController.value.position;

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 10),
          _buildMuteButton(videoPlayerController),
        ],
      ),
    );
  }

  Widget _buildMuteButton(VideoPlayerController videoPlayerController) {
    return IconButton(
      icon: Icon(
        _isMuted ? Icons.volume_off : Icons.volume_up,
        color: Colors.white,
      ),
      onPressed: () {
        setState(() {
          _isMuted = !_isMuted;
          videoPlayerController.setVolume(_isMuted ? 0.0 : 1.0);
        });
      },
    );
  }
}
